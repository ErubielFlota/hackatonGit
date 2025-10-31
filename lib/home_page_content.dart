// ESTA PAGINA O VISTA LA USARÉ PARA MOSTRAR LA LISTA DE ELEMENTOS DISPONIBLES
import 'package:flutter/material.dart';


class Programas {
  final String nombre;
  final String desc;

  const Programas({required this.nombre, required this.desc});
}

class PrincipalPage extends StatelessWidget {
  const PrincipalPage({super.key});

  // Lista de datos de ejemplo para simular los elementos de la lista
  final List<Programas> programastList = const [
    Programas(nombre: 'Beca Jovenes Construyendo el futuro', desc: 'Click para más detalles.'),
    Programas(nombre: 'Beca Universal de Educación Básica Rita Cetina', desc: 'Click para más detalles.'),
    Programas(nombre: 'Salud Casa por Casa', desc: 'Click para más detalles.'),
    Programas(nombre: 'Pensión Para el Bienestar de las Perosnas Mayores', desc: 'Click para más detalles.'),
    Programas(nombre: 'Salud Casa por Casa', desc: 'Click para más detalles.'),
    Programas(nombre: 'Pensión Para el Bienestar de las Perosnas Mayores', desc: 'Click para más detalles.'),
    Programas(nombre: 'Salud Casa por Casa', desc: 'Click para más detalles.'),
    Programas(nombre: 'Pensión Para el Bienestar de las Perosnas Mayores', desc: 'Click para más detalles.'),
    Programas(nombre: 'Salud Casa por Casa', desc: 'Click para más detalles.'),
    Programas(nombre: 'Pensión Para el Bienestar de las Perosnas Mayores', desc: 'Click para más detalles.')
    
  ];

  @override
  Widget build(BuildContext context) {
    
    // mi contenedor principal es un Scaffold
    return Scaffold(
      
    
      appBar: AppBar(
        title: const Text('Programas Disponibles'),
        backgroundColor: Colors.lightBlueAccent, // Color fondo 
        foregroundColor: Colors.white, // Color texto 
        elevation: 1,
      ),
      
      // defino el cuerpo que tendrá la lista
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        child: ListView.builder(
          
          itemCount: programastList.length,
          itemBuilder: (context, index) {
            final program = programastList[index];
            
            // con card se hace el diseño de los elementos de las listas
            return Card(
              margin: const EdgeInsets.only(bottom: 1.0),
              elevation: 0, 
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), // por si quiero redondear
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    // 1. Imagen Placeholder para simular foto, luego cambiar a url
                    
                    Container(
                      width: 140, 
                      height: 140, 
                      decoration: BoxDecoration(
                        color: Colors.grey[300], // Fondo gris 
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.image_outlined, 
                        color: Colors.grey[600],
                        size: 30,
                      ),
                    ),
                    
                    // espacio entre la imagen y el texto
                    const SizedBox(width: 16.0),

                    //sección de Título y Subtítulo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // Nombre del programa
                          Text(
                            program.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2, // Permite más de una línea para el título si es largo
                          ),
                          
                          // texto de descripcion
                          const SizedBox(height: 4.0),
                          Text(
                            program.desc,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
