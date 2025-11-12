
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/theme/colors.dart'; 


class Programa {
  final String id;
  final String nombre;
  final String imagenUrl;
  final String descripcion;
  final DateTime inicio;
  final DateTime fin;
  final String localidad;
  final String categoria;

  final String objetivo;
  final String dependencia;
  final String poblacionObjetivo;
  final List<String> requisitos;
  final List<String> pasosRegistro;
  final List<String> documentacionNecesaria;
  final String zonaAplicacion;
  final String telefonoContacto;
  final String correoContacto;
  final String imagenReferencia;
  final String enlaceOficial;

  Programa({
    required this.id,
    required this.nombre,
    required this.imagenUrl,
    required this.descripcion,
    required this.inicio,
    required this.fin,
    required this.localidad,
    required this.categoria,
    required this.objetivo,
    required this.dependencia,
    required this.poblacionObjetivo,
    required this.requisitos,
    required this.pasosRegistro,
    required this.documentacionNecesaria,
    required this.zonaAplicacion,
    required this.telefonoContacto,
    required this.correoContacto,
    required this.imagenReferencia,
    required this.enlaceOficial,
  });

  factory Programa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) throw Exception("Documento sin datos.");

    final inicioTimestamp = data['inicio'] as Timestamp?;
    final finTimestamp = data['fin'] as Timestamp?;

    return Programa(
      // --- Campos existentes ---
      id: doc.id,
      nombre: data['titulo'] ?? 'Programa sin nombre',
      descripcion: data['descripcion'] ?? 'Sin descripción.',
      imagenUrl: data['imagenUrl'] ??
          'https://placehold.co/70x70/223399/FFFFFF?text=P',
      inicio: inicioTimestamp?.toDate() ?? DateTime.now(),
      fin: finTimestamp?.toDate() ??
          DateTime.now().add(const Duration(days: 365)),
      localidad: data['localidad'] ?? 'Todas las localidades',
      categoria: data['categoria'] ?? 'Sin Categoría',

      // --- Campos nuevos leídos desde Firebase ---
      objetivo: data['objetivo'] ?? 'Sin objetivo',
      dependencia: data['dependencia'] ?? 'No especificada',
      poblacionObjetivo: data['poblacionObjetivo'] ?? 'Población general',
      requisitos: List<String>.from(data['requisitos'] ?? []),
      pasosRegistro: List<String>.from(data['pasosRegistro'] ?? []),
      documentacionNecesaria:
          List<String>.from(data['documentacionNecesaria'] ?? []),
      zonaAplicacion: data['zonaAplicacion'] ?? 'No especificada',
      telefonoContacto: data['telefonoContacto'] ?? 'No disponible',
      correoContacto: data['correoContacto'] ?? 'No disponible',
      imagenReferencia: data['imagenReferencia'] ?? '',
      enlaceOficial: data['enlaceOficial'] ?? '',
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


  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo lanzar $urlString');
    }
  }

 
  Widget _buildListSection(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: colors.secondary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: colors.onSurface),
                    ),
                  ),
                ],
              ),
            )),
        const Divider(height: 20, thickness: 0.5),
      ],
    );
  }

  
  Widget _buildInfoTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    
    if (subtitle.isEmpty ||
        subtitle == 'No disponible' ||
        subtitle == 'No especificada' ||
        subtitle == 'Sin objetivo' ||
        subtitle == 'Población general') {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: colors.onSurface),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: colors.onSurface, fontSize: 16),
      ),
      onTap: onTap,
      trailing: onTap != null
          ? Icon(Icons.open_in_new_rounded,
              size: 18, color: colors.outline)
          : null,
    );
  }

  
  Widget _buildExpansionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colors = Theme.of(context).colorScheme;

    // Filtra los widgets "vacíos" (SizedBox.shrink)
    final validChildren = children
        .where((child) => !(child is SizedBox && child.height == 0.0))
        .toList();

    // Si no hay NINGÚN widget con contenido, no muestra la tarjeta
    if (validChildren.isEmpty) {
      return const SizedBox.shrink();
    }

    // Si hay contenido, crea la tarjeta expandible
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
            fontSize: 17,
          ),
        ),
        backgroundColor: colors.surfaceContainerLowest.withOpacity(0.5),
        iconColor: colors.primary, 
        collapsedIconColor: colors.onSurfaceVariant, 

       
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              
              children: validChildren,
            ),
          ),
        ],
      ),
    );
  }
  

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(programa.nombre),
        backgroundColor: colors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // INFORMACIÓN ESTÁTICA (VISIBLE) La parte de arriba de la info de programas
            

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
                    color: colors.surfaceContainerHighest,
                    child: Center(
                      child: Icon(Icons.error,
                          size: 40, color: colors.onSurfaceVariant),
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
                  color: colors.secondaryContainer,
                  border: Border.all(color: colors.secondary),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  programa.estadoActual(),
                  style: TextStyle(
                    color: colors.onSecondaryContainer,
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
                    color: colors.onSurface,
                  ),
            ),
            const Divider(height: 30, thickness: 1),

            Text(
              'Detalles del Programa:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              programa.descripcion,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 20),

            // Localidad y Categoría fijos
            _buildInfoTile(
              context,
              title: 'Localidad',
              subtitle: programa.localidad,
              icon: Icons.location_on,
            ),
            _buildInfoTile(
              context,
              title: 'Categoría',
              subtitle: programa.categoria,
              icon: Icons.label,
            ),

            const Divider(height: 30, thickness: 1),

            
            //  INFORMACIÓN EXPANDIBLE
           

            // Información Adicional ---
            _buildExpansionCard(
              context,
              title: 'Información Adicional',
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                  context,
                  title: 'Objetivo',
                  subtitle: programa.objetivo,
                  icon: Icons.track_changes,
                ),
                _buildInfoTile(
                  context,
                  title: 'Dependencia',
                  subtitle: programa.dependencia,
                  icon: Icons.account_balance,
                ),
                _buildInfoTile(
                  context,
                  title: 'Población Objetivo',
                  subtitle: programa.poblacionObjetivo,
                  icon: Icons.group,
                ),
                _buildInfoTile(
                  context,
                  title: 'Zona de Aplicación',
                  subtitle: programa.zonaAplicacion,
                  icon: Icons.public,
                ),
              ],
            ),

            // Proceso de Registro ---
            _buildExpansionCard(
              context,
              title: 'Información de registro',
              icon: Icons.how_to_reg_outlined,
              children: [
                _buildListSection(
                  context,
                  title: 'Requisitos', // El título ahora se usa internamente
                  items: programa.requisitos,
                  icon: Icons.check_box_outline_blank_rounded,
                ),
                _buildListSection(
                  context,
                  title: 'Pasos de Registro',
                  items: programa.pasosRegistro,
                  icon: Icons.format_list_numbered_rounded,
                ),
                _buildListSection(
                  context,
                  title: 'Documentación Necesaria',
                  items: programa.documentacionNecesaria,
                  icon: Icons.description_outlined,
                ),
              ],
            ),

            //  Contacto y Enlaces ---
            _buildExpansionCard(
              context,
              title: 'Contacto y Enlaces',
              icon: Icons.contact_page_outlined,
              children: [
                _buildInfoTile(
                  context,
                  title: 'Teléfono de Contacto',
                  subtitle: programa.telefonoContacto,
                  icon: Icons.phone_outlined,
                  onTap: () => _launchUrl('tel:${programa.telefonoContacto}'),
                ),
                _buildInfoTile(
                  context,
                  title: 'Correo de Contacto',
                  subtitle: programa.correoContacto,
                  icon: Icons.email_outlined,
                  onTap: () => _launchUrl('mailto:${programa.correoContacto}'),
                ),
                _buildInfoTile(
                  context,
                  title: 'Enlace Oficial',
                  subtitle: programa.enlaceOficial,
                  icon: Icons.link_rounded,
                  onTap: () => _launchUrl(programa.enlaceOficial),
                ),
              ],
            ),

            // ---  Imagen de Referencia ---
            // 
            _buildExpansionCard(
              context,
              title: 'Imagen de Referencia',
              icon: Icons.image_outlined,
              children: [
                
                if (programa.imagenReferencia.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      programa.imagenReferencia,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: double.infinity,
                        height: 150,
                        color: colors.surfaceContainerHighest,
                        child: Icon(Icons.image_not_supported,
                            color: colors.onSurfaceVariant),
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),

            const SizedBox(height: 30),
            Text('Inicia: ${programa.inicio.toString().split(' ')[0]}',
                style: TextStyle(color: colors.outline)),
            Text('Finaliza: ${programa.fin.toString().split(' ')[0]}',
                style: TextStyle(color: colors.outline)),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
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
                        color: primaryColor
                            .darker, // Asumo que primaryColor está en tu theme
                      ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Busque un programa en específico',
                  prefixIcon: Icon(Icons.search, color: colors.primary),
                  filled: true,
                  fillColor: primaryColor.lighter
                      .withOpacity(0.3), // Asumo que primaryColor está en tu theme
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _localidadSeleccionada,
                    icon:
                        Icon(Icons.arrow_drop_down, color: colors.onSurface),
                    style: TextStyle(color: colors.onSurface, fontSize: 16),
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
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _programasCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}',
                            style: TextStyle(color: colors.error)),
                      );
                    }
                    final allPrograms = snapshot.data!.docs
                        .map((doc) => Programa.fromFirestore(doc))
                        .toList();
                    final programasFiltrados = allPrograms.where((p) {
                      final filtroNombre =
                          p.nombre.toLowerCase().contains(filtro.toLowerCase());
                      final filtroLocalidad =
                          _localidadSeleccionada == _localidadesDisponibles.first
                              ? true
                              : p.localidad == _localidadSeleccionada;
                      return filtroNombre && filtroLocalidad;
                    }).toList();
                    if (programasFiltrados.isEmpty) {
                      return Center(
                        child: Text(
                          'No se encontraron programas.',
                          style: TextStyle(color: colors.onSurfaceVariant),
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
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProgramaDetailPage(programa: programa),
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


class ProgramaCard extends StatelessWidget {
  final Programa programa;
  const ProgramaCard({super.key, required this.programa});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final estado = programa.estadoActual();

    final colorEstado = switch (estado) {
      'Activo' => colors.primary,
      'Próximamente' => colors.secondary,
      _ => colors.error,
    };

    return Card(
      elevation: 2,
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
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: colors.surfaceContainerHighest,
                  child: Icon(Icons.image_not_supported,
                      color: colors.onSurfaceVariant, size: 40),
                ),
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
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programa.localidad,
                          style:
                              TextStyle(fontSize: 13, color: colors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.label_outline,
                          size: 14, color: colors.secondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programa.categoria,
                          style:
                              TextStyle(fontSize: 13, color: colors.onSurface),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      border: Border.all(color: colorEstado),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    child: Text(
                      estado,
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}