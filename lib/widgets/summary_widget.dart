import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../auth_service.dart';
import '../component/text_view.dart';
import '../model/data_model.dart';
import '../service/summary_service.dart';

class SummaryWidget extends StatefulWidget {
  const SummaryWidget({super.key});

  @override
  _SummaryWidgetState createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  final AuthService _authService = AuthService();
  final SummaryService _summaryService = SummaryService();
  bool _isLoading = true;
  SummaryDataModel? _summaryData;

  @override
  void initState() {
    super.initState();
    _fetchAndCalculateSummary();
  }

  Future<void> _fetchAndCalculateSummary() async {
    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final data = doc.data();
      if (data != null && data['testResults'] != null) {
        List<Map<String, dynamic>> testResults =
            List<Map<String, dynamic>>.from(data['testResults']);

        // Calculate summary data
        final summaryData = _summaryService.calculateSummary(testResults);

        setState(() {
          _summaryData = summaryData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _summaryData == null
            ? const Center(
                child:
                    CustomText(text: 'No test data available.', fontSize: 16))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSummaryCard(
                    title: 'Total Correct Answers',
                    value: _summaryData!.totalCorrect.toString(),
                  ),
                  _buildSummaryCard(
                    title: 'Total Wrong Answers',
                    value: _summaryData!.totalWrong.toString(),
                  ),
                  _buildSummaryCard(
                    title: 'Average Response Time',
                    value:
                        '${_summaryData!.averageResponseTime.toStringAsFixed(2)} seconds',
                  ),
                  _buildSummaryCard(
                    title: 'Overall Accuracy',
                    value:
                        '${_summaryData!.overallAccuracy.toStringAsFixed(2)}%',
                  ),
                ],
              );
  }

  Widget _buildSummaryCard({required String title, required String value}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: value,
              fontSize: 16,
            ),
          ],
        ),
      ),
    );
  }
}
