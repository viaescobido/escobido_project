
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

class ParkKeysApp extends StatelessWidget {
  const ParkKeysApp({super.key});

  static const Color primaryPurple = Color(0xFF6941C6);
  static const Color darkPurple = Color(0xFF35245E);
  static const Color lightPurple = Color(0xFFF2EDFC);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ParkKeys',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
        ),
        scaffoldBackgroundColor: const Color(0xFFF9F8FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: darkPurple,
          elevation: 0,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
