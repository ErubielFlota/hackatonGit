import 'package:flutter/material.dart';
import 'login_screen.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nombreController = TextEditingController();
    final apellidoController = TextEditingController();
    final correoController = TextEditingController();
    final contrasenaController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: const Text(
          'CREA TU CUENTA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Nombre(s):', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: nombreController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Apellidos:', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: apellidoController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tus apellidos',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Correo electrónico:', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: correoController,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu dirección de correo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Contraseña:', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: contrasenaController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Ingrese su contraseña',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cuenta creada correctamente')),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Crear',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
