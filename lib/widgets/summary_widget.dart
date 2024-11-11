import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../component/text_view.dart';
import '../model/data_model.dart';
import '../service/tiering/summary_service.dart';

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

  Future<void> _refreshSummary() async {
    setState(() {
      _isLoading = true;
    });
    await _fetchAndCalculateSummary();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshSummary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _summaryData == null
                  ? const Center(
                      child: CustomText(
                          text: 'No test data available.', fontSize: 16))
                  : Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.lightBlueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.3),
                            spreadRadius: 4,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSummaryCard(
                            title: 'Total Correct Answers',
                            value: _summaryData!.totalCorrect.toString(),
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                          ),
                          _buildSummaryCard(
                            title: 'Total Wrong Answers',
                            value: _summaryData!.totalWrong.toString(),
                            icon: Icons.cancel_outlined,
                            color: Colors.red,
                          ),
                          _buildSummaryCard(
                            title: 'Avg. Response Time',
                            value:
                                '${_summaryData!.averageResponseTime.toStringAsFixed(2)}s',
                            icon: Icons.timer_outlined,
                            color: Colors.orange,
                          ),
                          _buildSummaryCard(
                            title: 'Overall Accuracy',
                            value:
                                '${_summaryData!.overallAccuracy.toStringAsFixed(2)}%',
                            icon: Icons.insights_outlined,
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        title: CustomText(
          text: title,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        subtitle: CustomText(
          text: value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }
}
