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
  
  // Estado del formulario
  String tipoSeleccionado = 'Queja';
  
  // Gestión de Categorías y Programas
  String categoriaSeleccionada = 'Comentario general';
  String? programaSeleccionado;
  List<String> listaProgramas = ['General'];
  bool _isLoadingProgramas = false;

  bool _isLoading = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> categorias = [
    'Comentario general',
    'Programa Social',
    'Servicio',
    'Trámite',
  ];

  @override
  void initState() {
    super.initState();
    _actualizarListaProgramas();
  }

  Future<void> _actualizarListaProgramas() async {
    setState(() {
      _isLoadingProgramas = true;
      programaSeleccionado = null; 
    });

    List<String> nuevosProgramas = [];

    try {
      if (categoriaSeleccionada == 'Comentario general') {
        nuevosProgramas = ['General'];
        programaSeleccionado = 'General';
      } else {
        String categoriaBusqueda = categoriaSeleccionada;
        if (categoriaSeleccionada == 'Trámites') {
          categoriaBusqueda = 'Tramites'; 
        }

        final querySnapshot = await _firestore
            .collection('programas_sociales')
            .where('programas', isEqualTo: categoriaBusqueda)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          nuevosProgramas = querySnapshot.docs
              .map((doc) => doc['nombre_programa'].toString())
              .toList();
          nuevosProgramas.sort();
        } else {
          nuevosProgramas = ['No hay opciones disponibles'];
        }
      }
    } catch (e) {
      debugPrint('Error cargando programas: $e');
      nuevosProgramas = ['Error al cargar lista'];
    } finally {
      if (mounted) {
        setState(() {
          listaProgramas = nuevosProgramas;
          _isLoadingProgramas = false;
        });
      }
    }
  }

  Future<void> enviarMensaje() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (programaSeleccionado == null || 
          programaSeleccionado == 'No hay opciones disponibles' ||
          mensajeController.text.trim().isEmpty) {
        throw Exception("Por favor completa todos los campos.");
      }

      if (user == null) {
        throw Exception("No hay usuario autenticado.");
      }

      // 1. Obtener datos del usuario
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

      // 2. Guardar en Firebase
      await _firestore.collection('sugerencias_quejas').add({
        'nombre': nombreCompleto,
        'correo': user.email ?? 'Desconocido',
        'uid': user.uid,
        'categoria': categoriaSeleccionada,
        'programa': programaSeleccionado,
        'tipo': tipoSeleccionado,
        'mensaje': mensajeController.text.trim(),
        'fecha': Timestamp.now(),
      });

      // 3. Enviar Email (EmailJS) con PRIVATE KEY
      const serviceId = 'service_1ndjsyp';
      const templateId = 'template_7gxqncc'; 
      const publicKey = 'g1sUydGApinepfy8J';
      
      // ¡IMPORTANTE! PEGA AQUÍ TU PRIVATE KEY QUE COPIASTE DEL DASHBOARD
      const privateKey = 'ebqMNzpNXVAxcAxstNzfD'; 

      final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
      
      final response = await http.post(
        url,
        headers: {
          'origin': 'http://localhost',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'accessToken': privateKey, // <--- ESTO ES LO QUE FALTABA
          'template_params': {
            'to_name': 'Administrador',
            'to_email': 'bogar.asis73@gmail.com',
            'from_name': nombreCompleto,
            'message': mensajeController.text.trim(),
            'reply_to': user.email ?? 'Desconocido',
            'categoria': categoriaSeleccionada,
            'programa': programaSeleccionado,
            'tipo': tipoSeleccionado,
          }
        }),
      );

      // VERIFICAR RESPUESTA DE EMAILJS
      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Mensaje enviado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        mensajeController.clear();
        setState(() {
          tipoSeleccionado = 'Queja';
          categoriaSeleccionada = 'Comentario general';
          _actualizarListaProgramas();
        });

      } else {
        debugPrint('EmailJS Error: ${response.body}');
        throw Exception('Error enviando correo: ${response.body}');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    backgroundColor: primaryColor,
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

                  // ===== CATEGORÍA =====
                  Text('Categoría:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontBase)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: categoriaSeleccionada,
                        items: categorias.map((String categoria) {
                          return DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null && newValue != categoriaSeleccionada) {
                            setState(() {
                              categoriaSeleccionada = newValue;
                            });
                            _actualizarListaProgramas();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ===== SELECCIÓN ESPECÍFICA =====
                  Text(
                    categoriaSeleccionada == 'Comentario general' 
                        ? 'Asunto:'
                        : 'Selecciona el ${categoriaSeleccionada.toLowerCase().substring(0, categoriaSeleccionada.length - 1)}:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontBase),
                  ),
                  const SizedBox(height: 8),

                  _isLoadingProgramas
                      ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: const Text('Selecciona una opción'),
                              value: programaSeleccionado,
                              items: listaProgramas.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(item, overflow: TextOverflow.ellipsis),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  programaSeleccionado = newValue;
                                });
                              },
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  // ===== TIPO =====
                  Text('Tipo de mensaje:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontBase)),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Queja', style: TextStyle(fontSize: fontBase)),
                          value: 'Queja',
                          groupValue: tipoSeleccionado,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setState(() => tipoSeleccionado = v!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: Text('Sugerencia', style: TextStyle(fontSize: fontBase)),
                          value: 'Sugerencia',
                          groupValue: tipoSeleccionado,
                          contentPadding: EdgeInsets.zero,
                          onChanged: (v) => setState(() => tipoSeleccionado = v!),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // ===== MENSAJE =====
                  Text('Mensaje:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontBase)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: mensajeController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí tu comentario detallado...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ===== BOTÓN ENVIAR =====
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : enviarMensaje,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                          : Text('Enviar Reporte', style: TextStyle(fontSize: fontBase, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}