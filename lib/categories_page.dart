import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'package:prueba2app/pages/programasocial.dart';
import 'package:prueba2app/pages/servicios.dart';     
import 'package:prueba2app/pages/tramite.dart';      

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;


    int crossAxisCount;
    double childAspectRatio = 1;

    if (width >= 1200) {
      crossAxisCount = 4; 
      childAspectRatio = 1.4;
    } else if (width >= 900) {
      crossAxisCount = 3; 
      childAspectRatio = 1.3;
    } else if (width >= 600) {
      crossAxisCount = 2; 
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 2; 
      childAspectRatio = 0.90;
    }

    final List<Map<String, dynamic>> categories = [
      {
        'title': 'Programas Sociales',
        'icon': Icons.groups_rounded,
        'page': const ProgramasSocialesPage(),
      },
      {
        'title': 'Servicios',
        'icon': Icons.design_services_rounded,
        'page': const ServiciosPage(), 
      },
      {
        'title': 'Trámites',
        'icon': Icons.assignment_rounded,
        'page': const TramitesPage(), 
      },
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Categorias',
          style: TextStyle(
            color: primaryColor.darker,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
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
                    // Círculo de fondo para el icono (Opcional, para resaltar)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        category['icon'],
                        size: 50,
                        color: primaryColor.darker,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      category['title'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Pequeña barra decorativa
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
