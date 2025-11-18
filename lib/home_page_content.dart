import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:prueba2app/theme/colors.dart';


//-------------------------------------------------------------
//    MODELO DE PROGRAMA
//-------------------------------------------------------------
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

//-------------------------------------------------------------
//    PÁGINA DE DETALLES
//-------------------------------------------------------------
class ProgramaDetailPage extends StatelessWidget {
  final Programa programa;
  const ProgramaDetailPage({super.key, required this.programa});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo lanzar $urlString');
    }
  }

  Widget _buildListSection(BuildContext context,
      {required List<String> items, required IconData icon}) {
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

  Widget _buildInfoTile(BuildContext context,
      {required String title,
      required String subtitle,
      required IconData icon,
      VoidCallback? onTap}) {
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
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
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

  //-------------------------------------------------------------
  //    BUILD DETALLE
  //-------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 900;
    final horizontalPadding = isWide ? 48.0 : 16.0;
    final imageHeight = isWide ? 360.0 : 200.0;
    final titleStyle = Theme.of(context)
        .textTheme
        .headlineSmall
        ?.copyWith(
          fontWeight: FontWeight.bold,
          color: colors.onSurface,
          fontSize: isWide ? 28 : null,
        );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          programa.nombre,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(horizontalPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // imagen principal
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                programa.imagenUrl,
                width: double.infinity,
                height: imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: imageHeight,
                    color: colors.surfaceContainerHighest,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        size: isWide ? 56 : 40,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // etiqueta estado
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
                    fontSize: isWide ? 15 : 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(programa.nombre, style: titleStyle),

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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontSize: isWide ? 18 : 14,
                  ),
            ),

            const SizedBox(height: 20),

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

            // Información adicional
            _buildExpansionCard(
              context,
              title: 'Información Adicional',
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                    context,
                    title: 'Objetivo',
                    subtitle: programa.objetivo,
                    icon: Icons.track_changes),
                _buildInfoTile(context,
                    title: 'Dependencia',
                    subtitle: programa.dependencia,
                    icon: Icons.account_balance),
                _buildInfoTile(
                    context,
                    title: 'Población Objetivo',
                    subtitle: programa.poblacionObjetivo,
                    icon: Icons.group),
                _buildInfoTile(
                    context,
                    title: 'Zona de Aplicación',
                    subtitle: programa.zonaAplicacion,
                    icon: Icons.public),
              ],
            ),

            // Información de registro
            _buildExpansionCard(
              context,
              title: 'Información de registro',
              icon: Icons.how_to_reg_outlined,
              children: [
                _buildListSection(context,
                    items: programa.requisitos,
                    icon: Icons.check_box_outline_blank_rounded),
                _buildListSection(context,
                    items: programa.pasosRegistro,
                    icon: Icons.format_list_numbered_rounded),
                _buildListSection(context,
                    items: programa.documentacionNecesaria,
                    icon: Icons.description_outlined),
              ],
            ),

            // Contacto y Enlaces
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
                  onTap: () =>
                      _launchUrl('tel:${programa.telefonoContacto}'),
                ),
                _buildInfoTile(
                  context,
                  title: 'Correo de Contacto',
                  subtitle: programa.correoContacto,
                  icon: Icons.email_outlined,
                  onTap: () =>
                      _launchUrl('mailto:${programa.correoContacto}'),
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

            // Imagen de referencia
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
                      height: null,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                        height: 150,
                        color: colors.surfaceContainerHighest,
                        child: Icon(Icons.image_not_supported,
                            color: colors.onSurfaceVariant),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              'Inicia: ${programa.inicio.toString().split(' ')[0]}',
              style: TextStyle(color: colors.outline),
            ),
            Text(
              'Finaliza: ${programa.fin.toString().split(' ')[0]}',
              style: TextStyle(color: colors.outline),
            ),
          ],
        ),
      ),
    );
  }
}

//-------------------------------------------------------------
//    LOCALIDADES DISPONIBLES
//-------------------------------------------------------------
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

//-------------------------------------------------------------
//    PRINCIPAL PAGE — HOME PAGE CONTENT
//-------------------------------------------------------------
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
    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final height = mq.size.height;

    final bool isWide = width > 900;
    final double horizontalPadding = isWide ? 48 : 16;
    final double titleFontSize = isWide ? 28 : 20;
    final double searchHeight = isWide ? 56 : 48;
    final double cardImageSize = isWide ? 96 : 70;
    final double cardVerticalPadding = isWide ? 16 : 12;

    return Scaffold(
      // *************** NUEVO APPBAR ***************
     appBar: AppBar(
        title: Text(
          'Programas',
          style: TextStyle(
            color: primaryColor.darker,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),

      backgroundColor: backgroundColor,

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 8,
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: height * 0.01),

              // --------------------- BUSCADOR -----------------------
              SizedBox(
                height: searchHeight,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Busque un programa en específico',
                    prefixIcon:
                        Icon(Icons.search, color: colors.primary),
                    filled: true,
                    fillColor: primaryColor.lighter.withOpacity(0.3),
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

              SizedBox(height: height * 0.02),

              // --------------------- SELECTOR LOCALIDAD -----------------------
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: isWide ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _localidadSeleccionada,
                    icon: Icon(Icons.arrow_drop_down,
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

              SizedBox(height: height * 0.02),

              //------------------------------------------------------------
              //    LISTA DE PROGRAMAS
              //------------------------------------------------------------
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
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: colors.error),
                        ),
                      );
                    }

                    final allPrograms = snapshot.data!.docs
                        .map((doc) => Programa.fromFirestore(doc))
                        .toList();

                    final programasFiltrados =
                        allPrograms.where((p) {
                      final filtroNombre =
                          p.nombre.toLowerCase().contains(
                                filtro.toLowerCase(),
                              );

                      final filtroLocalidad =
                          _localidadSeleccionada ==
                                  _localidadesDisponibles.first
                              ? true
                              : p.localidad ==
                                  _localidadSeleccionada;

                      return filtroNombre &&
                          filtroLocalidad;
                    }).toList();

                    if (programasFiltrados.isEmpty) {
                      return Center(
                        child: Text(
                          'No se encontraron programas.',
                          style: TextStyle(
                              color: colors.onSurfaceVariant),
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
                              imageSize: cardImageSize,
                              verticalPadding:
                                  cardVerticalPadding,
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

//-------------------------------------------------------------
//    TARJETA DE PROGRAMA
//-------------------------------------------------------------
class ProgramaCard extends StatelessWidget {
  final Programa programa;
  final double imageSize;
  final double verticalPadding;

  const ProgramaCard({
    super.key,
    required this.programa,
    this.imageSize = 70,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final estado = programa.estadoActual();

    final colorEstado = switch (estado) {
      'Activo' => colors.primary,
      'Próximamente' => colors.secondary,
      _ => colors.error,
    };

    final mq = MediaQuery.of(context);
    final width = mq.size.width;
    final bool isWide = width > 900;
    final double iconSize = imageSize * 0.55;
    final double titleFont = isWide ? 18 : 16;

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: verticalPadding),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(isWide ? 16 : 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                programa.imagenUrl,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: imageSize,
                    height: imageSize,
                    color: colors.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      color: colors.onSurfaceVariant,
                      size: iconSize,
                    ),
                  );
                },
              ),
            ),

            SizedBox(width: isWide ? 14 : 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    programa.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: titleFont,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: isWide ? 8 : 6),

                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          programa.localidad,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurface,
                          ),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isWide ? 8 : 6),

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


