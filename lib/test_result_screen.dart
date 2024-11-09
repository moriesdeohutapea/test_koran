import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'auth_service.dart';

class TestResultsScreen extends StatefulWidget {
  final String collectionField;

  const TestResultsScreen({super.key, required this.collectionField});

  @override
  _TestResultsScreenState createState() => _TestResultsScreenState();
}

class _TestResultsScreenState extends State<TestResultsScreen> {
  final AuthService _authService = AuthService();
  List<Map<String, dynamic>> _testResults = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTestResults();
  }

  Future<void> _fetchTestResults() async {
    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final data = doc.data();
      if (data != null && data[widget.collectionField] != null) {
        setState(() {
          _testResults =
              List<Map<String, dynamic>>.from(data[widget.collectionField]);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTestResultItem(Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text('Test pada ${result['timestamp']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Benar: ${result['score_correct']}'),
            Text('Salah: ${result['score_wrong']}'),
            if (widget.collectionField == 'oddEvenTestResults') ...[
              const Text('Jenis Tes: Ganjil/Genap'),
              Text('Waktu rata-rata: ${result['average_response_time']} detik'),
              Text('Akurasi: ${result['accuracy']}%'),
            ] else if (widget.collectionField == 'testResults') ...[
              const Text('Jenis Tes: Tes Koran'),
              if (result.containsKey('average_response_time'))
                Text(
                    'Waktu rata-rata: ${result['average_response_time']} detik'),
              if (result.containsKey('accuracy'))
                Text('Akurasi: ${result['accuracy']}%'),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Tes')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _testResults.isEmpty
              ? const Center(child: Text('Tidak ada riwayat tes ditemukan.'))
              : ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    return _buildTestResultItem(_testResults[index]);
                  },
                ),
    );
  }
}
