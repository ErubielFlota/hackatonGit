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
  late Timer _timer;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final double width = mq.size.width;

    // Responsividad básica
    final bool isTablet = width > 600;
    final bool isDesktop = width > 900;

    return Scaffold(
      backgroundColor: _showSplash ? primaryColor : backgroundColor,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: _showSplash
            ? _buildSplashView(isTablet, isDesktop)
            : _buildWelcomeView(context, isTablet, isDesktop),
      ),
    );
  }

  // -------------------------------
  // 🔵 VISTA SPLASH
  // -------------------------------
  Widget _buildSplashView(bool isTablet, bool isDesktop) {
    double logoSize = isDesktop
        ? 260
        : isTablet
            ? 200
            : 150;

    return Center(
      key: const ValueKey('splash'),
      child: Image.asset(
        'assets/logoblanco.png',
        width: logoSize,
        height: logoSize,
      ),
    );
  }

  // -------------------------------
  // 🔵 VISTA BIENVENIDA
  // -------------------------------
  Widget _buildWelcomeView(
      BuildContext context, bool isTablet, bool isDesktop) {
    double logoSize = isDesktop
        ? 220
        : isTablet
            ? 180
            : 140;

    double titleSize = isDesktop
        ? 38
        : isTablet
            ? 30
            : 26;

    double textSize = isDesktop
        ? 20
        : isTablet
            ? 17
            : 15;

    double buttonFontSize = isDesktop
        ? 22
        : isTablet
            ? 18
            : 16;

    EdgeInsets padding = EdgeInsets.symmetric(
      horizontal: isDesktop
          ? 200
          : isTablet
              ? 80
              : 24,
    );

    return Center(
      key: const ValueKey('welcome'),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/logoazul.png',
              width: logoSize,
              height: logoSize,
            ),

            SizedBox(height: isTablet ? 40 : 30),

            // Título
            Text(
              'Bienvenido',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 10),

            // Descripción
            Text(
              'Te presentamos una forma sencilla de conocer acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize,
                color: Colors.black54,
              ),
            ),

            SizedBox(height: isTablet ? 50 : 40),

            // BOTÓN COMENZAR
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 6,
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 40 : 32,
                  vertical: isTablet ? 22 : 18,
                ),
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
              child: Text(
                'COMENZAR',
                style: TextStyle(
                  fontSize: buttonFontSize,
                  color: Colors.white,
                ),
              ),
            ),

            SizedBox(height: isTablet ? 80 : 60),

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
