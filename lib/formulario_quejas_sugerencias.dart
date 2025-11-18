import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/autentificacion.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/colors.dart';

class FormularioQuejasSugerenciasPage extends StatefulWidget {
  const FormularioQuejasSugerenciasPage({super.key});

  @override
  State<FormularioQuejasSugerenciasPage> createState() =>
      _FormularioQuejasSugerenciasPageState();
}

class _FormularioQuejasSugerenciasPageState
    extends State<FormularioQuejasSugerenciasPage> {
  final TextEditingController mensajeController = TextEditingController();
  String tipoSeleccionado = 'Queja';
  String? programaSeleccionado;

  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> programas = [
    'General',
    'Pensión Mujeres Bienestar',
    'Beca Universal de Educación Básica Rita Cetina',
    'Salud Casa por Casa',
    'Pensión para el Bienestar de las Personas Adultas Mayores',
    'Pensión para el Bienestar de las Personas con Discapacidad',
    'Personas para el Bienestar de Niñas y Niños Hijos de Madres Trabajadoras',
    'Beca Universal de Educación Media Superior Benito Juárez',
    'Beca de educación superior Jóvenes Escribiendo el Futuro',
    'La Escuela es Nuestra',
    'Jóvenes Construyendo el Futuro',
    'Sembrando Vida',
    'Producción para el Bienestar',
    'Bienpesca',
    'Fertilizantes para el Bienestar',
    'Cosechando Soberanía',
    'Precios de Garantía',
    'Programa de Mejoramiento de Vivienda para el Bienestar',
    'Programa para el Bienestar',
  ];

  Future<void> enviarMensaje() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (programaSeleccionado == null || mensajeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, complete todos los campos.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se encontró el usuario.')),
        );
        return;
      }

      String nombreCompleto = 'Usuario';

      try {
        final docSnap = await _firestore
            .collection('usuarios_registrados')
            .doc(user.uid)
            .get();

        if (docSnap.exists) {
          final data = docSnap.data()!;
          nombreCompleto = '${data['nombres']} ${data['apellidos']}'.trim();
        }

        if (nombreCompleto.isEmpty) {
          nombreCompleto = user.displayName ?? "Usuario";
        }
      } catch (_) {}

      await _firestore.collection('sugerencias_quejas').add({
        'nombre': nombreCompleto,
        'correo': user.email ?? 'Desconocido',
        'uid': user.uid,
        'programa': programaSeleccionado,
        'tipo': tipoSeleccionado,
        'mensaje': mensajeController.text.trim(),
        'fecha': Timestamp.now(),
      });

      try {
        const serviceId = 'service_1ndjsyp';
        const templateId = 'template_7gxqncc';
        const publicKey = 'g1sUydGApinepfy8J';

        final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
        await http.post(
          url,
          headers: {
            'origin': 'http://localhost',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'service_id': serviceId,
            'template_id': templateId,
            'user_id': publicKey,
            'template_params': {
              'to_name': 'Administrador',
              'from_name': nombreCompleto,
              'message': mensajeController.text.trim(),
              'reply_to': user.email ?? 'Desconocido',
              'programa': programaSeleccionado,
              'tipo': tipoSeleccionado,
            }
          }),
        );
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado correctamente')),
      );

      mensajeController.clear();
      setState(() {
        tipoSeleccionado = 'Queja';
        programaSeleccionado = null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLarge = screenWidth > 600;
    final double maxContentWidth = 500;
    final double padding = isLarge ? 32 : 20;
    final double fontBase = isLarge ? 18 : 15;

    // Usuario no logueado
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Quejas y Sugerencias',
            style: TextStyle(
              color: primaryColor.darker,
              fontWeight: FontWeight.bold,
              fontSize: fontBase + 3,
            ),
          ),
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Debes iniciar sesión para acceder a esta página.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontBase + 1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Autentificacion()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: fontBase + 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Pantalla principal
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Quejas y Sugerencias',
          style: TextStyle(
            color: primaryColor.darker,
            fontWeight: FontWeight.bold,
            fontSize: fontBase + 3,
          ),
        ),
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ===== PROGRAMA DEL GOBIERNO =====
                  Text(
                    'Programa del gobierno:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontBase,
                    ),
                  ),
                  const SizedBox(height: 8),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        width: constraints.maxWidth,
                        child: DropdownButtonFormField<String>(
                          hint: const Text('Selecciona el programa'),
                          value: programaSeleccionado,
                          items: programas
                              .map((p) => DropdownMenuItem(
                                    value: p,
                                    child: Text(
                                      p,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => programaSeleccionado = value),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  // ===== TIPO =====
                  Text(
                    'Tipo:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontBase,
                    ),
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Queja', style: TextStyle(fontSize: fontBase)),
                          value: 'Queja',
                          groupValue: tipoSeleccionado,
                          onChanged: (v) => setState(() => tipoSeleccionado = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title:
                              Text('Sugerencia', style: TextStyle(fontSize: fontBase)),
                          value: 'Sugerencia',
                          groupValue: tipoSeleccionado,
                          onChanged: (v) => setState(() => tipoSeleccionado = v!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ===== MENSAJE =====
                  Text(
                    'Mensaje:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontBase,
                    ),
                  ),

                  TextField(
                    controller: mensajeController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Ingrese su mensaje',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : enviarMensaje,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              'Enviar',
                              style: TextStyle(
                                fontSize: fontBase,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

