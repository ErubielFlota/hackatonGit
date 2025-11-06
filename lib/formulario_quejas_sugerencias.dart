import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FormularioQuejasSugerenciasPage extends StatefulWidget {
  const FormularioQuejasSugerenciasPage({super.key});

  @override
  State<FormularioQuejasSugerenciasPage> createState() => _FormularioQuejasSugerenciasPageState();
}

class _FormularioQuejasSugerenciasPageState extends State<FormularioQuejasSugerenciasPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController apellidosController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final TextEditingController mensajeController = TextEditingController();

  String tipoSeleccionado = 'Queja';
  String? programaSeleccionado;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> programas = [
    'Becas Benito Juárez',
    'Pensión Adultos Mayores',
    'Jóvenes Construyendo el Futuro',
    'Sembrando Vida',
    'La Escuela es Nuestra',
    'IMSS Bienestar',
  ];

  Future<void> enviarMensaje() async {
    final String nombre = nombreController.text.trim();
    final String apellidos = apellidosController.text.trim();
    final String correo = correoController.text.trim();
    final String mensaje = mensajeController.text.trim();

    if (nombre.isEmpty || apellidos.isEmpty || correo.isEmpty || programaSeleccionado == null || mensaje.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, complete todos los campos.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      await _firestore.collection('sugerencias_quejas').add({
        'nombre': nombre,
        'apellidos': apellidos,
        'correo': correo,
        'programa': programaSeleccionado,
        'tipo': tipoSeleccionado,
        'mensaje': mensaje,
        'fecha': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mensaje enviado correctamente')),
      );

      // Limpia los campos
      nombreController.clear();
      apellidosController.clear();
      correoController.clear();
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
  }

  @override
  Widget build(BuildContext context) {
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
              children: [
                const Text('Nombre(s):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Apellidos:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: apellidosController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tus apellidos',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Correo electrónico:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu correo',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Programa del gobierno:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: programaSeleccionado,
                  hint: const Text('Selecciona un programa'),
                  items: programas.map((programa) {
                    return DropdownMenuItem(value: programa, child: Text(programa));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      programaSeleccionado = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                        onChanged: (value) => setState(() => tipoSeleccionado = value!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text('Sugerencia'),
                        value: 'Sugerencia',
                        groupValue: tipoSeleccionado,
                        activeColor: Colors.lightBlueAccent,
                        onChanged: (value) => setState(() => tipoSeleccionado = value!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Mensaje:', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: mensajeController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Ingrese su mensaje',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: enviarMensaje,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
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
