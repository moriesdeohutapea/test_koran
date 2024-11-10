import 'package:flutter/material.dart';

import 'component/text_view.dart';
import 'model/data_model.dart';
import 'tiering_service.dart';

class TierScreen extends StatelessWidget {
  final DataModel data;
  final TieringService tieringService = TieringService();

  TierScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Data Tiering',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTierCard(
              title: 'Accuracy',
              value: '${data.accuracy}%',
              tier: tieringService.getAccuracyTier(data.accuracy),
            ),
            _buildTierCard(
              title: 'Avg Response Time',
              value: '${data.averageResponseTime.toStringAsFixed(2)}s',
              tier:
                  tieringService.getResponseTimeTier(data.averageResponseTime),
            ),
            _buildTierCard(
              title: 'Score Correct',
              value: '${data.scoreCorrect}',
              tier: tieringService.getScoreCorrectTier(data.scoreCorrect),
            ),
            _buildTierCard(
              title: 'Score Wrong',
              value: '${data.scoreWrong}',
              tier: tieringService.getScoreWrongTier(data.scoreWrong),
            ),
            _buildTierCard(
              title: 'Selected Time',
              value: data.selectedTime,
              tier: 'N/A', // No specific tier for Selected Time
            ),
            SizedBox(height: 20),
            CustomText(
              text: 'Timestamp: ${data.timestamp}',
              fontSize: 16,
              color: Colors.grey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierCard(
      {required String title, required String value, required String tier}) {
    Color tierColor;
    switch (tier) {
      case 'High':
        tierColor = Colors.green;
        break;
      case 'Medium':
        tierColor = Colors.orange;
        break;
      case 'Low':
        tierColor = Colors.red;
        break;
      default:
        tierColor = Colors.blueGrey;
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tierColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: title,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: tierColor,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: value,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            CustomText(
              text: 'Tier: $tier',
              fontSize: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
