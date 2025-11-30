import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba2app/autentificacion.dart';
import 'package:prueba2app/home_page_content.dart';
import 'package:prueba2app/theme/colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  int _notificacionesVistasCount = 0;

  void showNotificationsDialog(BuildContext context) {
    setState(() {
      _notificacionesVistasCount = 999999; 
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Notificaciones"),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notificaciones_generales')
                .orderBy('fecha', descending: true) 
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text("Error al cargar");
              
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("Sin notificaciones nuevas"));
              }

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (ctx, i) => const Divider(),
                itemBuilder: (ctx, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  
                  // Formato de fecha simple
                  String fechaStr = "";
                  if (data['fecha'] != null) {
                    Timestamp t = data['fecha'];
                    DateTime dt = t.toDate();
                    fechaStr = "${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                  }

                  
                  IconData iconNoti = Icons.notifications;
                  Color colorNoti = Colors.blue;
                  
                  if (data['tipo'] == 'nuevo') {
                    iconNoti = Icons.new_releases;
                    colorNoti = Colors.orange;
                  } else if (data['tipo'] == 'actualizacion') {
                    iconNoti = Icons.update;
                    colorNoti = Colors.green;
                  }

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(iconNoti, color: colorNoti),
                    title: Text(
                      data['titulo'] ?? 'Aviso',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['mensaje'] ?? ''),
                        const SizedBox(height: 4),
                        Text(fechaStr, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),
                  );
                },
              );
            },
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

  String _originalNombre = '';
  String _originalApellido = '';
  String _originalCurp = '';

  final _formKey = GlobalKey<FormState>();
  final RegExp _curpRegex = RegExp(r'^[A-Z]{4}\d{6}[HM][A-Z]{5}[0-9A-Z]\d$');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  //  FUNCIÓN _loadUserData
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

        _originalNombre = _nombre.text;
        _originalApellido = _apellido.text;
        _originalCurp = _curp.text;

        
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

  //  FUNCIÓN _saveProfile
  Future<void> _saveProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Detectar si hay cambios
    final bool dataChanged = (_nombre.text.trim() != _originalNombre.trim()) ||
        (_apellido.text.trim() != _originalApellido.trim()) ||
        (_curp.text.trim().toUpperCase() != _originalCurp.trim().toUpperCase());

    final bool photoChanged = profileImageBytes != null;

    if (!dataChanged && !photoChanged) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("No hay cambios para guardar."),
        backgroundColor: Colors.blueAccent,
      ));
      return;
    }

    // Validar CURP
    final curp = _curp.text.trim().toUpperCase();
    if (curp.isNotEmpty && !_validarCurp(curp)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("CURP inválida"),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    String? password;

    // Solicitar contraseña si hay cambios en datos
    if (dataChanged) {
      password = await _confirmPasswordDialog(context);
      if (password == null) return;

      try {
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
        return;
      }
    }

    setState(() => _saving = true);
    print("[DEBUG] Guardando perfil...");

    try {
      final photoUrl = await _uploadProfileImage(user.uid);

      final fullName = "${_nombre.text.trim()} ${_apellido.text.trim()}";
      if (fullName.trim().isNotEmpty) {
        await user.updateDisplayName(fullName);
      } else if (user.displayName != null) {
        await user.updateDisplayName(null);
      }
      await user.reload();

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
            const Text(
                "Ingresa tu contraseña actual para confirmar los cambios en tus datos personales."),
            const SizedBox(height: 10),
            TextField(
                controller: passCtrl,
                decoration: const InputDecoration(labelText: "Contraseña"),
                obscureText: true),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, null),
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
              Navigator.pop(ctx, passCtrl.text);
            },
          )
        ],
      ),
    );
  }

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
          content: Text(e.code == 'email-already-in-use'
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

  Widget _buildSimpleField({
    required TextEditingController controller,
    required String labelText,
    bool enabled = true,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    const primaryColor = Colors.blue;

    return TextField(
      controller: controller,
      enabled: enabled,
      textCapitalization: textCapitalization,
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey[700],
      ),
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
        ),
        disabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isLarge = screenWidth > 600;
   
    final double padding = isLarge ? 32 : 20;
    final double fontBase = isLarge ? 18 : 15;

    //codigo  del usuario no registrado por favor ya no le muevan malditos

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Mi Perfil',
            style: TextStyle(
              color: primaryColor.darker,
              fontWeight: FontWeight.bold,
              fontSize: fontBase + 3,
            ),
          ),
          automaticallyImplyLeading: false,
          backgroundColor: backgroundColor,
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: backgroundColor,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Debes iniciar sesión para acceder a esta página.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontBase + 1,
                    fontWeight: FontWeight.bold,
                  ),
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
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                  ),
                  child: Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: fontBase + 1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(user.displayName ?? "Mi perfil"),
        automaticallyImplyLeading: false,
        actions: [
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('notificaciones_generales')
                .snapshots(),
            builder: (context, snapshot) {
              int totalDocs = 0;
              if (snapshot.hasData) {
                totalDocs = snapshot.data!.docs.length;
              }
              
              
              bool showBadge = totalDocs > 0 && totalDocs > _notificacionesVistasCount;

              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      showNotificationsDialog(context);
                    },
                  ),
                  if (showBadge)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          "!", 
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
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

            //CAMPO CORREO
            _buildSimpleField(
              controller: _email,
              labelText: "Correo",
              enabled: false,
            ),

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

            const SizedBox(height: 30),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),

            // SECCIÓN MIS FAVORITOS
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Mis Programas Favoritos",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800]),
              ),
            ),
            const SizedBox(height: 10),

            // Stream para mostrar favoritos
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('usuarios_registrados')
                  .doc(user.uid)
                  .collection('favoritos')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Text("Error al cargar favoritos");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(Icons.star_outline,
                            size: 50, color: Colors.grey[300]),
                        const Text("Aún no tienes programas favoritos."),
                      ],
                    ),
                  );
                }

                final favoriteDocs = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: favoriteDocs.length,
                  itemBuilder: (context, index) {
                    try {
                      final programa =
                          Programa.fromFirestore(favoriteDocs[index]);
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProgramaDetailPage(programa: programa),
                            ),
                          );
                        },
                        child: ProgramaCard(programa: programa),
                      );
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}