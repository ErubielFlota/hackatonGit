//archivo donde tengo creado los metodos para registro de los usuarios

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServiceImpl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- FUNCIÓN DE INICIO DE SESIÓN MODIFICADA ---
  // Ahora devuelve User? para facilitar la comprobación de emailVerified
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Devolvemos el objeto User asociado al inicio de sesión
      return userCredential.user; 
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en inicio de sesión: ${e.code}');
      // Usamos rethrow para que la UI pueda manejar los códigos de error específicos.
      rethrow; 
    } catch (e) {
      debugPrint('Error desconocido en signIn: $e');
      rethrow;
    }
  }

  // --- FUNCIÓN DE REGISTRO MODIFICADA ---
  // Ahora envía el correo de verificación y devuelve User?
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      
      // ** PASO CLAVE: ENVIAR VERIFICACIÓN POR CORREO **
      // Esto dispara el correo electrónico de Firebase al usuario recién registrado.
      await user?.sendEmailVerification();
      
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en registro: ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('Error desconocido en register: $e');
      rethrow;
    }
  }
}