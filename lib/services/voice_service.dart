import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // URL de tu Cloud Function
  final String _functionUrl = "https://us-central1-pruebahackaton-bfb64.cloudfunctions.net/dialogflowAudioGateway";

  // Método para detener cualquier reproducción de audio actual
  // <<< NUEVO: Esto permite callar al bot al cerrar el chat o grabar de nuevo
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Error al detener audio: $e");
    }
  }

  Future<void> startRecording() async {
    // 1. Detenemos al bot si estaba hablando antes de empezar a grabar
    await stopAudio(); 

    // Verificar permisos
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) return;

    // Obtener directorio temporal
    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/user_query.wav';

    // Configuración para Dialogflow (WAV 16kHZ)
    const config = RecordConfig(
      encoder: AudioEncoder.wav, 
      sampleRate: 16000, 
      numChannels: 1,
    );

    // Iniciar grabación
    if (await _audioRecorder.hasPermission()) {
      await _audioRecorder.start(config, path: path);
    }
  }

  Future<Map<String, dynamic>?> stopRecordingAndSend(String sessionId) async {
    final path = await _audioRecorder.stop();

    if (path != null) {
      File audioFile = File(path);
      List<int> audioBytes = await audioFile.readAsBytes();
      String audioBase64 = base64Encode(audioBytes);

      // Enviar a Cloud Function
      try {
        final response = await http.post(
          Uri.parse(_functionUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': sessionId,
            'audioBase64': audioBase64,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Reproducir audio de respuesta automáticamente
          if (data['audio'] != null) {
            playResponseAudio(data['audio']);
          }
          return data; // Retorna data para que actualices tu UI con el texto
        }
      } catch (e) {
        print("Error enviando audio: $e");
      }
    }
    return null;
  }

  Future<void> playResponseAudio(String base64String) async {
    // <<< MODIFICADO: Primero nos aseguramos que no haya otro audio sonando
    await stopAudio(); 
    
    Uint8List bytes = base64Decode(base64String);
    await _audioPlayer.play(BytesSource(bytes));
  }
}