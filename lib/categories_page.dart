import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'pages/mujeres_page.dart';
import 'pages/educacion_page.dart';
import 'pages/agricultura_page.dart';
import 'pages/vivienda_page.dart';
import 'pages/mayores_page.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // Número de columnas según tamaño de pantalla
    int crossAxisCount;
    double childAspectRatio = 1;

    if (width >= 1200) {
      crossAxisCount = 4; // Monitores grandes
      childAspectRatio = 1.4;
    } else if (width >= 900) {
      crossAxisCount = 3; // Pantallas de laptop
      childAspectRatio = 1.3;
    } else if (width >= 600) {
      crossAxisCount = 2; // Tablets o ventanas medianas
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 2; // Móviles
      childAspectRatio = 0.90;
    }

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Mujeres',
        'icon': Icons.female,
        'page': const ProgramasMujeresPage(),
      },
      {
        'title': 'Educación',
        'icon': Icons.school,
        'page': const ProgramasEducacionPage(),
      },
      {
        'title': 'Agricultura',
        'icon': Icons.agriculture,
        'page': const AgriculturaPage(),
      },
      {
        'title': 'Vivienda',
        'icon': Icons.house,
        'page': const ViviendaPage(),
      },
      {
        'title': 'Mayores de edad',
        'icon': Icons.elderly,
        'page': const AdultosPage(),
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Categorías de Programas',
          style: TextStyle(
            color: primaryColor.darker,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => category['page']),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.darker.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 60,
                      color: primaryColor.darker,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: primaryColor.darker,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

