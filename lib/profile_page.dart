import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba2app/autentificacion.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  List<String> notifications = ["hola canche.", "santi tamay."];
  int unreadNotifications = 2;

  bool get hasNewNotification => unreadNotifications > 0;

  void showNotificationsDialog(BuildContext context) {
    setState(() => unreadNotifications = 0);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notificaciones"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: notifications
                .map((n) => ListTile(
                      leading: const Icon(Icons.notifications),
                      title: Text(n),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          )
        ],
      ),
    );
  }

  
  File? profileImage;
  String? profileImageUrl;

  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _apellido = TextEditingController();
  final TextEditingController _curp = TextEditingController();
  final TextEditingController _email = TextEditingController();

  bool _saving = false;

  final _formKey = GlobalKey<FormState>();
  final RegExp _curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _email.text = user.email ?? "";

    try {
      final doc = await FirebaseFirestore.instance
          // <-- CAMBIO: Usamos la colección correcta
          .collection("usuarios_registrados") 
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;

        // <-- CAMBIO: Usamos los nombres de campo correctos
        _nombre.text = data["nombres"] ?? "";
        _apellido.text = data["apellidos"] ?? "";
        _curp.text = data["curp"] ?? ""; // Este campo es de profile
        profileImageUrl = data["fotoUrl"]; // Este campo es de profile
      }

      setState(() {});
    } catch (e) {}
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      setState(() => profileImage = File(picked.path));
    }
  }

  Future<String?> _uploadProfileImage(String uid) async {
    if (profileImage == null) return profileImageUrl;

    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("profileImages/$uid.jpeg");

      await ref.putFile(profileImage!);

      return await ref.getDownloadURL();
    } catch (e) {
      return profileImageUrl;
    }
  }

  bool _validarCurp(String curp) =>
      _curpRegex.hasMatch(curp.trim().toUpperCase());

  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final curp = _curp.text.trim().toUpperCase();
    if (curp.isNotEmpty && !_validarCurp(curp)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("CURP inválida"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() => _saving = true);

    try {
      final photoUrl = await _uploadProfileImage(user.uid);

      await FirebaseFirestore.instance
          // <-- CAMBIO: Usamos la colección correcta
          .collection("usuarios_registrados")
          .doc(user.uid)
          .set({
        // <-- CAMBIO: Usamos los nombres de campo correctos
        "nombres": _nombre.text.trim(),
        "apellidos": _apellido.text.trim(),
        "curp": curp,
        "correo": user.email, // <-- CAMBIO: "correo" para ser consistente
        "fotoUrl": photoUrl,
      }, SetOptions(merge: true));

      setState(() => profileImageUrl = photoUrl);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Perfil guardado correctamente"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => _saving = false);
    }
  }

  // ----------------------------------------------------------
  // CAMBIAR CORREO / CONTRASEÑA
  // ----------------------------------------------------------

  void _changeEmailDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar correo"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Nuevo correo")),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            child: const Text("Actualizar"),
            onPressed: () async {
              await _changeEmail(emailCtrl.text, passCtrl.text, ctx);
            },
          )
        ],
      ),
    );
  }

  Future<void> _changeEmail(String newEmail, String password, BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);

      // Esto actualiza Firebase AUTH (el login)
      await user.verifyBeforeUpdateEmail(newEmail);

      // Esto actualiza tu base de datos Firestore
      await FirebaseFirestore.instance
          // <-- CAMBIO: Usamos la colección correcta
          .collection("usuarios_registrados")
          .doc(user.uid)
          // <-- CAMBIO: "correo" para ser consistente
          .set({"correo": newEmail}, SetOptions(merge: true));

      Navigator.pop(ctx);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Se envió un mensaje al nuevo correo para verificar"),
        backgroundColor: Colors.green,
      ));
      
      // Actualizamos el campo de texto en la UI
      _email.text = newEmail;
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _changePassDialog() {
    final current = TextEditingController();
    final newPass = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: current, decoration: const InputDecoration(labelText: "Contraseña actual"), obscureText: true),
            TextField(controller: newPass, decoration: const InputDecoration(labelText: "Nueva contraseña"), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            child: const Text("Actualizar"),
            onPressed: () async {
              await _changePassword(current.text, newPass.text, ctx);
            },
          )
        ],
      ),
    );
  }

  Future<void> _changePassword(String oldPass, String newPass, BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final cred = EmailAuthProvider.credential(email: user.email!, password: oldPass);
      await user.reauthenticateWithCredential(cred);

      await user.updatePassword(newPass);

      Navigator.pop(ctx);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Contraseña actualizada"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ----------------------------------------------------------
  // UI (Sin cambios)
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          automaticallyImplyLeading: false,
          title: const Text("Mi perfil", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Debes iniciar sesión para ver tu perfil.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Autentificacion()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Mi perfil"),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () => showNotificationsDialog(context),
              ),
              if (hasNewNotification)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: Text(
                      unreadNotifications.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                )
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // FOTO DE PERFIL
            CircleAvatar(
              radius: 60,
              backgroundImage: profileImage != null
                  ? FileImage(profileImage!)
                  : (profileImageUrl != null
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage("assets/profile_default.png"))
                      as ImageProvider,
            ),

            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text("Elegir galería"),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text("Tomar foto"),
                        onTap: () {
                          Navigator.pop(context);
                          pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Cambiar foto"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: _nombre,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _apellido,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _curp,
              decoration: const InputDecoration(labelText: "CURP"),
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 15),

            TextField(
              controller: _email,
              enabled: false,
              decoration: const InputDecoration(labelText: "Correo"),
            ),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _changeEmailDialog,
                    child: const Text("Cambiar correo"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _changePassDialog,
                    child: const Text("Cambiar contraseña"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}