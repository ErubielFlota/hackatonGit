import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/home_page_content.dart'; 


class ViviendaPage extends StatefulWidget { 
  const ViviendaPage({super.key});

  @override
  State<ViviendaPage> createState() => _ViviendaPageState();
}

class _ViviendaPageState extends State<ViviendaPage> {
  
  String filtro = '';
  final Query _programasFiltradosQuery =
      FirebaseFirestore.instance
          .collection('programas')
          .where('categoria', isEqualTo: 'Vivienda');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Programas de Vivienda'), 
        backgroundColor: Colors.brown,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              TextField(
                decoration: InputDecoration(
                  hintText: 'Busque un programa en específico',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (query) {
                  
                  setState(() => filtro = query);
                },
              ),
              const SizedBox(height: 16),
              
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _programasFiltradosQuery.snapshots(), 
                  builder: (context, snapshot) {
                    
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                      );
                    }
                  
                    final allPrograms = snapshot.data!.docs
                        .map((doc) => Programa.fromFirestore(doc))
                        .toList();
                    
                    
                    final programasFiltrados = allPrograms
                        .where((p) => p.nombre.toLowerCase().contains(filtro.toLowerCase()))
                        .toList();

                    
                    if (programasFiltrados.isEmpty) {
                      return Center(
                        child: Text(
                          filtro.isEmpty
                          ? 'No hay programas activos en la categoría Vivienda.' 
                          : 'No se encontraron programas con ese nombre.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      key: ValueKey(filtro),
                      child: ListView.builder(
                        itemCount: programasFiltrados.length,
                        itemBuilder: (context, index) {
                          final programa = programasFiltrados[index];
                          
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProgramaDetailPage(programa: programa), 
                                ),
                              );
                            },
                            child: ProgramaCard(programa: programa),
                          );
                        },
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
