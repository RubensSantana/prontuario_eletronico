// Importações usando a nova sintaxe modular
const { onDocumentCreated } = require('firebase-functions/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');

// Inicializa o Firebase Admin SDK
initializeApp();

// Firestore instance
const db = getFirestore();

// Função: dispara ao criar um novo documento em 'prontuarios/{prontuarioId}'
exports.novaEntradaProntuarioLog = onDocumentCreated('prontuarios/{prontuarioId}', (event) => {
  const snap = event.data;
  if (!snap) {
    console.log('❗ Documento não encontrado.');
    return;
  }

  const data = snap.data();
  const paciente = data?.paciente || 'não informado';
  const descricao = data?.descricao || '';
  const id = event.params.prontuarioId || 'sem-id';

  console.log(`🔔 Cloud Function -> Novo prontuário criado. id=${id}, paciente=${paciente}`);

  // Se quiser registrar em outra coleção (descomente abaixo)
  /*
  return db.collection('logs_prontuarios').add({
    prontuarioId: id,
    paciente,
    descricao,
    createdAt: FieldValue.serverTimestamp(),
  });
  */

  return;
});