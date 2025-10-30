import 'package:flutter/material.dart';

// Asegúrate de que esta ruta sea correcta para tu archivo home_page.dart
import 'home_page.dart'; 

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Scaffold provee la estructura básica de la pantalla.
    return Scaffold(
      // La propiedad backgroundColor se usa si quieres un color de fondo diferente
      // al color por defecto. El de la imagen parece blanco o muy claro.
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                
                 SizedBox(
                   
                    child: Image.asset('assets/imagenes/image.png', width: 300, height: 250,),                   

                  
                ),
                
                
                const SizedBox(height: 40),
                const Text(
                  'Bienvenido',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A), 
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

               
                const Text(
                  'Te presentamos una forma sencilla de conocer, acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 50),

                
                SizedBox(
                  width: double.infinity, 
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomePage(), 
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF255B9F), // El color azul oscuro del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bordes ligeramente redondeados
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'COMENZAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

              
                Column(
                  children: <Widget>[
                   SizedBox(
                  
                    child: Image.asset('assets/imagenes/logo.png', width: 100, height: 150,),                   

                ),
                    const SizedBox(height: 5),
                    
                  ],
                ),

                const SizedBox(height: 10),
             
              ],
            ),
          ),
        ),
      ),
    );
  }
}