// lib/profile_page.dart 

import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba2app/autentificacion.dart';
// import 'package:prueba2app/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Variables de estado para notificaciones (Sin cambios)
  List<String> notifications = ["hola canche.", "santi tamay."];
  int unreadNotifications = 2;
  bool get hasNewNotification => unreadNotifications > 0;

  void showNotificationsDialog(BuildContext context) {
    setState(() => unreadNotifications = 0);
    // ... (Lógica de diálogo de notificaciones sin cambios)
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

  // 💾 Almacenaremos los valores originales al cargar para detectar cambios
  String _originalNombre = '';
  String _originalApellido = '';
  String _originalCurp = '';


  final _formKey = GlobalKey<FormState>();
  final RegExp _curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$');

  //  REMOVIDAS: _isEditingNombre, _isEditingApellido, _isEditingCurp.
  // Los campos siempre estarán editables.

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //  FUNCIÓN _loadUserData (Guarda los valores originales al cargar)
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

        // 🆕 Guardar valores originales
        _originalNombre = _nombre.text;
        _originalApellido = _apellido.text;
        _originalCurp = _curp.text;


        // LÓGICA DE SINCRONIZACIÓN DE CORREO:
        if (data["correo"] == null && user.email != null) {
            print("[DEBUG] Sincronizando nuevo correo en Firestore.");
            await FirebaseFirestore.instance
                .collection("usuarios_registrados")
                .doc(user.uid)
                .set({
                    "correo": user.email,
                    "correoPendiente": FieldValue.delete()
                }, SetOptions(merge: true));
        } else if (data["correo"] != user.email && user.email != null) {
           await FirebaseFirestore.instance
                .collection("usuarios_registrados")
                .doc(user.uid)
                .set({"correo": user.email}, SetOptions(merge: true));
        }
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
          maxWidth: 800,
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

  // ---------- FUNCIÓN DE SUBIDA BASE64 ----------
  Future<String?> _uploadProfileImage(String uid) async {
    if (profileImageBytes == null) {
      return profileImageUrl;
    }

    try {
      final filename = "profileImages/$uid/profile.jpg";
      final ref = FirebaseStorage.instance.ref().child(filename);
      String base64Image = base64Encode(profileImageBytes!);
      final uploadTask = ref.putString(
        base64Image,
        format: PutStringFormat.base64,
        metadata: SettableMetadata(contentType: 'image/jpeg'),
      );
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("[DEBUG] ERROR CRÍTICO EN UPLOAD: $e");
      return profileImageUrl;
    }
  }

  bool _validarCurp(String curp) =>
      _curpRegex.hasMatch(curp.trim().toUpperCase());

  //  FUNCIÓN _saveProfile (Mantengo la lógica de confirmación de contraseña)
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 1. Detectar si hay cambios en los campos
    final bool dataChanged = (_nombre.text.trim() != _originalNombre.trim()) ||
                                 (_apellido.text.trim() != _originalApellido.trim()) ||
                                 (_curp.text.trim().toUpperCase() != _originalCurp.trim().toUpperCase());

    final bool photoChanged = profileImageBytes != null;

    // Si no hay cambios en datos ni foto, no hacemos nada
    if (!dataChanged && !photoChanged) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No hay cambios para guardar."),
            backgroundColor: Colors.blueAccent,
        ));
        return;
    }

    // 2. Validar CURP
    final curp = _curp.text.trim().toUpperCase();
    if (curp.isNotEmpty && !_validarCurp(curp)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("CURP inválida"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    String? password;

    // 3. Si hay cambios en datos, solicitar y reautenticar con contraseña
    if (dataChanged) {
        password = await _confirmPasswordDialog(context);
        if (password == null) return; // Si el usuario cancela o hay error

        try {
            // Reautenticar
            final cred = EmailAuthProvider.credential(
                email: user.email!, password: password);
            await user.reauthenticateWithCredential(cred);
        } on FirebaseAuthException catch (e) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                 content: Text(
                     e.code == 'wrong-password' || e.code == 'invalid-credential'
                         ? "Contraseña incorrecta. Los datos no fueron guardados."
                         : "Error de autenticación: ${e.code}"),
                 backgroundColor: Colors.redAccent,
             ));
             return; // Detenemos el proceso si la contraseña es incorrecta
        }
    }

    // 4. Iniciar el guardado (tanto para cambios de foto como de datos)
    setState(() => _saving = true);
    print("[DEBUG] Guardando perfil...");

    try {
      // 5. Subimos la foto (se ejecuta sin requerir password explícitamente)
      final photoUrl = await _uploadProfileImage(user.uid);

      // 6. Actualizamos Auth (Display Name)
      final fullName = "${_nombre.text.trim()} ${_apellido.text.trim()}";
      if (fullName.trim().isNotEmpty) {
        await user.updateDisplayName(fullName);
      } else if (user.displayName != null) {
        await user.updateDisplayName(null);
      }
      await user.reload();

      // 7. Guardamos en Firestore
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

      // 8. Actualizamos la UI y los valores originales
      setState(() {
        profileImageUrl = photoUrl;
        profileImageBytes = null; // Limpiar los bytes después de la subida exitosa

        // 🔑 IMPORTANTE: Actualizar los valores originales al guardar
        _originalNombre = _nombre.text;
        _originalApellido = _apellido.text;
        _originalCurp = _curp.text;
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Guardado con éxito"),
        backgroundColor: Colors.green,
      ));

    } catch (e) {
      print("[DEBUG] ERROR GENERAL AL GUARDAR: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error al guardar: $e"),
        backgroundColor: Colors.redAccent,
      ));
    } finally {
      setState(() => _saving = false);
    }
  }

  //  DIÁLOGO PARA CONFIRMAR CONTRASEÑA ANTES DE GUARDAR
  Future<String?> _confirmPasswordDialog(BuildContext context) async {
    final passCtrl = TextEditingController();

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Cambios"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ingresa tu contraseña actual para confirmar los cambios en tus datos personales."),
            const SizedBox(height: 10),
            TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null), // Retorna null si cancela
              child: const Text("Cancelar")),
          ElevatedButton(
            child: const Text("Confirmar"),
            onPressed: () {
              if (passCtrl.text.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text("La contraseña no puede estar vacía"),
                    backgroundColor: Colors.orangeAccent));
                return;
              }
              Navigator.pop(ctx, passCtrl.text); // Retorna la contraseña
            },
          )
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // DIALOGOS DE CORREO / CONTRASEÑA (Se mantienen sin cambios)
  // ----------------------------------------------------------

  void _changeEmailDialog() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    emailCtrl.text = _email.text;

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

    final trimmedNewEmail = newEmail.trim().toLowerCase();

    if (trimmedNewEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Por favor, llena todos los campos"),
          backgroundColor: Colors.redAccent));
      return;
    }

    if (trimmedNewEmail == user.email!.toLowerCase()) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("El nuevo correo es el mismo que el actual."),
          backgroundColor: Colors.blue));
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: password);
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              e.code == 'wrong-password' || e.code == 'invalid-credential'
                  ? "Contraseña incorrecta"
                  : "Error de reautenticación: ${e.code}"),
          backgroundColor: Colors.redAccent));
      return;
    } catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error desconocido: $e"),
          backgroundColor: Colors.redAccent));
      return;
    }

    try {
      await user.verifyBeforeUpdateEmail(trimmedNewEmail);

      await FirebaseFirestore.instance
          .collection("usuarios_registrados")
          .doc(user.uid)
          .set({
            "correo": FieldValue.delete(),
            "correoPendiente": trimmedNewEmail
          }, SetOptions(merge: true));

      Navigator.pop(ctx);
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Se ha enviado un correo a ${trimmedNewEmail} para verificar el cambio. Por seguridad, debe volver a iniciar sesión."),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.blueAccent));

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Autentificacion()),
            (Route<dynamic> route) => false,
        );
      }

    } on FirebaseAuthException catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              e.code == 'email-already-in-use'
                  ? "El correo ya está en uso por otra cuenta."
                  : "Error al actualizar correo: ${e.code}"),
          backgroundColor: Colors.redAccent));
    } catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error desconocido: $e"),
          backgroundColor: Colors.redAccent));
    }
  }

  void _changePassDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cambiar Contraseña"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: oldPassCtrl,
                decoration: const InputDecoration(labelText: "Contraseña Actual"),
                obscureText: true),
            TextField(
                controller: newPassCtrl,
                decoration: const InputDecoration(labelText: "Nueva Contraseña"),
                obscureText: true),
            TextField(
                controller: confirmPassCtrl,
                decoration: const InputDecoration(
                    labelText: "Confirmar Nueva Contraseña"),
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
              await _changePassword(oldPassCtrl.text, newPassCtrl.text,
                  confirmPassCtrl.text, ctx);
            },
          )
        ],
      ),
    );
  }

  Future<void> _changePassword(String oldPassword, String newPassword,
      String confirmPassword, BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Las nuevas contraseñas no coinciden"),
          backgroundColor: Colors.redAccent));
      return;
    }

    if (oldPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
          content: Text("Por favor, llena todos los campos"),
          backgroundColor: Colors.redAccent));
      return;
    }

    try {
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: oldPassword);
      await user.reauthenticateWithCredential(cred);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              e.code == 'wrong-password' || e.code == 'invalid-credential'
                  ? "Contraseña actual incorrecta"
                  : "Error de reautenticación: ${e.code}"),
          backgroundColor: Colors.redAccent));
      return;
    } catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error desconocido: $e"),
          backgroundColor: Colors.redAccent));
      return;
    }

    try {
      await user.updatePassword(newPassword);

      Navigator.pop(ctx);
      await FirebaseAuth.instance.signOut();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            "Contraseña actualizada con éxito. Por seguridad, debe volver a iniciar sesión."),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.blueAccent));

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Autentificacion()),
            (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error al actualizar contraseña: ${e.code}"),
          backgroundColor: Colors.redAccent));
    } catch (e) {
      Navigator.pop(ctx);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Error desconocido: $e"),
          backgroundColor: Colors.redAccent));
    }
  }

  //  WIDGET DE TEXTFIELD SENCILLO (Sin lápiz de edición)
  Widget _buildSimpleField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    const primaryColor = Colors.blue;

    return TextField(
      controller: controller,
      // Ahora siempre enabled (salvo que se indique lo contrario en la llamada)
      enabled: enabled,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey[700],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        // Borde activo (si enabled es true)
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
        ),
        // Borde deshabilitado (si enabled es false)
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        // ❌ REMOVIDO: suffixIcon (Lápiz/X)
      ),
    );
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
        title: Text(user.displayName ?? "Mi perfil"),
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

            // 🚫 El cambio de foto NO requiere contraseña
            TextButton(
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              child: const Text("Cambiar foto"),
            ),

            const SizedBox(height: 20),

            // 📝 CAMPOS DE EDICIÓN PERMANENTE
            _buildSimpleField(
              controller: _nombre,
              labelText: "Nombre",
            ),
            const SizedBox(height: 15),

            _buildSimpleField(
              controller: _apellido,
              labelText: "Apellido",
            ),
            const SizedBox(height: 15),

            _buildSimpleField(
              controller: _curp,
              labelText: "CURP",
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 15),

            // 🔒 CAMPO CORREO (Deshabilitado)
            _buildSimpleField(
              controller: _email,
              labelText: "Correo",
              enabled: false,
            ),

            // ... (Botones de Correo y Contraseña sin cambios)
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

            // ... (Botón Guardar)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                // Ahora solo se deshabilita si está guardando
                onPressed: _saving ? null : _saveProfile,
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Guardar"),
              ),
            ),

            // ❌ REMOVIDO: El mensaje de ayuda del lápiz/X.
          ],
        ),
      ),
    );
  }
}