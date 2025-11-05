import 'package:flutter/material.dart';
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
        'color': Colors.pinkAccent,
        'page': const ProgramasMujeresPage(),
      },
      {
        'title': 'Educación',
        'icon': Icons.school,
        'color': Colors.blueAccent,
        'page': const ProgramasEducacionPage(),
      },
      {
        'title': 'Agricultura',
        'icon': Icons.agriculture,
        'color': Colors.green,
        'page': const AgriculturaPage(),
      },
      {
        'title': 'Vivienda',
        'icon': Icons.house,
        'color': Colors.orangeAccent,
        'page': const ViviendaPage(),
      },
      {
        'title': 'Mayores de edad',
        'icon': Icons.elderly,
        'color': Colors.purpleAccent,
        'page': const AdultosPage(),
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        automaticallyImplyLeading: false,
        title: const Text(
          'Categorías de Programas',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => category['page']),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 1,
                color: category['color'].withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 60,
                      color: category['color'],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category['title'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: category['color'],
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
