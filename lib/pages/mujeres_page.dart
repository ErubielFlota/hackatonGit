import 'package:flutter/material.dart';

class MujeresPage extends StatelessWidget {
  const MujeresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: const Text(
          'Programas para Mujeres',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrarán los programas dirigidos a mujeres',
          style: TextStyle(fontSize: 20, color: Colors.pinkAccent),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
