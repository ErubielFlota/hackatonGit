const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { onRequest } = require("firebase-functions/v2/https"); 
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { SessionsClient } = require("@google-cloud/dialogflow-cx"); 

initializeApp();
const db = getFirestore();

//configuracion de Dialogflow

const location = "us-central1";
const agentId = "1d0a0cfd-ae1b-4fec-847b-23f8fddf6241";

const projectId = process.env.GCLOUD_PROJECT; 

const client = new SessionsClient({ apiEndpoint: `${location}-dialogflow.googleapis.com` });

//funcion de grabado de audio
exports.dialogflowAudioGateway = onRequest(async (req, res) => {
    
    if (req.method !== 'POST') {
        res.status(405).send('Method Not Allowed');
        return;
    }

    try {
        const { audioBase64, sessionId } = req.body;

        
        const sessionPath = client.projectLocationAgentSessionPath(
            projectId,
            location,
            agentId,
            sessionId
        );

        
        const request = {
            session: sessionPath,
            queryInput: {
                audio: {
                    config: {
                        audioEncoding: "AUDIO_ENCODING_LINEAR_16", 
                        sampleRateHertz: 16000, 
                    },
                    audio: audioBase64, 
                },
                languageCode: "es", 
            },
            outputAudioConfig: {
                audioEncoding: "OUTPUT_AUDIO_ENCODING_MP3", 
            },
        };

        
        const [response] = await client.detectIntent(request);

        
        const responseText = response.queryResult.responseMessages[0]?.text?.text[0] || "No entendí, ¿puedes repetir?";
        const responseAudio = response.outputAudio; 

        
        res.status(200).send({
            text: responseText,
            
            audio: responseAudio ? responseAudio.toString('base64') : null
        });

    } catch (error) {
        console.error("Error interactuando con Dialogflow CX:", error);
        res.status(500).send({ error: error.message });
    }
});


//FUNCION NOTIFICACIONES

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