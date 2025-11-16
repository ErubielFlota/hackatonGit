import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/autentificacion.dart';
// import 'package:cloud_functions/cloud_functions.dart'; // Ya no se necesita
import 'package:http/http.dart' as http; // NUEVA IMPORTACIÓN
import 'dart:convert'; // NUEVA IMPORTACIÓN

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

  // <--- CORRECIÓN 1: Nombre de variable corregido (era _isLonading)
  //este sirve para ver si esta cargando o no
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
    // <--- CORRECIÓN 2: Lógica de carga implementada con try...finally
    if (_isLoading) return; //si ya esta cargando, no hacer nada
    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 1. Validación de campos
      if (programaSeleccionado == null ||
          mensajeController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, complete todos los campos.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return; // El 'finally' se ejecutará de todos modos
      }
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No se encontró el usuario.')),
        );
        return; // El 'finally' se ejecutará de todos modos
      }

      String nombreCompleto = 'Usuario'; // Valor por defecto

      // Este try/catch interno es para el nombre, está bien
      try {
        final String uid = user.uid;
        // 2. OBTENER EL NOMBRE COMPLETO DESDE FIRESTORE (¡AHORA CORREGIDO!)
        try {
          // Usamos los nombres correctos
          const String nombreColeccion = 'usuarios_registrados';
          const String campoNombre = 'nombres';
          const String campoApellidos = 'apellidos';

          final docSnap =
              await _firestore.collection(nombreColeccion).doc(uid).get();

          if (docSnap.exists) {
            final data = docSnap.data() as Map<String, dynamic>;

            final String nombreFirestore = data[campoNombre] ?? '';
            final String apellidosFirestore = data[campoApellidos] ?? '';

            nombreCompleto = '$nombreFirestore $apellidosFirestore'.trim();
          }

          // Fallback por si acaso
          if (nombreCompleto.isEmpty) {
            nombreCompleto = user.displayName ?? 'Usuario';
          }
        } catch (e) {
          debugPrint('Error al leer nombre de Firestore: $e');
          nombreCompleto = user.displayName ?? 'Usuario'; // Usar fallback
        }

        // 3. Guardar en Firestore
        await _firestore.collection('sugerencias_quejas').add({
          'nombre': nombreCompleto, // <-- Se usa la nueva variable
          'correo': user.email ?? 'Desconocido',
          'uid': uid,
          'programa': programaSeleccionado,
          'tipo': tipoSeleccionado,
          'mensaje': mensajeController.text.trim(),
          'fecha': Timestamp.now(),
        });

        // 4. Enviar correo usando EmailJS
        try {
          const serviceId = 'service_1ndjsyp';
          const templateId = 'template_7gxqncc';
          const publicKey = 'g1sUydGApinepfy8J';

          final url =
              Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
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
              'template_params': {
                'to_name': 'Administrador',
                'from_name': nombreCompleto, // <-- Se usa la nueva variable
                'message': mensajeController.text.trim(),
                'reply_to': user.email ?? 'Desconocido',
                'programa': programaSeleccionado,
                'tipo': tipoSeleccionado,
              }
            }),
          );

          if (response.statusCode == 200) {
            debugPrint('Correo enviado correctamente');
          } else {
            debugPrint('Error al enviar correo: ${response.body}');
          }
        } catch (emailError) {
          debugPrint('No se pudo enviar el correo: $emailError');
        }

        // 5. Mostrar confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mensaje enviado correctamente')),
        );

        mensajeController.clear();
        setState(() {
          tipoSeleccionado = 'Queja';
          programaSeleccionado = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar: $e')),
        );
      }
    } finally {
      // <--- CORRECIÓN 2:
      // Esto se ejecutará SIEMPRE, no importa si hubo éxito o error.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...
    // EL RESTO DE TU CÓDIGO (LA INTERFAZ DE USUARIO) VA AQUÍ
    // No es necesario cambiar nada en la función build()
    // ...
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          automaticallyImplyLeading: false,
          title: const Text(
            "Quejas y Sugerencias",
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
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
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Si está logueado, mostramos solo los campos importantes
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Quejas y Sugerencias',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // ... (dentro de Column)
              children: [
                // ESTO LO AGREGUE COMO COMETARIO PARA QUE NO SE VEA EL "USUARIO:ASDGASGDFGRA@GMAIL.COM"
                /* <-- AÑADE ESTO 
                Text(
                  'Usuario: ${user.email}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Divider(height: 20, thickness: 1),
                  <-- Y AÑADE ESTO */

                const Text('Programa del gobierno:', // ...
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  hint: const Text('Selecciona un programa'),
                  initialValue: programaSeleccionado,
                  items: programas
                      .map((programa) => DropdownMenuItem(
                          value: programa, child: Text(programa)))
                      .toList(),
                  onChanged: (value) =>
                      setState(() => programaSeleccionado = value),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Tipo:', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Queja'),
                        value: 'Queja',
                        groupValue: tipoSeleccionado,
                        activeColor: Colors.lightBlueAccent,
                        onChanged: (value) =>
                            setState(() => tipoSeleccionado = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Sugerencia'),
                        value: 'Sugerencia',
                        groupValue: tipoSeleccionado,
                        activeColor: Colors.lightBlueAccent,
                        onChanged: (value) =>
                            setState(() => tipoSeleccionado = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Mensaje:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: mensajeController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ingrese su mensaje',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  // <--- CORRECIÓN 3: El botón ahora reacciona a _isLoading
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : enviarMensaje,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'Enviar',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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