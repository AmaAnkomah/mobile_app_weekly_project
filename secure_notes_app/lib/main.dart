import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';


void main() {
  runApp(const SecureNotesApp());
}


class SecureNotesApp extends StatelessWidget {
  const SecureNotesApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade900),
        useMaterial3: true,
        fontFamily: 'Roboto', // Default fallback
      ),
      home: const AuthScreen(),
    );
  }
}
