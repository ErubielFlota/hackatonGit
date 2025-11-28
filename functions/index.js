
const { onDocumentCreated, onDocumentUpdated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");


initializeApp();
const db = getFirestore();


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