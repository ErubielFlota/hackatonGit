import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:prueba2app/theme/colors.dart';
import '../services/dialogflow_service.dart';
import '../services/faq_service.dart';
import '../services/voice_service.dart'; // <<< 1. IMPORTAR SERVICIO DE VOZ

class _Message {
  final String? text;
  final bool isWelcomeImage;
  final bool fromUser;

  _Message({
    this.text,
    this.isWelcomeImage = false,
    this.fromUser = false
  });
}

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
  
  // <<< 2. VARIABLES NUEVAS PARA VOZ
  final VoiceService _voiceService = VoiceService(); 
  bool _isRecording = false; 
  // Usa un ID de sesión consistente. Si tu DialogflowService ya tiene uno, intenta usar el mismo.
  // Por ahora generamos uno temporal o usamos uno fijo para pruebas.
  final String _currentSessionId = "session-${DateTime.now().millisecondsSinceEpoch}"; 

  final String botAvatarAsset = 'assets/leoncibot.png';

  @override
  void initState() {
    super.initState();
    _faqService = FaqService();
    _faqService.init();

    _addInitialContent();

    _initDialogflow();
  }

  void _addInitialContent() {
    setState(() {
      _messages.add(_Message(
        isWelcomeImage: true,
        fromUser: false
      ));

      _messages.add(_Message(
        text: "¡Hola! Soy Leoncibot tu aistente ChatBot. ¿En qué puedo ayudarte hoy?👋🏻",
        fromUser: false,
      ));
    });
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
        if (reply.isNotEmpty && !reply.contains("Error:") && !reply.contains("No se recibió")) {
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

  Widget _buildTextBubble(_Message m) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: m.fromUser ? Colors.blue.shade100 : Colors.grey.shade200,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
          bottomLeft: m.fromUser ? Radius.circular(12) : Radius.circular(0),
          bottomRight: m.fromUser ? Radius.circular(0) : Radius.circular(12),
        ),
      ),
      child: Text(m.text ?? '', style: TextStyle(fontSize: 15)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
       borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
           borderRadius: BorderRadius.circular(24),

        ),
        
        child: SafeArea(
          child: Column(
            children: [
              // --- CABECERA ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300))
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(botAvatarAsset),
                      backgroundColor: Colors.grey.shade200,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leoncibot', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Asistente virtual', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(icon: Icon(Icons.close), onPressed: widget.onClose),
                  ],
                ),
              ),

              // --- LISTA DE MENSAJES ---
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];

                    if (m.isWelcomeImage) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  spreadRadius: 2
                                )
                              ]
                            ),
                            child: CircleAvatar(
                              radius: 80,
                              backgroundColor: Colors.grey.shade100,
                              backgroundImage: AssetImage(botAvatarAsset),
                            ),
                          ),
                        ),
                      );
                    }
                    
                    if (m.fromUser) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(child: _buildTextBubble(m)),
                          ],
                        ),
                      );
                    } 
                    
                    else {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(botAvatarAsset),
                              radius: 16, 
                              backgroundColor: Colors.grey.shade200,
                            ),
                            SizedBox(width: 8),
                            Flexible(child: _buildTextBubble(m)),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),

              // --- AREA DE INPUT ---
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                 decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Colors.grey.shade200))
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: _isRecording ? 'Grabando audio...' : (_dfReady ? 'Escribe un mensaje...' : 'Conectando...'), // Feedback visual
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                            borderSide: BorderSide.none
                          ),
                          filled: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          fillColor: _isRecording ? Colors.red.shade50 : Colors.grey.shade100 // Feedback de color
                        ),
                        onSubmitted: _send,
                        enabled: _dfReady && !_isRecording, // Bloquear input si graba
                      ),
                    ),
                    
                    SizedBox(width: 8),

                    // <<< 3. BOTÓN DE MICRÓFONO
                    GestureDetector(
                      onLongPressStart: (_) async {
                        if (!_dfReady) return;
                        setState(() => _isRecording = true);
                        await _voiceService.startRecording();
                        debugPrint("Grabando...");
                      },
                      onLongPressEnd: (_) async {
                        if (!_dfReady) return;
                        setState(() => _isRecording = false);
                        debugPrint("Enviando audio...");
                        
                        // Enviamos el audio y esperamos respuesta JSON
                        final response = await _voiceService.stopRecordingAndSend(_currentSessionId);
                        
                        // Si hay respuesta exitosa
                        if (response != null && response['text'] != null) {
                           setState(() {
                             // Agregamos la respuesta textual del bot al chat
                             _messages.add(_Message(
                               text: response['text'], 
                               fromUser: false
                             ));
                           });
                           // Nota: El audio ya se reproduce automáticamente dentro de voiceService
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: _isRecording ? Colors.red : Colors.blueAccent, // Color cambia al grabar
                        child: Icon(
                          _isRecording ? Icons.mic : Icons.mic_none, 
                          color: Colors.white, 
                          size: 20
                        ),
                      ),
                    ),

                    SizedBox(width: 8),

                    // BOTÓN DE ENVIAR (Original)
                    CircleAvatar(
                      backgroundColor: _dfReady ? primaryColor.darker : Colors.grey,
                      child: IconButton(
                        icon: Icon(Icons.send, color: Colors.white, size: 20),
                        onPressed: _dfReady ? () => _send(_controller.text) : null,
                      ),
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