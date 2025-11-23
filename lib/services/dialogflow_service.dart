import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis/dialogflow/v3.dart' as cx;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:uuid/uuid.dart';

class DialogflowService {
  
  final String _locationId = 'us-central1';

  // ID DE AGENTE
  final String _agentId = '1d0a0cfd-ae1b-4fec-847b-23f8fddf6241'; 

  // ID DE ENTORNO "PRODUCCION"
  final String _environmentId = 'd78da970-5a2c-4d1d-b62b-1ffd0f2b83cc'; 

  final String _credentialsFile =
      'assets/pruebahackaton-bfb64-cb3dbd690d75.json';

  late auth.AutoRefreshingAuthClient _httpClient;
  late String _projectId;
  late String _sessionId;
  bool _isInitialized = false;

  DialogflowService() {
    _sessionId = Uuid().v4();
  }

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      final raw = await rootBundle.loadString(_credentialsFile);
      final Map<String, dynamic> jsonMap = json.decode(raw);

      final credentials = auth.ServiceAccountCredentials.fromJson(jsonMap);

      final client = await auth.clientViaServiceAccount(
        credentials,
        [cx.DialogflowApi.dialogflowScope],
      );

      _httpClient = client;
      final pid = jsonMap['project_id'] ?? jsonMap['projectId'] ?? '';
      if (pid is! String || pid.isEmpty) {
        throw StateError(
            'No se encontró el project_id en el JSON de credenciales.');
      }
      _projectId = pid;

      _isInitialized = true;
      print("DialogflowService (CX) inicializado correctamente.");
      print("   Usando Proyecto: $_projectId");
      print("   Usando Agente: $_agentId");
      print("   Usando Entorno: $_environmentId");
      print("   Usando Sesión: $_sessionId");
    } catch (e) {
      print("Error al inicializar DialogflowService: $e");
      print("   Asegúrate de que '$_credentialsFile' exista en 'assets/'");
      print(
          "   y que las variables _locationId, _agentId y _environmentId sean correctas.");
      rethrow;
    }
  }

  Future<String> sendMessage(String text) async {
    print("--- INTENTANDO ENVIAR MENSAJE: '$text' ---");
    if (!_isInitialized) {
    
      throw StateError(
          'DialogflowService no inicializado. Llama a init() antes.');
    }

    // RUTA DEL ENTORNO "URL"
    final String sessionPath =
        'projects/$_projectId/locations/$_locationId/agents/$_agentId/environments/$_environmentId/sessions/$_sessionId';

    final String regionalEndpoint = 'https://$_locationId-dialogflow.googleapis.com/';
    final api = cx.DialogflowApi(_httpClient, rootUrl: regionalEndpoint);

    final request = cx.GoogleCloudDialogflowCxV3DetectIntentRequest.fromJson({
      'queryInput': {
        'text': {
          'text': text,
        },
        'languageCode': 'es',
      }
    });

    try {
      final response = await api.projects.locations.agents.sessions.detectIntent(
        request,
        sessionPath,
      );

      if (response.queryResult?.responseMessages != null &&
          response.queryResult!.responseMessages!.isNotEmpty) {
        var textMessages = response.queryResult!.responseMessages!
            .where((message) => message.text != null && message.text!.text != null && message.text!.text!.isNotEmpty);

        if (textMessages.isNotEmpty) {
          return textMessages
              .map((message) => message.text!.text!.join('\n'))
              .join('\n');
        }
      }

      return "No se recibió una respuesta de texto del agente.";
    } catch (e) {
      print("Error al llamar a detectIntent: $e");
      rethrow;
    }
  }
}