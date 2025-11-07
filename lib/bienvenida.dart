import 'dart:async';
import 'package:flutter/material.dart';
import 'package:prueba2app/autentificacion.dart';
import 'package:prueba2app/theme/colors.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  bool _showSplash = true; // Controla qué pantalla mostrar

  @override
  void initState() {
    super.initState();

    // Espera 3 segundos y cambia de splash a bienvenida
    Timer(const Duration(seconds: 3), () {
      setState(() {
        _showSplash = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          _showSplash ? primaryColor : backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _showSplash ? _buildSplashView() : _buildWelcomeView(context),
      ),
    );
  }

  // 🔹 Pantalla Splash (logo grande sobre fondo azul)
  Widget _buildSplashView() {
    return Center(
      key: const ValueKey('splash'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/logo2.png', // asegúrate de tenerlo registrado en pubspec.yaml
            width: 180,
            height: 180,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // 🔹 Pantalla de bienvenida (botón "COMENZAR")
  Widget _buildWelcomeView(BuildContext context) {
    return Center(
      key: const ValueKey('welcome'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo_app.png',
              width: 140,
              height: 140,
            ),
            const SizedBox(height: 30),
            const Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Te presentamos una forma sencilla de conocer acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:primaryColor,
                elevation: 6,
                shadowColor: primaryColor.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const Autentificacion()),
                );
              },
              child: const Text(
                'COMENZAR',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 60),
            const Text(
              'Derechos reservados 2025',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
