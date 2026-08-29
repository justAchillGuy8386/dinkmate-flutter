import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const DinkMateApp());
}

class DinkMateApp extends StatelessWidget {
  const DinkMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseTheme = AppTheme.theme;
    return MaterialApp(
      title: 'DinkMate',
      debugShowCheckedModeBanner: false,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.nunitoTextTheme(baseTheme.textTheme),
      ),
      home: const LoginScreen(),
    );
  }
}