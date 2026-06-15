import 'package:flutter/material.dart';
import 'screens/lista_screen.dart';

void main() {
  runApp(const GestorCommApp());
}

class GestorCommApp extends StatelessWidget {
  const GestorCommApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestorComm',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F42C1),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF6F42C1),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6F42C1),
          foregroundColor: Colors.white,
        ),
      ),
      home: const ListaScreen(),
    );
  }
}
