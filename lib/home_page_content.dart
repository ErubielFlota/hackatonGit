import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tenerlo en pubspec.yaml

// MODELO DE PROGRAMA
class Programa {
  final String nombre;
  final DateTime inicio;
  final DateTime fin;

  Programa({
    required this.nombre,
    required this.inicio,
    required this.fin,
  });

  // Determinar estado según fechas
  String estadoActual() {
    final ahora = DateTime.now();
    if (ahora.isBefore(inicio)) return 'Próximamente';
    if (ahora.isAfter(fin)) return 'Finalizado';
    return 'Activo';
  }
}

// PÁGINA PRINCIPAL
class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  String filtro = '';

  // Lista de programas con fechas simuladas
  final List<Programa> programas = [
    Programa(
      nombre: 'Beca universal de educación MEDIA SUPERIOR',
      inicio: DateTime(2025, 1, 1),
      fin: DateTime(2025, 12, 31),
    ),
    Programa(
      nombre: 'Beca educación SUPERIOR: JÓVENES ESCRIBIENDO EL FUTURO',
      inicio: DateTime(2025, 12, 15),
      fin: DateTime(2026, 6, 30),
    ),
    Programa(
      nombre: 'Beca universal de educación MEDIA SUPERIOR (anterior)',
      inicio: DateTime(2023, 1, 1),
      fin: DateTime(2023, 12, 31),
    ),
  ];

  // Filtrado dinámico
  List<Programa> get programasFiltrados => programas
      .where((p) => p.nombre.toLowerCase().contains(filtro.toLowerCase()))
      .toList();

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
              // 🟦 Título principal
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

              // 🔍 Barra de búsqueda moderna
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

              // 🧩 Lista de programas animada
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: programasFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            'No se encontraron programas.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          key: ValueKey(filtro),
                          itemCount: programasFiltrados.length,
                          itemBuilder: (context, index) {
                            final programa = programasFiltrados[index];
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: ProgramaCard(programa: programa),
                            );
                          },
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

// TARJETA INDIVIDUAL DE PROGRAMA
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
      _ => 'No disponible',
    };

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // 🖼️ Placeholder temporal (sin imagen aún)
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Colors.grey,
                size: 40,
              ),
            ),
            const SizedBox(width: 12),

            // 🧾 Texto + burbuja de estado
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
          ],
        ),
      ),
    );
  }
}



