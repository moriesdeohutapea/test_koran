import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_koran/extension.dart';
import 'package:test_koran/tier_screen.dart';

import 'auth_service.dart';
import 'component/text_view.dart';
import 'model/data_model.dart';

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

  void _navigateToTierScreen() {
    if (_testResults.isNotEmpty) {
      final tierData = _testResults.first;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TierScreen(
            data: DataModel(
              accuracy: (tierData['accuracy'] ?? 0).toInt(),
              // Cast to int
              averageResponseTime:
                  (tierData['average_response_time'] ?? 0.0).toDouble(),
              // Ensure it's a double
              scoreCorrect: (tierData['score_correct'] ?? 0).toInt(),
              // Cast to int
              scoreWrong: (tierData['score_wrong'] ?? 0).toInt(),
              // Cast to int
              selectedTime: tierData['selected_time'] ?? 'N/A',
              timestamp: DateTime.parse(tierData['timestamp']),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTestResultItem(Map<String, dynamic> result) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: CustomText(
          text: 'Test pada ${result['timestamp'].toString().toUserFriendlyDate()}',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(text: 'Benar: ${result['score_correct']}'),
            CustomText(text: 'Salah: ${result['score_wrong']}'),
            if (widget.collectionField == 'oddEvenTestResults') ...[
              const CustomText(
                text: 'Jenis Tes: Ganjil/Genap',
                fontWeight: FontWeight.bold,
              ),
              CustomText(
                text:
                    'Waktu rata-rata: ${result['average_response_time'].toString().roundToDecimals(3)} detik',
              ),
              CustomText(
                text: 'Akurasi: ${result['accuracy']}%',
              ),
            ] else if (widget.collectionField == 'testResults') ...[
              const CustomText(
                text: 'Jenis Tes: Tes Koran',
                fontWeight: FontWeight.bold,
              ),
              if (result.containsKey('average_response_time'))
                CustomText(
                  text:
                      'Waktu rata-rata: ${result['average_response_time'].toString().roundToDecimals(3)} detik',
                ),
              if (result.containsKey('accuracy'))
                CustomText(
                  text: 'Akurasi: ${result['accuracy']}%',
                ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Riwayat Tes',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navigateToTierScreen,
            tooltip: 'Lihat Tiering',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _testResults.isEmpty
              ? const Center(
                  child: CustomText(
                      text: 'Tidak ada riwayat tes ditemukan.', fontSize: 16))
              : ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    return _buildTestResultItem(_testResults[index]);
                  },
                ),
    );
  }
}
