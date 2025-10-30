import 'package:flutter/material.dart';

import 'package:prueba2app/welcome_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      theme: ThemeData( useMaterial3: true),
      debugShowCheckedModeBanner: false,
      home:WelcomeScreen()
    );
  }
}