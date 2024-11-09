import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'fire_store_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Login berhasil untuk email: $email");
    } catch (e) {
      print("Error during login: $e");
      rethrow;
    }
  }

  Future<String?> getUserName() async {
    final userId = getCurrentUserId();
    if (userId == null) return null;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      return doc.data()?['name'] as String?;
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  Future<void> signUpWithEmail(
      String email, String password, String name, int age) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user?.uid;
      if (userId != null) {
        await _firestoreService.saveData(
          collection: 'users',
          documentId: userId,
          data: {
            'name': name,
            'email': email,
            'age': age,
          },
        );
        print("Registrasi berhasil dan data pengguna disimpan di Firestore.");
      }
    } catch (e) {
      print("Error during registration: $e");
      rethrow;
    }
  }

  Future<void> logTestResult({
    required int scoreCorrect,
    required int scoreWrong,
    required double averageResponseTime,
    required double accuracy,
  }) async {
    final userId = getCurrentUserId();
    if (userId != null) {
      final testResult = {
        'score_correct': scoreCorrect,
        'score_wrong': scoreWrong,
        'average_response_time': averageResponseTime,
        'accuracy': accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _firestoreService.addDataToList(
        collection: 'users',
        documentId: userId,
        field: 'testResults',
        data: testResult,
      );
    }
  }

  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  Future<bool> isUserLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    print("Logout berhasil.");
  }

  Future<void> logOddEvenTestResult({
    required int scoreCorrect,
    required int scoreWrong,
    required String selectedTime,
    required double averageResponseTime,
    required double accuracy,
  }) async {
    final userId = getCurrentUserId();
    if (userId != null) {
      final testResult = {
        'score_correct': scoreCorrect,
        'score_wrong': scoreWrong,
        'selected_time': selectedTime,
        'average_response_time': averageResponseTime,
        'accuracy': accuracy,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await FirestoreService().addDataToList(
        collection: 'users',
        documentId: userId,
        field: 'oddEvenTestResults',
        data: testResult,
      );
    }
  }
}
