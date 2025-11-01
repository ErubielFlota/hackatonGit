import 'package:flutter/material.dart';

class AgriculturaPage extends StatelessWidget {
  const AgriculturaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'Programas de Agricultura',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        
        child: Text(
          'Aquí se mostrarán los programas agrícolas',
          style: TextStyle(fontSize: 20, color: Colors.green),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
