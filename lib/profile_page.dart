import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'autentificacion.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool hasNewNotification = true;

  List<String> notifications = [
    "hola canche.",
    "santi tamay.",
  ];

  File? profileImage;

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        profileImage = File(pickedFile.path);
      });
    }
  }

  void showNotificationsDialog(BuildContext context) async {
    setState(() {
      hasNewNotification = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.notifications, color: Colors.blueAccent),
              SizedBox(width: 10),
              Text('Notificaciones'),
            ],
          ),
          content: notifications.isEmpty
              ? const Text("No tienes notificaciones nuevas.")
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.circle_notifications_outlined),
                        title: Text(notifications[index]),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cerrar',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    //Esta parte es cuando no inicias sesion

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Mi perfil', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Debes iniciar sesión para acceder a esta página.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 25),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Autentificacion(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    //Esto es cuando ya el usuario inicio sesion 

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Mi perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    showNotificationsDialog(context);
                  },
                ),
                if (hasNewNotification)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: const Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // FOTO DE PERFIL
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: CircleAvatar(
                radius: 55,
                backgroundImage: profileImage == null
                    ? const AssetImage('assets/profile_default.png')
                    : FileImage(profileImage!) as ImageProvider,
              ),
            ),

            const SizedBox(height: 10),

            // BOTÓN CAMBIAR FOTO
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (context) {
                    return Wrap(
                      children: [
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Seleccionar imagen',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text('Elegir de galería'),
                          onTap: () {
                            Navigator.pop(context);
                            pickImage(ImageSource.gallery);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text('Tomar foto'),
                          onTap: () {
                            Navigator.pop(context);
                            pickImage(ImageSource.camera);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: const Text(
                "Cambiar foto",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blueAccent,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Bienvenido, ${user.email ?? 'Usuario'}',
              style: const TextStyle(fontSize: 22),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 35),

            // NOMBRE
            TextField(
              decoration: InputDecoration(
                labelText: "Nombre",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // APELLIDO
            TextField(
              decoration: InputDecoration(
                labelText: "Apellido",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CURP
            TextField(
              decoration: InputDecoration(
                labelText: "CURP",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Datos guardados (ejemplo)")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Guardar",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            const Text(
              'Programas favoritos o guardados',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
