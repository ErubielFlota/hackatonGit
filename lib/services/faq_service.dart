import 'package:cloud_firestore/cloud_firestore.dart';

class FaqService {
  final _col = FirebaseFirestore.instance.collection('faqs');

  Future<void> init() async {
    // Firestore móvil mantiene caché por defecto.
    // Opcional: pre-cargar o escuchar cambios:
    // _col.snapshots().listen(...);
  }

  Future<String?> searchBestMatch(String userText) async {
    final tokens = userText.toLowerCase().split(RegExp(r'\s+')).where((t) => t.length > 2).toList();
    if (tokens.isEmpty) return null;

    // Estrategia simple: buscar documentos que contengan alguna palabra en 'question'
    // Para mejor matching usa algoritmos de similitud o embeddings en el futuro.
    final snapshot = await _col.get(); // lee desde cache si offline disponible
    for (final doc in snapshot.docs) {
      final question = (doc.data()['question'] ?? '').toString().toLowerCase();
      // cuenta coincidencias
      int matches = tokens.where((t) => question.contains(t)).length;
      if (matches > 0) {
        return doc.data()['answer'] as String?;
      }
    }
    return null;
  }

  // Métodos para administrar FAQs (opcional)
  Future<void> addFaq(String q, String a) => _col.add({'question': q, 'answer': a});
  Future<List<QueryDocumentSnapshot>> allFaqs() async => (await _col.get()).docs;
}
