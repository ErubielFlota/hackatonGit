// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:prueba2app/autentificacion.dart';
// import 'package:prueba2app/theme/colors.dart';

// class BienvenidaScreen extends StatefulWidget {
//   const BienvenidaScreen({super.key});

//   @override
//   State<BienvenidaScreen> createState() => _BienvenidaScreenState();
// }

// class _BienvenidaScreenState extends State<BienvenidaScreen> {
//   bool _showSplash = true; // Controla qué pantalla mostrar

//   @override
//   void initState() {
//     super.initState();

//     // Espera 3 segundos y cambia de splash a bienvenida
//     Timer(const Duration(seconds: 3), () {
//       setState(() {
//         _showSplash = false;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const SizedBox(height: 30),
//               Expanded(
//                 child: Column(
//                   children: [
                    

// <<<<<<< ramacambios
//   // 🔹 Pantalla Splash (logo grande sobre fondo azul)
//   Widget _buildSplashView() {
//     return Center(
//       key: const ValueKey('splash'),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset(
//             'assets/logoblanco.png', // asegúrate de tenerlo registrado en pubspec.yaml
//             width: 180,
//             height: 180,
//           ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }

//   // 🔹 Pantalla de bienvenida (botón "COMENZAR")
//   Widget _buildWelcomeView(BuildContext context) {
//     return Center(
//       key: const ValueKey('welcome'),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Image.asset(
//               'assets/logoazul.png',
//               width: 140,
//               height: 140,
//             ),
//             const SizedBox(height: 30),
//             const Text(
//               'Bienvenido',
//               style: TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.bold,
//                 color: primaryColor,
//               ),
//             ),
//             const SizedBox(height: 10),
//             const Text(
//               'Te presentamos una forma sencilla de conocer acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
//               textAlign: TextAlign.center,
//               style: TextStyle(fontSize: 15, color: Colors.black54),
//             ),
//             const SizedBox(height: 40),
//             FilledButton(
//               style: FilledButton.styleFrom(
//                 backgroundColor:primaryColor,
//                 elevation: 6,
//                 shadowColor: primaryColor.withOpacity(0.3),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(16),
// =======
//                     Image.asset(
//                       'bienestarbanner.png',
//                       fit: BoxFit.contain
                      
//                     ),
//                     const SizedBox(height: 32),


//                     Text(
//                       'Bienvenido',
//                       style: Theme.of(context)
//                           .textTheme
//                           .headlineMedium
//                           ?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.blue[900],
//                           ),
//                     ),
//                     const SizedBox(height: 16),
//                     const Text(
//                       'Te presentamos una forma sencilla de conocer acerca de los programas y apoyos disponibles según el municipio del estado de Quintana Roo.',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(fontSize: 16, color: Colors.black54),
//                     ),
//                   ],
// >>>>>>> master
//                 ),
//               ),
//               Column(
//                 children: [
//                   FilledButton(
//                     onPressed: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const Autentificacion(),
//                         ),
//                       );
//                     },
//                     style: FilledButton.styleFrom(
//                       minimumSize: const Size(double.infinity, 50),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: const Text('COMENZAR', style: TextStyle(fontSize: 16)),
//                   ),
//                   const SizedBox(height: 12),
//                   Column(
//                     children: const [
//                       SizedBox(height: 8),
//                       Text('© Derechos reservados 2025',
//                           style: TextStyle(color: Colors.grey)),
//                       SizedBox(height: 8),
//                       Text('MiApoyo',
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, color: Colors.blue)),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }