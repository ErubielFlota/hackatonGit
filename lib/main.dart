import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:prueba2app/firebase_options.dart';
import 'package:prueba2app/theme/colors.dart'; 
import 'auth_checker.dart'; // ¡Importamos el comprobador de estado!

void main() async {
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
      debugShowCheckedModeBanner: false,
      title: 'Mi App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, //usa tu color global
          primary: primaryColor,
          background: backgroundColor,
        ),
        useMaterial3: true,
      ),
      // CAMBIO CLAVE: Usamos el AuthChecker como pantalla inicial.
      // El AuthChecker decidirá entre HomePage y Autentificacion (Login).
      home: const AuthChecker(),
    );
  }
}

