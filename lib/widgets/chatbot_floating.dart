import 'package:flutter/material.dart';
import 'package:prueba2app/pages/chat_panel.dart';
import 'package:prueba2app/theme/colors.dart';

class ChatbotFloating extends StatefulWidget {
  final bool isGuest; // ← NUEVO

  const ChatbotFloating({super.key, required this.isGuest});

  @override
  State<ChatbotFloating> createState() => _ChatbotFloatingState();
}

class _ChatbotFloatingState extends State<ChatbotFloating> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    // ← SI ES INVITADO, NO SE MUESTRA NADA
    if (widget.isGuest) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      right: 20,
      child: _isOpen
          ? SizedBox(
              width: 320,
              height: 420,
              child: ChatPanel(onClose: () {
                setState(() => _isOpen = false);
              }),
            )
          : FloatingActionButton(
              backgroundColor: primaryColor.darker,
              onPressed: () => setState(() => _isOpen = true),
              child: Icon(Icons.chat, color: primaryColor.lighter),
            ),
    );
  }
}
