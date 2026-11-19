import 'package:flutter/material.dart';

void main() {
  runApp(const MuktoKeyboardApp());
}

class MuktoKeyboardApp extends StatelessWidget {
  const MuktoKeyboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'মুক্ত কিবোর্ড',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1565C0),
        ),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'মুক্ত কিবোর্ড',
            style: TextStyle(fontSize: 32),
          ),
        ),
      ),
    );
  }
}
