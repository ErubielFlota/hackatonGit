const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https"); // Necesario para recibir la petición de la app
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { SessionsClient } = require("@google-cloud/dialogflow-cx"); // Cliente de Dialogflow

initializeApp();
const db = getFirestore();

// ==========================================
// CONFIGURACIÓN DE DIALOGFLOW CX
// ==========================================
// TODO: Reemplaza estos valores con los de tu agente
const location = "us-central1"; // Ej: us-central1, global, etc.
const agentId = "1d0a0cfd-ae1b-4fec-847b-23f8fddf6241"; // Copia el ID de tu agente desde la consola de Dialogflow

// El Project ID se toma automáticamente del entorno de Firebase, 
// pero si prefieres ponerlo manual: const projectId = "tu-proyecto-id";
const projectId = process.env.GCLOUD_PROJECT; 

const client = new SessionsClient({ apiEndpoint: `${location}-dialogflow.googleapis.com` });

// ==========================================
// NUEVA FUNCIÓN: GATEWAY DE AUDIO (VOZ)
// ==========================================
exports.dialogflowAudioGateway = onRequest(async (req, res) => {
    // Manejo básico de métodos
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed');
        return;
    }

    try {
        const { audioBase64, sessionId } = req.body;

        // Construir la ruta de la sesión
        const sessionPath = client.projectLocationAgentSessionPath(
            projectId,
            location,
            agentId,
            sessionId
        );

        // Configurar la solicitud a Dialogflow CX
        const request = {
            session: sessionPath,
            queryInput: {
                audio: {
                    config: {
                        audioEncoding: "AUDIO_ENCODING_LINEAR_16", // Formato WAV que enviamos desde Flutter
                        sampleRateHertz: 16000, 
                    },
                    audio: audioBase64, // El audio en Base64
                },
                languageCode: "es", // Idioma español
            },
            outputAudioConfig: {
                audioEncoding: "OUTPUT_AUDIO_ENCODING_MP3", // Queremos respuesta en MP3
            },
        };

        // Enviar a Dialogflow y esperar respuesta
        const [response] = await client.detectIntent(request);

        // Extraer texto y audio de la respuesta
        const responseText = response.queryResult.responseMessages[0]?.text?.text[0] || "No entendí, ¿puedes repetir?";
        const responseAudio = response.outputAudio; 

        // Responder a la App Flutter
        res.status(200).send({
            text: responseText,
            // Convertimos el buffer de audio a Base64 para enviarlo por JSON
            audio: responseAudio ? responseAudio.toString('base64') : null
        });

    } catch (error) {
        console.error("Error interactuando con Dialogflow CX:", error);
        res.status(500).send({ error: error.message });
    }
});


// ==========================================
// TUS FUNCIONES EXISTENTES (FIRESTORE)
// ==========================================

exports.notificarNuevoPrograma = onDocumentCreated("programas_sociales/{programaId}", (event) => {
    const snapshot = event.data;

    if (!snapshot) {
        return;
    }

    const nuevoPrograma = snapshot.data();
    const nombre = nuevoPrograma.nombre_programa || 'Programa sin nombre';

    return db.collection('notificaciones_generales').add({
        titulo: '¡Nuevo Programa Disponible!',
        mensaje: `Se ha agregado el programa "${nombre}" al catálogo.`,
        fecha: FieldValue.serverTimestamp(),
        programaId: event.params.programaId, 
        tipo: 'nuevo'
    });
});

exports.notificarCambioEstatus = onDocumentUpdated("programas_sociales/{programaId}", (event) => {
    if (!event.data) {
        return;
    }

    const antes = event.data.before.data();
    const ahora = event.data.after.data();

    const estadoAnterior = antes.estado_actual_programa ? antes.estado_actual_programa.toLowerCase() : '';
    const estadoNuevo = ahora.estado_actual_programa ? ahora.estado_actual_programa.toLowerCase() : '';

    if (estadoAnterior.includes('finalizado') && estadoNuevo.includes('vigente')) {
        
        const nombre = ahora.nombre_programa || 'Programa';

        return db.collection('notificaciones_generales').add({
            titulo: 'Programa Reactivado',
            mensaje: `El programa "${nombre}" vuelve a estar Vigente. ¡Revisa los requisitos!`,
            fecha: FieldValue.serverTimestamp(),
            programaId: event.params.programaId,
            tipo: 'actualizacion'
        });
    }
    return null;
});