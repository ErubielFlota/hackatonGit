import 'package:flutter/material.dart';
import 'package:prueba2app/login.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Inicia sesión',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ingrese su correo electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Ingresa tu contraseña',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('¿Has olvidado tu contraseña?'),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Inicio', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 20),
              const Center(child: Text('O continúa con')),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 36),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.facebook,
                      size: 32,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('¿No tienes una cuenta?'),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    child: const Text('Crea una.'),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context); // Regresa a la bienvenida
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Omitir por ahora'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
