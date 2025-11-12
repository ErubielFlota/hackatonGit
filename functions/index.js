// --- IMPORTACIONES BÁSICAS ---
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const express = require("express");
const cors = require("cors");
const bodyParser = require("body-parser");
const { SessionsClient } = require("@google-cloud/dialogflow");

// Inicializar Firebase Admin
admin.initializeApp();

// Configurar Express
const app = express();
app.use(cors({ origin: true }));
app.use(bodyParser.json());

// --- CONFIGURA AQUÍ TU PROJECT ID Y ID DEL AGENTE DE DIALOGFLOW ---
const PROJECT_ID = "pruebahackaton-bfb64"; // <-- Tu Project ID de Firebase
const SESSION_ID = "flutter_chat_session"; // Puede ser cualquiera
const LANGUAGE_CODE = "es"; // Español

// --- ¡AQUÍ! - INICIALIZACIÓN DEL CLIENTE DE DIALOGFLOW ---
// Se saca del endpoint para que sea más eficiente y no se cree en cada llamada.
// Y se usa tu keyFilename para la autenticación.
const sessionClient = new SessionsClient({
  projectId: PROJECT_ID,
  keyFilename: "./service-account.json", // <-- ¡ASEGÚRATE DE INCLUIR ESTE ARCHIVO!
});
// -----------------------------------------------------------------


// --- ENDPOINT PRINCIPAL DEL CHATBOT ---
app.post("/api/dialogflow", async (req, res) => {
  try {
    const userMessage = req.body.message;

    if (!userMessage) {
      return res.status(400).json({ error: "Falta el mensaje del usuario" });
    }

    // --- ¡AQUÍ! ---
    // Se elimina la inicialización de "sessionClient" de este lugar.
    // Ya lo creamos arriba y lo estamos reutilizando.

    const sessionPath = sessionClient.projectAgentSessionPath(
      PROJECT_ID,
      SESSION_ID
    );

    // Enviar texto a Dialogflow
    const request = {
      session: sessionPath,
      queryInput: {
        text: {
          text: userMessage,
          languageCode: LANGUAGE_CODE,
        },
      },
    };

    const responses = await sessionClient.detectIntent(request);
    const result = responses[0].queryResult;

    // Devolver respuesta del bot
    res.json({
      query: result.queryText,
      response: result.fulfillmentText,
    });
  } catch (error) {
    console.error("Error al conectar con Dialogflow:", error);
    res.status(500).json({ error: "Error interno del servidor" });
  }
});

// --- EXPORTAR FUNCIÓN PARA FIREBASE ---
exports.api = functions.https.onRequest(app);