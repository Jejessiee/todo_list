import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../models/database_helper.dart';

class AddEditTodoScreen extends StatefulWidget {
  final Todo? todo; // Nullable: untuk Tambah baru. Jika ada nilai: untuk Edit.

  const AddEditTodoScreen({super.key, this.todo});

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _deadline;
  late DatabaseHelper _dbHelper;

  // Inisialisasi DatabaseHelper
  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    // Inisialisasi nilai form dengan data tugas lama jika ada
    _title = widget.todo?.title ?? '';
    _description = widget.todo?.description ?? '';
    _deadline = widget.todo?.deadline ?? DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));
  }

  // Fungsi untuk menampilkan Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.parse(_deadline),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030));
    if (picked != null) {
      setState(() {
        _deadline = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _saveTodo() async {
    if (_formKey.currentState!.validate()) { // Validasi
      _formKey.currentState!.save(); // Simpan Nilai

      String actionMessage = widget.todo == null ? 'ditambahkan' : 'diperbarui';

      // operasi CREATE (Tambah) atau UPDATE (Edit)
      final newTodo = Todo(
        id: widget.todo?.id, // ID diambil jika mode Edit
        title: _title,
        description: _description,
        createdAt: widget.todo?.createdAt ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
        deadline: _deadline,
        isDone: widget.todo?.isDone ?? 0,
      ); // Todo

      if (widget.todo == null) { // Jika bernilai null
        await _dbHelper.insertTodo(newTodo); // CREATE
      } else {
        await _dbHelper.updateTodo(newTodo); // UPDATE
      }

      // Kirim pesan konfirmasi kembali ke layar utama
      if (!mounted) return;
      Navigator.pop(context, actionMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.todo == null ? 'Tambah Tugas Baru' : 'Edit Tugas'),
        backgroundColor: Colors.indigo,
      ), // AppBar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            // Form dan Column
            children: <Widget>[
              // Input Judul
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: 'Judul Tugas',
                  border: OutlineInputBorder(),
                ), // InputDecoration
                // Logika Validasi
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ), // TextFormField
              const SizedBox(height: 16),
              // Input Deskripsi
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  prefixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                onSaved: (value) {
                  _description = value ?? '';
                },
              ), // TextFormField
              const SizedBox(height: 16),
              // Input Deadline (Date Picker)
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Batas Waktu (Deadline)',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ), // InputDecoration
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _deadline,
                      style: const TextStyle(fontSize: 16),
                    ), // Text
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('PILIH TANGGAL'),
                    ), // TextButton
                  ], // <Widget>[]
                ), // Row
              ), // InputDecorator
              const SizedBox(height: 30),
              // Tombol Simpan/Perbarui
              ElevatedButton.icon(
                onPressed: _saveTodo,
                icon: Icon(widget.todo == null ? Icons.save : Icons.update),
                label: Text(
                  widget.todo == null ? 'SIMPAN TUGAS' : 'PERBARUI TUGAS',
                  style: const TextStyle(fontSize: 18),
                ), // Text
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ), // ElevatedButton.icon
            ], // <Widget>[]
          ), // Column
        ), // Form
      ), // Padding
    ); // Scaffold
  }
}