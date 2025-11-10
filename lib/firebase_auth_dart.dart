import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServiceImpl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- FUNCIÓN DE INICIO de SESIÓN (Sin cambios) ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return userCredential.user; 
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en inicio de sesión: ${e.code}');
      rethrow; 
    } catch (e) {
      debugPrint('Error desconocido en signIn: $e');
      rethrow;
    }
  }

  // --- FUNCIÓN DE REGISTRO (Sin cambios) ---
  Future<User?> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = userCredential.user;
      
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

  // --- ¡NUEVA FUNCIÓN AÑADIDA! ---
  // Esta es la lógica pura para enviar el correo.
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Deja que la UI (la página de login) maneje los códigos de error
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}