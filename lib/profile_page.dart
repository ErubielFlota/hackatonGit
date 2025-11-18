// profile_page.dart
// VERSIÓN FINAL "BASE64":
// Usamos codificación Base64 para evitar bloqueos de transmisión en Web.

import 'dart:convert'; // <--- ¡NUEVO IMPORT NECESARIO!
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba2app/autentificacion.dart';
import 'package:prueba2app/theme/colors.dart';

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

  Uint8List? profileImageBytes;
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
          .collection("usuarios_registrados")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nombre.text = data["nombres"] ?? "";
        _apellido.text = data["apellidos"] ?? "";
        _curp.text = data["curp"] ?? "";
        profileImageUrl = data["fotoUrl"];
      }

      setState(() {});
    } catch (e) {
      print("Error loading data: $e");
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
          source: source,
          maxWidth: 800, // Reduje un poco el tamaño para facilitar la subida
          maxHeight: 800,
          imageQuality: 80);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => profileImageBytes = bytes);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // ---------- FUNCIÓN DE SUBIDA BASE64 (LA SOLUCIÓN) ----------
  Future<String?> _uploadProfileImage(String uid) async {
    if (profileImageBytes == null) {
      print("[DEBUG] No hay foto nueva, retornando URL actual.");
      return profileImageUrl;
    }

    try {
      final filename = "profileImages/$uid/profile.jpg";
      final ref = FirebaseStorage.instance.ref().child(filename);

      print("[DEBUG] Iniciando subida Base64 a: $filename");

      // 1. Convertimos los bytes a un String Base64
      String base64Image = base64Encode(profileImageBytes!);

      // 2. Subimos usando putString (Mucho más estable en Web)
      final uploadTask = ref.putString(
        base64Image,
        format: PutStringFormat.base64,
        metadata: SettableMetadata(contentType: 'image/jpeg'),
      );

      // 3. Esperamos (ahora no debería colgarse)
      final snapshot = await uploadTask;
      print("[DEBUG] ¡Subida completada!");

      final downloadUrl = await snapshot.ref.getDownloadURL();
      print("[DEBUG] URL obtenida: $downloadUrl");
      
      return downloadUrl;

    } catch (e) {
      print("[DEBUG] ERROR CRÍTICO EN UPLOAD: $e");
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
    print("[DEBUG] Guardando perfil...");

    try {
      // Subimos la foto
      final photoUrl = await _uploadProfileImage(user.uid);

      if (photoUrl == null || photoUrl.isEmpty) {
        print("[DEBUG] ALERTA: URL es nula, pero seguimos guardando datos.");
      }

      // Guardamos en Firestore
      await FirebaseFirestore.instance
          .collection("usuarios_registrados")
          .doc(user.uid)
          .set({
        "nombres": _nombre.text.trim(),
        "apellidos": _apellido.text.trim(),
        "curp": curp,
        "correo": user.email,
        "fotoUrl": photoUrl,
      }, SetOptions(merge: true));

      setState(() {
        profileImageUrl = photoUrl;
        profileImageBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Guardado con éxito"),
        backgroundColor: Colors.green,
      ));
    } catch (e) {
      print("[DEBUG] ERROR GENERAL: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => _saving = false);
    }
  }

  // ----------------------------------------------------------
  // DIALOGOS DE CORREO / CONTRASEÑA (Sin cambios)
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
            TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(labelText: "Nuevo correo")),
            TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
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

  Future<void> _changeEmail(
      String newEmail, String password, BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
      await user.verifyBeforeUpdateEmail(newEmail);
      await FirebaseFirestore.instance
          .collection("usuarios_registrados")
          .doc(user.uid)
          .set({"correo": newEmail}, SetOptions(merge: true));
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Verifica tu nuevo correo"),
          backgroundColor: Colors.green));
      _email.text = newEmail;
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
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
            TextField(
                controller: current,
                decoration:
                    const InputDecoration(labelText: "Contraseña actual"),
                obscureText: true),
            TextField(
                controller: newPass,
                decoration:
                    const InputDecoration(labelText: "Nueva contraseña"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancelar")),
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

  Future<void> _changePassword(
      String oldPass, String newPass, BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: oldPass);
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPass);
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Contraseña actualizada"),
          backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
            child: ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Autentificacion())),
                child: const Text("Iniciar Sesión"))),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi perfil"),
        automaticallyImplyLeading: false,
        actions: [
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
            CircleAvatar(
              radius: 60,
              backgroundImage: (() {
                if (profileImageBytes != null) {
                  return MemoryImage(profileImageBytes!) as ImageProvider;
                } else if (profileImageUrl != null &&
                    profileImageUrl!.isNotEmpty) {
                  return NetworkImage(profileImageUrl!) as ImageProvider;
                } else {
                  return const AssetImage("assets/profile_default.png")
                      as ImageProvider;
                }
              })(),
            ),
            TextButton(
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              child: const Text("Cambiar foto"),
            ),
            const SizedBox(height: 20),
            TextField(
                controller: _nombre,
                decoration: const InputDecoration(labelText: "Nombre")),
            const SizedBox(height: 15),
            TextField(
                controller: _apellido,
                decoration: const InputDecoration(labelText: "Apellido")),
            const SizedBox(height: 15),
            TextField(
                controller: _curp,
                decoration: const InputDecoration(labelText: "CURP"),
                textCapitalization: TextCapitalization.characters),
            const SizedBox(height: 15),
            TextField(
                controller: _email,
                enabled: false,
                decoration: const InputDecoration(labelText: "Correo")),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton(
                        onPressed: _changeEmailDialog,
                        child: const Text("Cambiar correo"))),
                const SizedBox(width: 10),
                Expanded(
                    child: OutlinedButton(
                        onPressed: _changePassDialog,
                        child: const Text("Cambiar contraseña"))),
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