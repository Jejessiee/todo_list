class Todo {
  int? id; // nullable
  String title;
  String description;
  String createdAt; // Tanggal dibuat
  String deadline;  // Tanggal batas waktu
  int isDone; // 0 = Belum Selesai, 1 = Selesai

  // Constructor
  Todo({
    this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.deadline,
    this.isDone = 0, // Nilai default 0 (belum selesai)
  });

  // Metode untuk mengonversi objek Todo ke Map (untuk SQLite)
  Map<String, dynamic> toMap() {
    // Digunakan untuk menyimpan data ke database (INSERT/UPDATE)
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'deadline': deadline,
      'isDone': isDone,
    };
  }

// Factory Constructor untuk membuat objek Todo dari Map (dari SQLite)
  factory Todo.fromMap(Map<String, dynamic> map) {
    // Memberikan nilai default String jika nilai dari database adalah null
    const String defaultDate = '2025-01-01';

    // Digunakan saat membaca data dari database (SELECT).
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      createdAt: map['createdAt'] ?? defaultDate,
      deadline: map['deadline'] ?? defaultDate,
      isDone: map['isDone'],
    );
  }
}