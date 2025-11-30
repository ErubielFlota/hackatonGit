import 'package:flutter/material.dart';
import 'package:prueba2app/pages/chat_panel.dart';
import 'package:prueba2app/theme/colors.dart';

class ChatbotFloating extends StatefulWidget {
  final bool isGuest;

  const ChatbotFloating({super.key, required this.isGuest});

  @override
  State<ChatbotFloating> createState() => _ChatbotFloatingState();
}

class _ChatbotFloatingState extends State<ChatbotFloating> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    // Tamaños responsivos
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ajustes para pantallas pequeñas
    final panelWidth = screenWidth * 0.85;    
    final panelHeight = screenHeight * 0.55; 

    
    final fabSize = screenWidth * 0.16; 

    if (widget.isGuest) return const SizedBox.shrink();

    return Positioned(
      bottom: screenHeight * 0.03, 
      right: screenWidth * 0.04,  
      child: _isOpen
          ? SizedBox(
              width: panelWidth,
              height: panelHeight,
              child: ChatPanel(
                onClose: () {
                  setState(() => _isOpen = false);
                },
              ),
            )
          : SizedBox(
              width: fabSize,
              height: fabSize,
              child: FloatingActionButton(
                backgroundColor: primaryColor.darker,
                onPressed: () => setState(() => _isOpen = true),
                child: Transform.scale(
                  scale:0.7,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/leoncibotv2.png',
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

