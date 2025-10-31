import 'package:flutter/material.dart';

class EducacionPage extends StatelessWidget {
  const EducacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4FF),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Programas de Educación',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los programas educativos',
          style: TextStyle(fontSize: 20, color: Colors.blueAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
