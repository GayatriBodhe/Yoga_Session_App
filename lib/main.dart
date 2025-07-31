import 'package:flutter/material.dart';
import 'package:yoga_session_app/screens/preview_screen.dart';

void main() {
  runApp(const YogaSessionApp());
}

class YogaSessionApp extends StatelessWidget {
  const YogaSessionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yoga Session App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 18, color: Colors.black87),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      home: const PreviewScreen(),
    );
  }
}
