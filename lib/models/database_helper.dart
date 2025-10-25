import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'todo.dart'; // Import model Todo

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  String todoTable = 'todo_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colCreatedAt = 'createdAt';
  String colDeadline = 'deadline';
  String colIsDone = 'isDone';

  // Getter database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  //  Inisialisasi lokasi penyimpanan database
  Future<Database> _initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'todo_list.db');
    var todoListDb = await openDatabase(path, version: 1, onCreate: _createDb);
    return todoListDb;
  }

  // Membuat Tabel
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $todoTable($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colCreatedAt TEXT, $colDeadline TEXT, $colIsDone INTEGER)');
  }

  // --- CRUD Operations ---

  // CREATE: Insert To-Do (Tambah Data)
  Future<int> insertTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.insert(todoTable, todo.toMap());
    return result; // Mengembalikan ID dari data yang baru diinput
  }

  // READ: Get To-Do (Ambil Data)
  Future<List<Todo>> getTodoList() async {
    Database db = await this.database;
    var result = await db.query(todoTable, orderBy: '$colId DESC');

    // Konversi List<Map> menjadi List<Todo>
    List<Todo> todoList = [];
    result.forEach((map) {
      todoList.add(Todo.fromMap(map));
    });

    return todoList;
  }

  // UPDATE: Update To-Do (Ubah Data)
  Future<int> updateTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.update(todoTable, todo.toMap(),
        where: '$colId = ?', whereArgs: [todo.id]);
    return result; // Mengembalikan jumlah baris yang terpengaruh
  }

  // DELETE: Delete To-Do (Hapus Data)
  Future<int> deleteTodo(int id) async {
    Database db = await this.database;
    var result =
    await db.delete(todoTable, where: '$colId = ?', whereArgs: [id]);
    return result; // Mengembalikan jumlah baris yang dihapus
  }
}