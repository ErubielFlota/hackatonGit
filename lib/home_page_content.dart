import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/theme/colors.dart';

const Color kPrimaryColor = Color(0xFF6200EE);
const Color kBackgroundColor = Color(0xFFF5F5F5);

//    MODELO DE PROGRAMA SOCIAL

class Programa {
  final String id;
  final String nombre; 
  final String descripcion; 
  final String objetivo; 
  final String tipoObjetivo;
  
  final String institucionEncargada; 
  final String institucionAcronimo; 
  
  final String direccion;
  final String horariosAtencion; 
  final String telefonoContacto;
  final String correoContacto;
  final String redesSociales;
  final String enlaceModuloAtencion;
  final String regionAplicacion;
  
  final String tipoApoyo;
  final String costoServicio;
  final String modalidad; 
  final String poblacionObjetivo; 
  final String presupuesto; 
  final String categoria; 
  
  // Procesos
  final List<String> pasosSeguir; 
  final List<String> requisitos; 
  final List<String> documentosRequeridos; 
  final String fechasSolicitud; 
  final String periodosPago; 
  final bool requiereCita; 
  final String tiempoResolucion; 
  
  // Estado y Legal
  final String estadoActual; 
  final String descripcionIndicador; 
  final String fundamentosJuridicos; 

  // Imagen del programa
  final String imagenUrl; 

  Programa({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.objetivo,
    required this.tipoObjetivo,
    required this.institucionEncargada,
    required this.institucionAcronimo,
    required this.direccion,
    required this.horariosAtencion,
    required this.telefonoContacto,
    required this.correoContacto,
    required this.redesSociales,
    required this.enlaceModuloAtencion,
    required this.regionAplicacion,
    required this.tipoApoyo,
    required this.costoServicio,
    required this.modalidad,
    required this.poblacionObjetivo,
    required this.presupuesto,
    required this.categoria,
    required this.pasosSeguir,
    required this.requisitos,
    required this.documentosRequeridos,
    required this.fechasSolicitud,
    required this.periodosPago,
    required this.requiereCita,
    required this.tiempoResolucion,
    required this.estadoActual,
    required this.descripcionIndicador,
    required this.fundamentosJuridicos,
    required this.imagenUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'nombre_programa': nombre,
      'descripcion': descripcion,
      'objetivo': objetivo,
      'tipo_objetivo': tipoObjetivo,
      'institucion_encargada': institucionEncargada,
      'institucion_acronimo': institucionAcronimo,
      'dirección': direccion,
      'horarios_atencion': horariosAtencion,
      'telefono_contacto': telefonoContacto,
      'correo_contacto': correoContacto,
      'redes_sociales': redesSociales,
      'enlace_modulo_atencion': enlaceModuloAtencion,
      'zona_region_que_aplica': regionAplicacion,
      'tipo_apoyo': tipoApoyo,
      'costo_servicio': costoServicio,
      'modalidad': modalidad,
      'poblacion_objetivo': poblacionObjetivo,
      'presupuesto': presupuesto,
      'categoria_programa': categoria,
      'pasos_a_seguir': pasosSeguir,
      'requisitos': requisitos,
      'documentos_requeridos': documentosRequeridos,
      'fechas_solicitud': fechasSolicitud,
      'periodos_pago': periodosPago,
      'requiere_cita': requiereCita,
      'tiempo_resolucion': tiempoResolucion,
      'estado_actual_programa': estadoActual,
      'descripcion_indicador': descripcionIndicador,
      'fundamentos_juridicos': fundamentosJuridicos,
      'imagen_url': imagenUrl,
    };
  }

  factory Programa.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    if (data == null) throw Exception("Documento sin datos.");

    List<String> parseList(dynamic value) {
      if (value is List) {
        return List<String>.from(value.map((e) => e.toString()));
      } else if (value is String && value.isNotEmpty) {
        return [value]; 
      }
      return [];
    }

    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) {
        return value.toLowerCase().contains('sí') || value.toLowerCase() == 'si' || value.toLowerCase() == 'true';
      }
      return false;
    }

    return Programa(
      id: doc.id,
      nombre: data['nombre_programa'] ?? 'Programa sin nombre',
      descripcion: data['descripcion'] ?? 'Sin descripción disponible.',
      objetivo: data['objetivo'] ?? 'No especificado',
      tipoObjetivo: data['tipo_objetivo'] ?? 'General',
      institucionEncargada: data['institucion_encargada'] ?? 'Gobierno del Estado',
      institucionAcronimo: data['institucion_acronimo'] ?? 'GOB',
      direccion: data['dirección'] ?? 'No especificada',
      horariosAtencion: data['horarios_atencion'] ?? 'No especificado',
      telefonoContacto: data['telefono_contacto']?.toString() ?? 'No disponible',
      correoContacto: data['correo_contacto'] ?? 'No disponible',
      redesSociales: data['redes_sociales'] ?? '',
      enlaceModuloAtencion: data['enlace_modulo_atencion'] ?? '',
      regionAplicacion: data['zona_region_que_aplica'] ?? 'Estatal',
      tipoApoyo: data['tipo_apoyo'] ?? 'No especificado',
      costoServicio: data['costo_servicio'] ?? 'Gratuito',
      modalidad: data['modalidad'] ?? 'Presencial',
      poblacionObjetivo: data['poblacion_objetivo'] ?? 'Población General',
      presupuesto: data['presupuesto']?.toString() ?? 'No público',
      categoria: data['categoria_programa'] ?? 'Social',
      
      // Listas
      pasosSeguir: parseList(data['pasos_a_seguir']),
      requisitos: parseList(data['requisitos']),
      documentosRequeridos: parseList(data['documentos_requeridos']),
      
      fechasSolicitud: data['fechas_solicitud'] ?? 'Consultar convocatoria',
      periodosPago: data['periodos_pago'] ?? 'No aplica',
      requiereCita: parseBool(data['requiere_cita']),
      tiempoResolucion: data['tiempo_resolucion'] ?? 'Variable',
      
      estadoActual: data['estado_actual_programa'] ?? 'Activo',
      descripcionIndicador: data['descripcion_indicador'] ?? '',
      fundamentosJuridicos: data['fundamentos_juridicos'] ?? '',
      
      imagenUrl: data['imagen_url'] ?? 'https://placehold.co/600x400/223399/FFFFFF?text=Sin+Imagen',
    );
  }
}


//    PÁGINA DE DETALLES

class ProgramaDetailPage extends StatelessWidget {
  final Programa programa;
  const ProgramaDetailPage({super.key, required this.programa});

  Future<void> _launchUrl(String urlString) async {
    if (urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('No se pudo lanzar $urlString');
      }
    } catch (e) {
      debugPrint('Error lanzando URL: $e');
    }
  }

  Widget _buildListSection(BuildContext context,
      {required List<String> items, required IconData icon, required String title}) {
    if (items.isEmpty) return const SizedBox.shrink();

    final colors = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: colors.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            )),
        const Divider(height: 16),
      ],
    );
  }

  Widget _buildInfoTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      VoidCallback? onTap}) {
    if (subtitle.isEmpty ||
        subtitle.toLowerCase() == 'no disponible' ||
        subtitle.toLowerCase() == 'no especificada') {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: colors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
          fontSize: 14,
        ),
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
    final validChildren = children
        .where((child) => !(child is SizedBox && child.height == 0.0))
        .toList();

    if (validChildren.isEmpty) return const SizedBox.shrink();

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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final horizontalPadding = isWide ? 48.0 : 16.0;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          programa.institucionAcronimo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: kBackgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (programa.imagenUrl.isNotEmpty)
              Container(
                width: double.infinity,
                height: isWide ? 300 : 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                ),
                child: Image.network(
                  programa.imagenUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.image_not_supported, 
                        size: 50, color: Colors.grey[500]),
                    );
                  },
                ),
              ),

            Padding(
              padding: EdgeInsets.all(horizontalPadding),
              child: Column(
                children: [
                   const SizedBox(height: 20),

                   // Información Principal
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                programa.categoria,
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: programa.estadoActual.toLowerCase().contains('activo') 
                                  ? Colors.green.withOpacity(0.1) 
                                  : Colors.grey.withOpacity(0.1),
                                border: Border.all(
                                  color: programa.estadoActual.toLowerCase().contains('activo') 
                                    ? Colors.green 
                                    : Colors.grey
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                programa.estadoActual,
                                style: TextStyle(
                                  color: programa.estadoActual.toLowerCase().contains('activo') 
                                    ? Colors.green[700] 
                                    : Colors.grey[700],
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          programa.nombre,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          programa.institucionEncargada,
                          style: TextStyle(
                            fontSize: 16,
                            color: colors.primary,
                            fontWeight: FontWeight.w500
                          ),
                        ),
                        const Divider(height: 30),
                        Text(
                          programa.descripcion,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 1. Información General y Objetivo
                  _buildExpansionCard(
                    context,
                    title: 'Objetivos y Alcance',
                    icon: Icons.track_changes,
                    children: [
                       _buildInfoTile(context, title: 'Objetivo General', subtitle: programa.objetivo, icon: Icons.flag),
                       _buildInfoTile(context, title: 'Tipo de Objetivo', subtitle: programa.tipoObjetivo, icon: Icons.category),
                       _buildInfoTile(context, title: 'Población Objetivo', subtitle: programa.poblacionObjetivo, icon: Icons.groups),
                       _buildInfoTile(context, title: 'Zona de Aplicación', subtitle: programa.regionAplicacion, icon: Icons.map),
                       _buildInfoTile(context, title: 'Indicador de Resultados', subtitle: programa.descripcionIndicador, icon: Icons.analytics),
                    ],
                  ),

                  // 2. Requisitos y Trámite
                  _buildExpansionCard(
                    context,
                    title: 'Requisitos y Trámite',
                    icon: Icons.assignment,
                    children: [
                      _buildListSection(context, items: programa.requisitos, icon: Icons.check_circle_outline, title: "Requisitos"),
                      _buildListSection(context, items: programa.documentosRequeridos, icon: Icons.description, title: "Documentación"),
                      _buildListSection(context, items: programa.pasosSeguir, icon: Icons.format_list_numbered, title: "Pasos a seguir"),
                      
                      const Divider(),
                      _buildInfoTile(context, title: 'Fechas de Solicitud', subtitle: programa.fechasSolicitud, icon: Icons.calendar_month),
                      _buildInfoTile(context, title: 'Tiempo de Resolución', subtitle: programa.tiempoResolucion, icon: Icons.timer),
                      _buildInfoTile(context, title: 'Requiere Cita', subtitle: programa.requiereCita ? "Sí" : "No", icon: Icons.schedule),
                      _buildInfoTile(context, title: 'Costo del Servicio', subtitle: programa.costoServicio, icon: Icons.monetization_on),
                    ],
                  ),

                  // 3. Beneficios y Operación
                  _buildExpansionCard(
                    context,
                    title: 'Detalles del Apoyo',
                    icon: Icons.handshake,
                    children: [
                      _buildInfoTile(context, title: 'Tipo de Apoyo', subtitle: programa.tipoApoyo, icon: Icons.star_border),
                      _buildInfoTile(context, title: 'Modalidad', subtitle: programa.modalidad, icon: Icons.settings_input_component),
                      _buildInfoTile(context, title: 'Periodos de Pago/Entrega', subtitle: programa.periodosPago, icon: Icons.payments),
                      _buildInfoTile(context, title: 'Presupuesto Asignado', subtitle: programa.presupuesto, icon: Icons.account_balance_wallet),
                    ],
                  ),

                  // 4. Contacto y Ubicación
                  _buildExpansionCard(
                    context,
                    title: 'Contacto y Ubicación',
                    icon: Icons.contact_support,
                    children: [
                      _buildInfoTile(context, title: 'Institución', subtitle: programa.institucionEncargada, icon: Icons.account_balance),
                      _buildInfoTile(context, title: 'Dirección', subtitle: programa.direccion, icon: Icons.location_on),
                      _buildInfoTile(context, title: 'Horarios', subtitle: programa.horariosAtencion, icon: Icons.access_time),
                      _buildInfoTile(context, 
                        title: 'Teléfono', 
                        subtitle: programa.telefonoContacto, 
                        icon: Icons.phone,
                        onTap: () => _launchUrl('tel:${programa.telefonoContacto}')
                      ),
                      _buildInfoTile(context, 
                        title: 'Correo', 
                        subtitle: programa.correoContacto, 
                        icon: Icons.email,
                        onTap: () => _launchUrl('mailto:${programa.correoContacto}')
                      ),
                      _buildInfoTile(context, 
                        title: 'Sitio Web / Redes', 
                        subtitle: programa.redesSociales, 
                        icon: Icons.public,
                        onTap: () => _launchUrl(programa.redesSociales)
                      ),
                      _buildInfoTile(context, 
                        title: 'Módulo de Atención', 
                        subtitle: programa.enlaceModuloAtencion, 
                        icon: Icons.map,
                        onTap: () => _launchUrl(programa.enlaceModuloAtencion)
                      ),
                    ],
                  ),

                   // 5. Marco Legal
                  _buildExpansionCard(
                    context,
                    title: 'Marco Legal',
                    icon: Icons.gavel,
                    children: [
                      Text(
                        programa.fundamentosJuridicos,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const List<String> _localidadesDisponibles = [
  'Todas las Regiones de Quintana Roo',
  'Estatal',
  'Othón P. Blanco',
  'Felipe Carrillo Puerto',
  'José María Morelos',
  'Cozumel',
  'Benito Juárez',
  'Isla Mujeres',
  'Solidaridad',
  'Tulum'
];

//    PRINCIPAL PAGE — HOME PAGE CONTENT

class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  String filtro = '';
  String _localidadSeleccionada = _localidadesDisponibles.first;

  final CollectionReference _programasCollection =
      FirebaseFirestore.instance.collection('programas_sociales');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final isWide = width > 900;
    final double horizontalPadding = isWide ? 48 : 16;
    final double searchHeight = isWide ? 56 : 48;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Programas Sociales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),

      backgroundColor: kBackgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //  BUSCADOR 
              SizedBox(
                height: searchHeight,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o institución...',
                    prefixIcon:
                        Icon(Icons.search, color: colors.primary),
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
              ),

              const SizedBox(height: 16),

              //SELECTOR LOCALIDAD 
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isWide ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _localidadSeleccionada,
                    icon: Icon(Icons.filter_list,
                        color: colors.onSurface),
                    style: TextStyle(
                        color: colors.onSurface,
                        fontSize: isWide ? 16 : 14),
                    onChanged: (String? newValue) {
                      setState(() {
                        _localidadSeleccionada = newValue!;
                      });
                    },
                    items:
                        _localidadesDisponibles.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              //    LISTA DE PROGRAMAS
              
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _programasCollection.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error al cargar: ${snapshot.error}',
                          style: TextStyle(color: colors.error),
                        ),
                      );
                    }

                    // Convertimos documentos a objetos Programa
                    final allPrograms = snapshot.data!.docs
                        .map((doc) {
                           try {
                             return Programa.fromFirestore(doc);
                           } catch (e) {
                             debugPrint("Error parseando documento ${doc.id}: $e");
                             return null;
                           }
                        })
                        .whereType<Programa>() 
                        .toList();

                    // Aplicamos filtros en memoria
                    final programasFiltrados =
                        allPrograms.where((p) {
                      
                      final filtroTexto =
                          p.nombre.toLowerCase().contains(filtro.toLowerCase()) ||
                          p.institucionEncargada.toLowerCase().contains(filtro.toLowerCase()) ||
                          p.institucionAcronimo.toLowerCase().contains(filtro.toLowerCase());

                      final filtroLocalidad =
                          _localidadSeleccionada == _localidadesDisponibles.first
                              ? true
                              : p.regionAplicacion.toLowerCase().contains(_localidadSeleccionada.toLowerCase());

                      return filtroTexto && filtroLocalidad;
                    }).toList();

                    if (programasFiltrados.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                            const SizedBox(height: 10),
                            Text(
                              'No se encontraron programas.',
                              style: TextStyle(
                                  color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }

                    return AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: 400),
                      key: ValueKey(
                          filtro + _localidadSeleccionada),
                      child: ListView.builder(
                        itemCount: programasFiltrados.length,
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          final programa =
                              programasFiltrados[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProgramaDetailPage(
                                            programa:
                                                programa),
                                ),
                              );
                            },
                            child: ProgramaCard(
                              programa: programa,
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


// UBICACIÓN: Al final de home_page_content.dart

class ProgramaCard extends StatelessWidget {
  final Programa programa;

  const ProgramaCard({
    super.key,
    required this.programa,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    
    Color statusColor = Colors.grey;
    if (programa.estadoActual.toLowerCase().contains('vigente')) statusColor = Colors.green;
    if (programa.estadoActual.toLowerCase().contains('cerrado')) statusColor = Colors.red;
    if (programa.estadoActual.toLowerCase().contains('próximamente')) statusColor = Colors.orange;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGEN DEL PROGRAMA
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 90,
                    height: 90,
                    color: colors.primary.withOpacity(0.1),
                    child: Image.network(
                      programa.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            programa.institucionAcronimo.length > 3 
                                ? programa.institucionAcronimo.substring(0,3) 
                                : programa.institucionAcronimo,
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // INFORMACIÓN DEL PROGRAMA
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 30.0), 
                              child: Text(
                                programa.nombre,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        programa.institucionEncargada,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _buildChip(
                            context, 
                            label: programa.estadoActual, 
                            color: statusColor,
                            isOutlined: true
                          ),
                          _buildChip(
                            context, 
                            label: programa.regionAplicacion, 
                            color: colors.secondary,
                            isOutlined: false,
                            opacity: 0.1
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // --- BOTÓN DE FAVORITOS (AQUÍ ESTÁ EL CAMBIO) ---
          if (user != null)
            Positioned(
              top: 0,
              right: 0,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios_registrados')
                    .doc(user.uid)
                    .collection('favoritos')
                    .doc(programa.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  bool isFav = false;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    isFav = true;
                  }

                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.star : Icons.star_border,
                      color: isFav ? Colors.amber : Colors.grey,
                    ),
                    onPressed: () async {
                      final favRef = FirebaseFirestore.instance
                          .collection('usuarios_registrados')
                          .doc(user.uid)
                          .collection('favoritos')
                          .doc(programa.id);

                      if (isFav) {
                        // --- LÓGICA DE CONFIRMACIÓN PARA ELIMINAR ---
                        bool? confirmar = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: const Text("Eliminar de favoritos"),
                              content: const Text("¿Realmente quieres eliminar este programa de tus favoritos?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(false),
                                  child: const Text("Cancelar"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(true),
                                  child: const Text(
                                    "Eliminar", 
                                    style: TextStyle(color: Colors.red)
                                  ),
                                ),
                              ],
                            );
                          },
                        );

                        // Si el usuario presionó "Eliminar" (true)
                        if (confirmar == true) {
                          await favRef.delete();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Eliminado de favoritos"), 
                                duration: Duration(seconds: 1)
                              ),
                            );
                          }
                        }
                        // Si presionó cancelar o fuera del dialogo, no hace nada.

                      } else {
                        // --- LÓGICA PARA AGREGAR (SIN CONFIRMACIÓN) ---
                        await favRef.set(programa.toMap());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Agregado a favoritos"), 
                              duration: Duration(seconds: 1)
                            ),
                          );
                        }
                      }
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, {
    required String label, 
    required Color color, 
    bool isOutlined = false,
    double opacity = 0.1
  }) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isOutlined ? Colors.transparent : color.withOpacity(opacity),
        border: isOutlined ? Border.all(color: color) : null,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isOutlined ? color : color, 
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}