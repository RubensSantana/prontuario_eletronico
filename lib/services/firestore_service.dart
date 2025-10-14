import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prontuario.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> prontuariosCollection =
      FirebaseFirestore.instance.collection('prontuarios');

  Future<void> adicionarProntuario(Prontuario prontuario) async {
    await prontuariosCollection.add(prontuario.toMap());
  }

  Future<void> atualizarProntuario(Prontuario prontuario) async {
    if (prontuario.id != null) {
      await prontuariosCollection.doc(prontuario.id).update(prontuario.toMap());
    }
  }

  Future<void> deletarProntuario(String id) async {
    await prontuariosCollection.doc(id).delete();
  }

  Stream<List<Prontuario>> getProntuarios() {
    return prontuariosCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Prontuario.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<Prontuario?> getProntuarioPorId(String id) async {
    final doc = await prontuariosCollection.doc(id).get();
    if (!doc.exists) return null;
    return Prontuario.fromMap(doc.id, doc.data()!);
  }
}
