import 'package:flutter/material.dart';
import 'models/screen.dart';

void main() {
  // Pastikan inisialisasi widget sudah dilakukan sebelum memanggil runApp
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi To-Do List Lokal',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: const AppBarTheme(
            color: Colors.blueAccent,
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: IconThemeData(color: Colors.white),
          )
      ),
      home: const TodoListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}