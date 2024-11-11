import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:test_koran/helper/extension.dart';
import 'package:test_koran/ui/tier_screen.dart';

import '../component/text_view.dart';
import '../model/data_model.dart';
import '../service/auth_service.dart';

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
    setState(() => _isLoading = true);
    try {
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
          });
        }
      }
    } catch (e) {
      print("Error fetching test results: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToTierScreen() {
    if (_testResults.isNotEmpty) {
      // Menghitung rata-rata dari seluruh hasil tes
      final averageData = _calculateAverageData();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TierScreen(data: averageData),
        ),
      );
    }
  }

  DataModel _calculateAverageData() {
    double totalAccuracy = 0;
    double totalAverageResponseTime = 0;
    int totalScoreCorrect = 0;
    int totalScoreWrong = 0;

    for (var result in _testResults) {
      totalAccuracy += (result['accuracy'] as num? ?? 0).toDouble();
      totalAverageResponseTime +=
          (result['average_response_time'] as num? ?? 0).toDouble();
      totalScoreCorrect += (result['score_correct'] as num? ?? 0).toInt();
      totalScoreWrong += (result['score_wrong'] as num? ?? 0).toInt();
    }

    int itemCount = _testResults.length;
    return DataModel(
      accuracy: (totalAccuracy / itemCount).round(),
      averageResponseTime: totalAverageResponseTime / itemCount,
      scoreCorrect: totalScoreCorrect,
      scoreWrong: totalScoreWrong,
      selectedTime: 'N/A',
      // Placeholder, bisa disesuaikan
      timestamp: DateTime.now(),
    );
  }

  Widget _buildTestResultItem(Map<String, dynamic> result) {
    final timestamp = result['timestamp'] != null
        ? DateTime.tryParse(result['timestamp'])
        : null;

    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Test pada :\n${timestamp != null ? timestamp.toLocal().toString().toUserFriendlyDate() : 'Unknown Date'}',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildChip('Benar', result['score_correct']?.toString() ?? 'N/A', Colors.green),
                const SizedBox(width: 10),
                _buildChip('Salah', result['score_wrong']?.toString() ?? 'N/A', Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.collectionField == 'oddEvenTestResults') ...[
              const CustomText(
                text: 'Jenis Tes: Ganjil/Genap',
                fontWeight: FontWeight.bold,
              ),
              _buildInfoRow(
                  Icons.timer, 'Waktu rata-rata', '${result['average_response_time']?.toString().roundToDecimals(3) ?? 'N/A'} detik'),
              _buildInfoRow(Icons.check_circle, 'Akurasi', '${result['accuracy'].toString().roundToDecimals(3)}%'),
            ] else if (widget.collectionField == 'testResults') ...[
              const CustomText(
                text: 'Jenis Tes: Tes Koran',
                fontWeight: FontWeight.bold,
              ),
              if (result.containsKey('average_response_time'))
                _buildInfoRow(Icons.timer, 'Waktu rata-rata', '${result['average_response_time']?.toStringAsFixed(2) ?? 'N/A'} detik'),
              if (result.containsKey('accuracy')) _buildInfoRow(Icons.check_circle, 'Akurasi', '${result['accuracy'].toString().roundToDecimals(3)}%'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, String value, Color color) {
    return Chip(
      label: CustomText(text: '$label: $value'),
      backgroundColor: color.withOpacity(0.1),
      avatar: Icon(
        label == 'Benar' ? Icons.check : Icons.close,
        color: color,
        size: 16,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent, size: 18),
          const SizedBox(width: 8),
          CustomText(
            text: '$label: $value',
            fontSize: 16,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const CustomText(
          text: 'Riwayat Tes',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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
                    text: 'Tidak ada riwayat tes ditemukan.',
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                )
              : ListView.builder(
                  itemCount: _testResults.length,
                  itemBuilder: (context, index) {
                    return _buildTestResultItem(_testResults[index]);
                  },
                ),
    );
  }
}
