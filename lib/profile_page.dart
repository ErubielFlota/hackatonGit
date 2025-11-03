import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: const Text('Mi perfil'),
        actions: [
          IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
             Navigator.pop(context);
          },
        ),
        ],
       ),
       body: Center(
        child: Text(
          'Bienvenido, ${FirebaseAuth.instance.currentUser?.email ?? 'Usuario'}'
        )
       )
      
    );
  }
}