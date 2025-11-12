import 'package:flutter/material.dart';
import 'package:prueba2app/home_page.dart';
import 'package:prueba2app/theme/colors.dart';
import 'firebase_auth_dart.dart';
import 'register.dart'; 
import 'package:firebase_auth/firebase_auth.dart';

class Autentificacion extends StatefulWidget {
  const Autentificacion({super.key});
  
  @override
  State<Autentificacion> createState() => AuthPageState();
}

class AuthPageState extends State<Autentificacion> {
  final AuthServiceImpl _authService = AuthServiceImpl();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  void _showVerificationPendingDialog(User user) {
    // (Tu código original - Sin cambios)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: const Text("Verificación de Correo Requerida", textAlign: TextAlign.center),
          content: const Text(
            "Tu correo electrónico no ha sido verificado. Por favor, revisa tu bandeja de entrada (o spam) y haz clic en el enlace de verificación.",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              child: const Text('Reenviar Correo', style: TextStyle(color: Colors.orange)),
              onPressed: () async {
                Navigator.of(context).pop();
                setState(() => _isLoading = true);
                try {
                  await user.sendEmailVerification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Correo de verificación reenviado con éxito.')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al reenviar el correo.')),
                  );
                } finally {
                  setState(() => _isLoading = false);
                }
              },
            ),
            TextButton(
              child: const Text('Ya Verifiqué'),
              onPressed: () async {
                
                await user.reload();
                User? reloadedUser = FirebaseAuth.instance.currentUser;

                Navigator.of(context).pop();

                if (reloadedUser != null && reloadedUser.emailVerified) {
                  
                  if (mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  }
                } else {
                  
                  if (mounted) {
                    _showVerificationPendingDialog(user);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sigue pendiente la verificación. Por favor, inténtalo de nuevo.')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }



  void _mostrarVentanaInvitado(BuildContext context) {
    // (Tu código original - Sin cambios)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Al no registrarse no podrá tener los siguientes beneficios de la aplicación:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("* Notificaciones en su correo de programas disponibles."),
                    Text("* Acceder al apartado de quejas y sugerencias."),
                    Text("* Interactuar con el asistente Chatbot."),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      
                      Navigator.pop(context); 
                      Navigator.pushReplacement( 
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Continuar", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> _handleSignIn() async {
    // (Tu código original - Sin cambios)
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo y contraseña.')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    User? user;
    try {
      user = await _authService.signIn(_emailController.text, _passwordController.text);
      
      if (user != null) {
        if (user.emailVerified) {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomePage()), 
            );
          }
        } else {
          if (mounted) {
            _showVerificationPendingDialog(user);
          }
        }
      }

    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage;
        if (e.code == 'user-not-found') {
          errorMessage = 'No se encontró una cuenta con ese correo.';
        } else if (e.code == 'wrong-password') {
          errorMessage = 'Contraseña incorrecta.';
        } else {
          errorMessage = 'Error al iniciar sesión. Verifica tus datos.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ocurrió un error inesperado al iniciar sesión.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ----- INICIO DEL CÓDIGO AÑADIDO -----

  Future<void> _enviarCorreoReseteo(String email, BuildContext dialogContext) async {
    // Este 'dialogContext' es el contexto del Pop-Up
    
    // Muestra un indicador de carga DENTRO del Pop-Up
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  
    if (email.isEmpty) {
      Navigator.pop(context); // Oculta el indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu correo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
  
    try {
      // 1. Llama a tu servicio
      await _authService.sendPasswordResetEmail(email);
  
      Navigator.pop(context); // Oculta el indicador de carga
      Navigator.pop(dialogContext); // Cierra el pop-up de reseteo
  
      // 2. Avisa al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Correo enviado! Revisa tu bandeja de entrada.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Oculta el indicador de carga
      
      // 3. Maneja errores
      String mensaje = 'Ocurrió un error. Intenta de nuevo.';
      if (e.code == 'user-not-found') {
        mensaje = 'No se encontró ningún usuario con ese correo electrónico.';
      } else if (e.code == 'invalid-email') {
        mensaje = 'El formato del correo es inválido.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      Navigator.pop(context); // Oculta el indicador de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  // Esta función muestra el Pop-Up (AlertDialog)
  void _mostrarDialogoReseteo() {
    final TextEditingController correoReseteoController = TextEditingController();
  
    showDialog(
      context: context,
      builder: (dialogContext) { // Usamos un 'dialogContext' diferente
        return AlertDialog(
          title: const Text('Restablecer Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  'Ingresa tu correo y te enviaremos un link para restablecer tu contraseña.'),
              const SizedBox(height: 16),
              TextField(
                controller: correoReseteoController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), // Usa dialogContext
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Llama a la función de lógica
                _enviarCorreoReseteo(
                    correoReseteoController.text.trim(), dialogContext);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
  
  // ----- FIN DEL CÓDIGO AÑADIDO -----


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Inicia sesión',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: primaryColor.darker,
                ),
              ),
              const SizedBox(height: 50),

              
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  hintText: 'Ingrese su correo electrónico',
                  prefixIcon: Icon(Icons.email, color: primaryColor.darker),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  prefixIcon: Icon(Icons.lock, color: primaryColor.darker),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: primaryColor, width: 2),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              
              // ----- AQUÍ ESTÁ EL BOTÓN AÑADIDO -----
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Llama a la función que muestra el pop-up
                    _mostrarDialogoReseteo();
                  },
                  child: Text(
                    '¿Has olvidado tu contraseña?',
                    style: TextStyle(color: primaryColor.darker),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Inicio',
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 30),

              
              const Text(
                'O continúa con',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  IconButton(
                    icon: const Icon(Icons.g_mobiledata, size: 36),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login con Google pendiente')),
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  
                  IconButton(
                    icon: const Icon(Icons.facebook, size: 32, color: Colors.blue),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login con Facebook pendiente')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '¿No tienes una cuenta? ',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      'Crea una.',
                      style: TextStyle(
                        fontSize: 16,
                        color: primaryColor.darker,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: primaryColor.darker),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onPressed: () {
                    
                    _mostrarVentanaInvitado(context);
                  },
                  child:Text(
                    'Omitir por ahora',
                    style: TextStyle(fontSize: 20, color: primaryColor.darker),
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