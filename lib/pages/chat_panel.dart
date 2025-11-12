import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/dialogflow_service.dart';
import '../services/faq_service.dart';

class ChatPanel extends StatefulWidget {
  final VoidCallback onClose;
  const ChatPanel({super.key, required this.onClose});

  @override
  State<ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final List<_Message> _messages = [];
  late final FaqService _faqService;
  bool _dfReady = false; 

 
  final DialogflowService _dialogflowService = DialogflowService();

  @override
  void initState() {
    super.initState();
    _faqService = FaqService();
    _faqService.init();
    _initDialogflow();
  }

  
  Future<void> _initDialogflow() async {
    try {
      
      await _dialogflowService.init();

      setState(() => _dfReady = true);
      debugPrint('Dialogflow inicializado correctamente.');
    } catch (e) {
      setState(() => _dfReady = false);
      debugPrint('Error al inicializar Dialogflow: $e');
    }
  }

  
  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    
    setState(() => _messages.add(_Message(text: text, fromUser: true)));
    _controller.clear();

    final connectivity = await Connectivity().checkConnectivity();
    final online = connectivity != ConnectivityResult.none;

    if (online && _dfReady) {
      try {
        final reply = await _dialogflowService.sendMessage(text);

        if (reply.isNotEmpty &&
            !reply.contains("Error:") &&
            !reply.contains("No se recibió")) {
          setState(() => _messages.add(_Message(text: reply, fromUser: false)));
          return;
        }
      } catch (e) {
        debugPrint('Error al obtener respuesta de Dialogflow: $e');
      }
    }

    final faqAnswer = await _faqService.searchBestMatch(text);
    if (faqAnswer != null) {
      setState(() => _messages.add(_Message(text: faqAnswer, fromUser: false)));
    } else {
      setState(() => _messages.add(_Message(
          text: "Lo siento, no tengo una respuesta local. Intenta más tarde.",
          fromUser: false)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      child: Container(
        color: Colors.white,
        child: SafeArea(
          child: Column(
            children: [
             
              ListTile(
                leading: CircleAvatar(child: Icon(Icons.smart_toy)),
                title: Text('Chatbot'),
                trailing: IconButton(
                    icon: Icon(Icons.close), onPressed: widget.onClose),
              ),
              Divider(height: 1),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    return Align(
                      alignment:
                          m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: m.fromUser
                              ? Colors.blue.shade100
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(m.text),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _dfReady
                              ? 'Escribe un mensaje'
                              : 'Inicializando bot...',
                        ),
                        onSubmitted: _send,
                        enabled: _dfReady,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed:
                          _dfReady ? () => _send(_controller.text) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Message {
  final String text;
  final bool fromUser;
  _Message({required this.text, this.fromUser = false});
}