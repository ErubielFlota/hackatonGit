import 'package:flutter/material.dart';

class ViviendaPage extends StatelessWidget {
  const ViviendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'Programas de Vivienda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los programas para vivienda',
          style: TextStyle(fontSize: 20, color: Colors.orangeAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
