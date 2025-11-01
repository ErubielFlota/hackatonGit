import 'package:flutter/material.dart';

class MayoresPage extends StatelessWidget {
  const MayoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'Programas para Mayores de Edad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los programas dirigidos a mayores de edad',
          style: TextStyle(fontSize: 20, color: Colors.purpleAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
