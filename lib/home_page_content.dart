import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class Programa {
  final String id; 
  final String nombre;
  final String imagenUrl; 
  final String descripcion;
  final DateTime inicio;
  final DateTime fin;
  final String localidad; 
  final String categoria; 

  Programa({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.localidad,
    required this.categoria, 
  });

  
  factory Programa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    
    if (data == null) {
      throw Exception("Documento de Firestore no contiene datos.");
    }

    
    final inicioTimestamp = data['inicio'] as Timestamp?;
    final finTimestamp = data['fin'] as Timestamp?;

    return Programa(
      id: doc.id,
      nombre: data['titulo'] ?? 'Programa sin nombre',
      descripcion: data['descripcion'] ?? 'Sin descripción.',
      imagenUrl: data['imagenUrl'] ?? 'https://placehold.co/70x70/223399/FFFFFF?text=P',
      inicio: inicioTimestamp?.toDate() ?? DateTime.now(),
      fin: finTimestamp?.toDate() ?? DateTime.now().add(const Duration(days: 365)),
      localidad: data['localidad'] ?? 'Todas las localidades',
      categoria: data['categoria'] ?? 'Sin Categoría',
    );
  }

  
  String estadoActual() {
    final ahora = DateTime.now();
    if (ahora.isBefore(inicio)) return 'Próximamente';
    if (ahora.isAfter(fin)) return 'Finalizado';
    return 'Activo';
  }
}


class ProgramaDetailPage extends StatelessWidget {
  final Programa programa;
  const ProgramaDetailPage({super.key, required this.programa});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(programa.nombre),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                programa.imagenUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.error, size: 40, color: Colors.blueGrey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                decoration: BoxDecoration(
                  color: (programa.estadoActual() == 'Activo' ? Colors.green : Colors.amber).withOpacity(0.15),
                  border: Border.all(color: programa.estadoActual() == 'Activo' ? Colors.green : Colors.amber),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  programa.estadoActual(),
                  style: TextStyle(
                    color: programa.estadoActual() == 'Activo' ? Colors.green : Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            Text(
              programa.nombre,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                    ),
            ),
            const Divider(height: 30, thickness: 1),

            
            const Text(
              'Detalles del Programa:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              programa.descripcion,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),

            const SizedBox(height: 20),
            
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on, color: Colors.blueAccent),
              title: Text('Localidad', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(programa.localidad, style: TextStyle(fontSize: 16)),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.label, color: Colors.indigo), 
              title: Text('Categoría', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(programa.categoria, style: TextStyle(fontSize: 16)),
            ),
            
            const SizedBox(height: 10),


            Text('Inicia: ${programa.inicio.toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
            Text('Finaliza: ${programa.fin.toString().split(' ')[0]}', style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}


const List<String> _localidadesDisponibles = [
  'Todas las Localidades', 
  'Othón P. Blanco',
  'Felipe Carrillo Puerto',
  'José María Morelos',
  'Cozumel',
  'Lázaro Cárdenas',
  'Benito Juárez',
  'Isla Mujeres',
  'Solidaridad',
  'Tulum',
  'Puerto Morelos',
  'Bacalar',
];

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  String filtro = '';
  String _localidadSeleccionada = _localidadesDisponibles.first; 
  
  final CollectionReference _programasCollection =
      FirebaseFirestore.instance.collection('programas');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Center(
                child: Text(
                  'Programas disponibles',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              
              // Barra de Búsqueda por Nombre
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
              
              // Selector de Localidad 
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _localidadSeleccionada,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
                    style: TextStyle(color: Colors.blueGrey[800], fontSize: 16),
                    onChanged: (String? newValue) {
                      setState(() {
                        _localidadSeleccionada = newValue!;
                      });
                    },
                    items: _localidadesDisponibles
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 16),


              
              // Lista de Programas 
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _programasCollection.snapshots(),
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
                        .where((p) {
                          
                          final filtroNombre = p.nombre.toLowerCase().contains(filtro.toLowerCase());

                          
                          final filtroLocalidad = _localidadSeleccionada == _localidadesDisponibles.first 
                              ? true 
                              : p.localidad == _localidadSeleccionada; 

                          return filtroNombre && filtroLocalidad;
                        })
                        .toList();

                    if (programasFiltrados.isEmpty) {
                      return const Center(
                        child: Text(
                          'No se encontraron programas con esos criterios.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      );
                    }

                    
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      key: ValueKey(filtro + _localidadSeleccionada), 
                      child: ListView.builder(
                        itemCount: programasFiltrados.length,
                        itemBuilder: (context, index) {
                          final programa = programasFiltrados[index];
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProgramaDetailPage(programa: programa),
                                  ),
                                );
                              },
                              child: ProgramaCard(programa: programa),
                            ),
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


class ProgramaCard extends StatelessWidget {
  final Programa programa;
  const ProgramaCard({super.key, required this.programa});

  @override
  Widget build(BuildContext context) {
    final estado = programa.estadoActual();
    final colorEstado = switch (estado) {
      'Activo' => Colors.green,
      'Próximamente' => Colors.amber,
      _ => Colors.red,
    };

    final etiqueta = switch (estado) {
      'Activo' => 'Activo',
      'Próximamente' => 'Próximamente',
      _ => 'Finalizado',
    };

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                programa.imagenUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  
                  return Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.image_not_supported,
                      color: Colors.grey,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programa.nombre,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.blueGrey[800],
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),

                 
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.blueGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programa.localidad,
                          style: TextStyle(fontSize: 13, color: Colors.blueGrey[700]),
                          overflow: TextOverflow.ellipsis, 
                        ),
                      ),
                    ],
                  ),
                 
                  Row(
                    children: [
                      const Icon(Icons.label_outline, size: 14, color: Colors.indigo),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programa.categoria,
                          style: TextStyle(fontSize: 13, color: Colors.indigo[700]),
                          overflow: TextOverflow.ellipsis, 
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 6),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorEstado.withOpacity(0.15),
                        border: Border.all(color: colorEstado),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      child: Text(
                        etiqueta,
                        style: TextStyle(
                          color: colorEstado,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey),
          ],
        ),
      ),
    );
  }
}


