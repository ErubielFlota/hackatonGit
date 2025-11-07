import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prueba2app/bienvenida.dart';
import 'package:prueba2app/firebase_options.dart';


void main() async {
  // 🔹 Asegura que Flutter esté inicializado antes de usar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

Future<void> main2() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0078D0), // 🔹 tu color principal
          primary: const Color(0xFF0078D0),
          background: const Color(0xFFFBFCFB), // 🔸 fondo claro
        ),
        useMaterial3: true,
      ),
      home: const BienvenidaScreen(),
    );
  }
}

