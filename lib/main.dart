import 'package:flutter/material.dart';

// Import main app pages
import 'screens/home_page.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TrestleApp(),
    ),
  );
}

class TrestleApp extends StatefulWidget {
  const TrestleApp({super.key});

  @override
  _TrestleAppState createState() => _TrestleAppState();
}

class _TrestleAppState extends State<TrestleApp> {
  final String userName = "Marc Velasquez";

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trestle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: WelcomeScreen(userName: userName),
    );
  }
}
