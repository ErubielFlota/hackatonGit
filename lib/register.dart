import 'package:flutter/material.dart';
import 'firebase_auth_dart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'autentificacion.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  
  final AuthServiceImpl _authService = AuthServiceImpl();
  
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

    // Requerimos que al menos el nombre, correo y contraseña no estén vacios 
    if (email.isEmpty || password.isEmpty || _nombreController.text.isEmpty) {
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
      await _authService.register(email, password);

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
      }
       else {
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
        ).showSnackBar(const SnackBar(content: Text('Ocurrió un error inesperado.')));
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
                      _nombreController, 
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
                      _apellidoController,
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
                      _correoController, 
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
                  controller:
                      _contrasenaController,
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
                    onPressed: _isLoading
                        ? null
                        : _handleRegistration, 

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