import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'autentificacion.dart';
import 'bienvenida.dart'; 

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Código para usuario no autenticado
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          automaticallyImplyLeading: false,
          title: const Text(
            'Mi perfil',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Debes iniciar sesión para acceder a esta página.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Autentificacion(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Código para usuario autenticado
    return Scaffold(
      appBar: AppBar(
        
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const BienvenidaScreen()), 
                  (Route<dynamic> route) =>
                      false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Bienvenido, ${user.email ?? 'Usuario'}',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}