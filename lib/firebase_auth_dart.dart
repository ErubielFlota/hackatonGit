//archivo donde tengo creado los metodos para registro de los usuarios

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthServiceImpl {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  
  Future<UserCredential> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en inicio de sesión: ${e.code}');
      
      rethrow; 
    }
  }

  
  Future<UserCredential> register(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('Error en registro: ${e.code}');
      rethrow;
    }
  }
}