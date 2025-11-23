import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/colors.dart';

// Importamos los componentes reutilizables (Modelo, Tarjeta, Detalle)
// Ocultamos PrincipalPage para usar nuestra propia clase
import 'package:prueba2app/home_page_content.dart' hide PrincipalPage;

class ProgramasSocialesPage extends StatefulWidget {
  const ProgramasSocialesPage({super.key});

  @override
  State<ProgramasSocialesPage> createState() => _ProgramasSocialesPageState();
}

class _ProgramasSocialesPageState extends State<ProgramasSocialesPage> {
  String _filtroBusqueda = '';

  // FILTRO ESPECÍFICO: "Programas sociales"
  final Query _consulta = FirebaseFirestore.instance
      .collection('programas_sociales')
      .where('programas', isEqualTo: 'Programa Social');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Programas Sociales',
          style: TextStyle(color: primaryColor.darker, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryColor.darker),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Buscador Local
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar programas...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                ),
                onChanged: (val) => setState(() => _filtroBusqueda = val.toLowerCase()),
              ),
              const SizedBox(height: 16),
              
              // Lista Filtrada
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _consulta.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No hay programas sociales registrados.'));
                    }

                    final lista = snapshot.data!.docs.map((doc) {
                      try { return Programa.fromFirestore(doc); } catch (_) { return null; }
                    }).whereType<Programa>()
                      .where((p) => p.nombre.toLowerCase().contains(_filtroBusqueda))
                      .toList();

                    if (lista.isEmpty) return const Center(child: Text('No se encontraron resultados.'));

                    return ListView.builder(
                      itemCount: lista.length,
                      itemBuilder: (ctx, i) => InkWell(
                        onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => ProgramaDetailPage(programa: lista[i]))),
                        child: ProgramaCard(programa: lista[i]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}