import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../models/database_helper.dart';
import '../models/edit_todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late Future<List<Todo>> _todoListFuture;
  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper(); // Mendapatkan instance DatabaseHelper (SQLite)
    _refreshTodoList(); // Memuat data pertama kali
  }

  // Fungsi untuk memuat ulang daftar dari database
  void _refreshTodoList() {
    setState(() {
      _todoListFuture = _dbHelper.getTodoList();
    });
  }

  // Aksi Toggle Selesai/Belum Selesai (Update)
  void _toggleTodoStatus(Todo todo) async {
    todo.isDone = todo.isDone == 0 ? 1 : 0;
    await _dbHelper.updateTodo(todo);
    _refreshTodoList();
    _showSnackbar(
        'Tugas "${todo.title}" ${todo.isDone == 1 ? 'selesai' : 'belum selesai'}');
  }

  // Aksi Hapus (Delete)
  void _deleteTodo(int id, String title) async {
    await _dbHelper.deleteTodo(id);
    _refreshTodoList();
    _showSnackbar('Tugas "$title" berhasil dihapus', isError: true);
  }

  // Aksi Menampilkan Snackbar (Poin 6)
  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ), // SnackBar
    );
  }

  // Aksi Navigasi ke Layar Tambah/Edit
  void _navigateToAddEditScreen([Todo? todo]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTodoScreen(todo: todo),
      ), // MaterialPageRpute
    );

    if (result != null) {
      _refreshTodoList();
      _showSnackbar('Tugas berhasil $result');
    }
  }

  // Fungsi untuk warning
  Color _getCardColor(Todo todo) {
    if (todo.isDone == 1) {
      return Colors.green.shade50; // Hijau muda jika selesai
    }

    // Cek apakah deadline terlampaui
    final deadlineDate = DateTime.parse(todo.deadline);
    final today = DateTime.now();
    final isOverdue = deadlineDate.isBefore(today) && deadlineDate.day != today.day;

    if (isOverdue) {
      return Colors.red.shade100; // Merah muda jika terlambat
    } else if (deadlineDate.difference(today).inDays <= 1) {
      return Colors.amber.shade100; // Kuning muda jika hampir terlambat (H-1)
    }

    return Colors.white; // Putih default
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Tugas Prioritas'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 4,
      ), // AppBar
      body: FutureBuilder<List<Todo>>(
        future: _todoListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada tugas. Silahkan tambah tugas baru!'));
          } else {
            // ListView untuk menampilkan tugas yang ada dari database
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                final deadlineDate = DateTime.parse(todo.deadline);
                final today = DateTime.now();
                final isOverdue = deadlineDate.isBefore(today) && deadlineDate.day != today.day;

                return Dismissible(
                  key: Key(todo.id.toString()), // Untuk swipe to delete
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deleteTodo(todo.id!, todo.title),
                  background: Container(
                    color: Colors.red.shade700,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete_forever, color: Colors.white, size: 30),
                  ), // Container
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 3,
                    color: _getCardColor(todo),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    // Menampilkan judul, deskripsi, dan status tugas (ListTile)
                    child: ListTile(
                      // Aksi Toggle Status (Menandai selesai/belum selesai)
                      onTap: () => _toggleTodoStatus(todo),
                      // Aksi Edit
                      onLongPress: () => _navigateToAddEditScreen(todo),

                      leading: Icon(
                        todo.isDone == 1 ? Icons.check_box : Icons.check_box_outline_blank,
                        color: todo.isDone == 1 ? Colors.green.shade800 : Colors.indigo.shade300,
                      ), // Icon
                      title: Text(
                        todo.title,
                        style: TextStyle(
                          decoration: todo.isDone == 1 ? TextDecoration.lineThrough : TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ), // TextStyle
                      ), // Text
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(todo.description.isEmpty ? 'Tidak ada detail' : todo.description, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              // Ikon peringatan overdue
                              if (isOverdue && todo.isDone == 0)
                                const Icon(Icons.warning_amber, color: Colors.red, size: 16),

                              Text(
                                'Deadline: ${todo.deadline}',
                                style: TextStyle(
                                  color: isOverdue && todo.isDone == 0 ? Colors.red.shade800 : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ), // TextStyle
                              ), // Text
                            ],
                          ), // Row
                        ],
                      ), // Column
                      trailing: const Icon(Icons.chevron_right, color: Colors.indigo),
                    ), // ListTile
                  ), // Card
                ); // Dismissible
              },
            ); // ListView.builder
          }
        },
      ), // FutureBuilder
      // Tombol FAB untuk Menambah Tugas
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddEditScreen(),
        backgroundColor: Colors.indigoAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_task),
      ), // FloatingActionButton
    ); // Scaffold
  }
}