import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const DinkMateApp());
}

class DinkMateApp extends StatelessWidget {
  const DinkMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DinkMate',
      debugShowCheckedModeBanner: false, // Tắt chữ "DEBUG" ở góc phải
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        // Dùng font chữ của Google cho toàn App
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}