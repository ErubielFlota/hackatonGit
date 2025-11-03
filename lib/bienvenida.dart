import 'package:flutter/material.dart';
import 'package:prueba2app/autentificacion.dart';


class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 30),
              Expanded(
                child: Column(
                  children: [
                    
                    Image.asset(
                      'assets/family_illustration.png',
                      height: 220,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bienvenido',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Te presentamos una forma sencilla de conocer acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  FilledButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Autentificacion(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('COMENZAR', style: TextStyle(fontSize: 16)),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: const [
                      SizedBox(height: 8),
                      Text('© Derechos reservados 2025',
                          style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                      Text('MiApoyo',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


