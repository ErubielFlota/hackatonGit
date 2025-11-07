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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text(
                'Categorías de Programas',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),
              Expanded(
                child: GridView.builder(
                  itemCount: categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => category['page']),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                              size: 55,
                              color: primaryColor.darker,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              category['title'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: 30,
                              height: 3,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
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

