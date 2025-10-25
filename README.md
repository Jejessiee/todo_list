# todo_list

Aplikasi To-Do List Lokal (Daily Planner)

## Getting Started

Aplikasi mobile multi-platform sederhana yang dibuat dengan Flutter dan Dart, menggunakan database SQLite untuk penyimpanan data lokal persisten.

Fitur Utama
Aplikasi ini memenuhi semua kriteria tugas, termasuk fitur CRUD dasar, persistensi data, manajemen deadline, dan antarmuka pengguna yang modern.

1. Penyimpanan Lokal Persisten (SQLite): Semua tugas disimpan di database SQLite lokal perangkat, memastikan data tetap ada meskipun aplikasi ditutup.
2. Operasi CRUD Lengkap: Create (Tambah), Read (Lihat Daftar), Update (Edit Detail / Tandai Selesai), Delete (Hapus via Swipe).
3. Manajemen Deadline: Setiap tugas memiliki batas waktu (deadline) yang dapat diatur menggunakan Date Picker.
4. Sistem Peringatan Visual: Tampilan daftar otomatis memberikan warning (peringatan) visual berdasarkan status deadline:
5. Desain Antarmuka: Menggunakan ListView dan tampilan Card yang menarik.
6. Umpan Balik Instan: Menggunakan Snackbar untuk konfirmasi setiap aksi (tambah, perbarui status, hapus).

Dependencies yang digunakan:
1. sqflite: Database SQLite untuk penyimpanan data lokal.
2. path_provider: Membantu menemukan jalur file dokumen untuk database.
3. intl: Digunakan untuk memformat dan membandingkan tanggal (deadline).

Struktur kode:
1. lib/main.dart sebagai titik masuk aplikasi dengan memanggil screen.dart.
2. lib/models/todo.dart sebagai model data yang mendefinisikan struktur Todo dan fungsi Map untuk SQLite.
3. lib/models/database_helper.dart sebagai lapisan data (CRUD) yang mengelola koneksi database, pembuatan tabel, dan operasi CRUD.
4. lib/models/screen.dart sebagai layar utama yang menampilkan hasil.
5. lib/models/edit_todo.dart sebagai layar input form yang berisi form untuk input data.
