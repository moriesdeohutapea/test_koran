import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveData({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
      print("Data berhasil disimpan di Firestore: $collection/$documentId");
    } catch (e) {
      print("Gagal menyimpan data ke Firestore ($collection/$documentId): $e");
    }
  }

  Future<void> addDataToList({
    required String collection,
    required String documentId,
    required String field,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(documentId).update({
        field: FieldValue.arrayUnion([data]),
      });
      print("Data berhasil ditambahkan ke list di Firestore.");
    } catch (e) {
      print("Error saat menambahkan data ke list di Firestore: $e");
    }
  }

  /// Mengambil data dari Firestore berdasarkan koleksi dan ID dokumen.
  Future<Map<String, dynamic>?> getData({
    required String collection,
    required String documentId,
  }) async {
    try {
      final docSnapshot =
          await _firestore.collection(collection).doc(documentId).get();
      return docSnapshot.data();
    } catch (e) {
      print(
          "Gagal mengambil data dari Firestore ($collection/$documentId): $e");
      return null;
    }
  }
}
