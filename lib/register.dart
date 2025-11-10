import 'package:flutter/material.dart';
import 'firebase_auth_dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- 1. IMPORTACIÓN NUEVA
import 'autentificacion.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthServiceImpl _authService = AuthServiceImpl();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // <-- 2. INSTANCIA NUEVA

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _handleRegistration() async {
    final email = _correoController.text.trim();
    final password = _contrasenaController.text.trim();
    final nombre = _nombreController.text.trim();
    final apellido = _apellidoController.text.trim(); // <-- Obtenemos el apellido

    // Requerimos que al menos el nombre, correo y contraseña no estén vacios
    if (email.isEmpty || password.isEmpty || nombre.isEmpty) { // <-- Dejamos la validación simple
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa el nombre, correo y contraseña.'),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Crear el usuario en Firebase Auth
      await _authService.register(email, password);

      // --- 3. INICIO DE LA MODIFICACIÓN ---
      // 2. Obtener el UID del usuario recién creado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No se pudo obtener el usuario recién creado.');
      }
      final uid = user.uid;

      // 3. Guardar los datos en Firestore
      await _firestore.collection('usuarios_registrados').doc(uid).set({
        'uid': uid,
        'nombres': nombre,
        'apellidos': apellido,
        'correo': email,
        // ¡¡¡NO GUARDES LA CONTRASEÑA EN FIRESTORE!!!
      });
      // --- FIN DE LA MODIFICACIÓN ---


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Cuenta creada! Revisa tu correo electrónico para verificar tu cuenta antes de iniciar sesión.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 8),
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Autentificacion()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;

      if (e.code == 'email-already-in-use') {
        errorMessage = 'El correo electrónico ya está registrado.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'La contraseña es demasiado débil (mínimo 6 caracteres).';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo electrónico es inválido.';
      } else {
        errorMessage = 'Error al crear la cuenta. Inténtalo de nuevo.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ocurrió un error inesperado: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...
    // TU WIDGET build(...) NO NECESITA CAMBIOS
    // ...
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        centerTitle: true,
        title: const Text(
          'CREA TU CUENTA',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: SingleChildScrollView(
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
                  child: Text(
                    'Nombre(s):',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller:
                      _nombreController, // Este ahora se guarda como 'nombres'
                  decoration: const InputDecoration(
                    hintText: 'Ingresa tu nombre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Apellidos:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller:
                      _apellidoController, // Este ahora se guarda como 'apellidos'
                  decoration: const InputDecoration(
                    hintText: 'Ingresa tus apellidos',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Correo electrónico:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller:
                      _correoController, // Este se guarda como 'correo'
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Ingresa tu dirección de correo',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Contraseña:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 5),
                TextField(
                  controller: _contrasenaController,
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
                    onPressed: _isLoading ? null : _handleRegistration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            ),
                          )
                        : const Text(
                            'Crear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}