import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos SingleChildScrollView para evitar desbordamiento cuando el teclado aparece
    return const Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Título principal
              Text(
                'Inicia sesión',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A), 
                ),
              ),

              SizedBox(height: 40),

              //Campo de Usuario (Correo Electrónico)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Usuario', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ingrese su correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 20),

              // Campo de contraseña
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Contraseña', style: TextStyle(fontSize: 16)),
              ),
              SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Ingresa tu contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
                ),
                obscureText: true,
              ),

              SizedBox(height: 10),

              // Olvidaste tu contraseña?
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '¿Has olvidado tu contraseña?',
                  style: TextStyle(
                    color: Color(0xFF1E3A8A), 
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(height: 25),

              // Botón de Inicio de Sesión
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: null, // Aquí iría la lógica de inicio de sesión
                  
                  child: Text(
                    'Inicio',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              SizedBox(height: 20),

              //Separador "O continua con" 
              Text('O continua con', style: TextStyle(color: Colors.grey)),

              SizedBox(height: 15),

              //Botones de Redes Sociales
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Botón de Google (Simulado)
                  
                  SizedBox(width: 20),
                  
                ],
              ),

              SizedBox(height: 40),

              // --- ¿No tienes una cuenta? Crea una. ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('¿No tienes una cuenta? ', style: TextStyle(fontSize: 16)),
                  Text(
                    'Crea una.',
                    style: TextStyle(
                      color: Color(0xFF1E3A8A), // Enlace para crear cuenta
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // --- Botón "Omitir por ahora" ---
              //SizedBox(
               // width: 200,
                //height: 48,
                //child: ElevatedButton(
                 // onPressed: null, // Aquí iría la lógica para omitir la sesión y continuar
                 // 
                 // child: Text(
                  //  'Omitir por ahora',
                   // style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.normal),
                // ),
               // ),
              //),
            ],
          ),
        ),
      ),
    );
  }
}