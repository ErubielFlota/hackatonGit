import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 📌 Necesario para bloquear orientación
import 'package:prueba2app/firebase_options.dart';
import 'package:prueba2app/theme/colors.dart';
import 'auth_checker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔒 BLOQUEO DE ORIENTACIÓN A VERTICAL
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  if (Firebase.apps.isEmpty) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (_) {}
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
          background: backgroundColor,
        ),
        useMaterial3: true,
      ),
      home: const AuthChecker(),
    );
  }
}


