import 'package:flutter/material.dart';
import 'package:prueba2app/home_page.dart';
import 'package:prueba2app/theme/colors.dart';
import 'firebase_auth_dart.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // ───────────────────────────────────────────────────────────────
  // TUS FUNCIONES ORIGINALES (NO SE MODIFICÓ NINGUNA)
  // ───────────────────────────────────────────────────────────────

  void _showVerificationPendingDialog(User user) {
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
                  if (reloadedUser.email != user.email) {
                    try {
                      await FirebaseFirestore.instance
                          .collection("usuarios_registrados")
                          .doc(reloadedUser.uid)
                          .set({
                        "correo": reloadedUser.email,
                        "correo_pendiente": FieldValue.delete(),
                      }, SetOptions(merge: true));
                    } catch (e) {}
                  }

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Si decides no registrarte.",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              const Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("No tendrás acceso a las notificaciones de programas disponibles, al apartado de quejas y sugerencias, ni a la interacción con el asistente Chatbot."),
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
                      backgroundColor: primaryColor.darker,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(100, 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa tu correo y contraseña.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    User? user;
    try {
      user = await _authService.signIn(_emailController.text, _passwordController.text);

      if (user != null) {
        if (user.emailVerified) {
          if (mounted) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
          }
        } else {
          if (mounted) _showVerificationPendingDialog(user);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = (e.code == 'user-not-found')
            ? 'No se encontró una cuenta con ese correo.'
            : (e.code == 'wrong-password')
                ? 'Contraseña incorrecta.'
                : 'Error al iniciar sesión.';

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Reset password (NO SE MODIFICÓ)
  Future<void> _enviarCorreoReseteo(String email, BuildContext dialogContext) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    if (email.isEmpty) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa tu correo.'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await _authService.sendPasswordResetEmail(email);

      Navigator.pop(context);
      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Correo enviado!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _mostrarDialogoReseteo() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Restablecer Contraseña'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa tu correo y te enviaremos un link.'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _enviarCorreoReseteo(controller.text.trim(), dialogContext);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //               PANTALLA RESPONSIVA
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        final titleSize = w * 0.08; // antes: 32
        final inputFont = w * 0.045; // antes: 16
        final buttonFont = w * 0.05; // antes: 20
        final smallText = w * 0.04;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: w * 0.06,
                vertical: w * 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Inicia sesión',
                    style: TextStyle(
                      fontSize: titleSize.clamp(22, 34),
                      fontWeight: FontWeight.bold,
                      color: primaryColor.darker,
                    ),
                  ),

                  SizedBox(height: w * 0.12),

                  TextField(
                    controller: _emailController,
                    style: TextStyle(fontSize: inputFont),
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      hintText: 'Ingresa tu correo electrónico',
                      labelStyle: TextStyle(fontSize: smallText),
                      prefixIcon: Icon(Icons.email, color: primaryColor.darker),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  SizedBox(height: w * 0.05),

                  TextField(
                    controller: _passwordController,
                    style: TextStyle(fontSize: inputFont),
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      hintText:'Ingresa tu contraseña',
                      labelStyle: TextStyle(fontSize: smallText),
                      prefixIcon: Icon(Icons.lock, color: primaryColor.darker),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    obscureText: true,
                  ),

                  SizedBox(height: w * 0.02),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _mostrarDialogoReseteo,
                      child: Text(
                        '¿Has olvidado tu contraseña?',
                        style: TextStyle(
                          fontSize: smallText,
                          color: primaryColor.darker,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: w * 0.08),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: w * 0.04),
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: _isLoading ? null : _handleSignIn,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Inicio',
                              style: TextStyle(
                                fontSize: buttonFont,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: w * 0.08),

                  Text(
                    'O continúa con',
                    style: TextStyle(fontSize: smallText, color: Colors.grey),
                  ),

                  SizedBox(height: w * 0.06),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.g_mobiledata, size: w * 0.12),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login con Google pendiente')),
                          );
                        },
                      ),
                      SizedBox(width: w * 0.1),
                      IconButton(
                        icon: Icon(Icons.facebook, size: w * 0.1, color: Colors.blue),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login con Facebook pendiente')),
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: w * 0.1),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿No tienes una cuenta? ',
                        style: TextStyle(fontSize: smallText, color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          'Crea una.',
                          style: TextStyle(
                            fontSize: smallText,
                            color: primaryColor.darker,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: w * 0.05),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: w * 0.04),
                        side: BorderSide(color: primaryColor.darker),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _mostrarVentanaInvitado(context),
                      child: Text(
                        'Continuar como invitado',
                        style: TextStyle(
                          fontSize: buttonFont,
                          color: primaryColor.darker,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
