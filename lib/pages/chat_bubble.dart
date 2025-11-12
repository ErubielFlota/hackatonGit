import 'package:flutter/material.dart';
import 'chat_panel.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _open = false;

  void _togglePanel() {
    setState(() => _open = !_open);
    if (_open) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              heightFactor: 1.0,
              child: ChatPanel(onClose: () {
                Navigator.of(context).pop();
                setState(() => _open = false);
              }),
            ),
          ),
        ),
      ).then((_) => setState(() => _open = false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: _togglePanel,
        child: CircleAvatar(
          radius: 28,
          child: Icon(Icons.chat_bubble_outline),
        ),
      ),
    );
  }
}
