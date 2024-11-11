import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../component/text_view.dart';
import '../model/data_model.dart';

class TierScreen extends StatelessWidget {
  final DataModel data;
  final ScreenshotController screenshotController = ScreenshotController();

  TierScreen({super.key, required this.data});

  List<ChartData> _generateTierData() {
    return [
      ChartData('Accuracy', _tierValue(data.accuracy)),
      ChartData('Avg Response', _tierValue(data.averageResponseTime)),
      ChartData('Correct', _tierValue(data.scoreCorrect)),
      ChartData('Wrong', _tierValue(data.scoreWrong)),
    ];
  }

  double _tierValue(num value) {
    if (value >= 80) return 3; // High
    if (value >= 50) return 2; // Medium
    return 1; // Low
  }

  Future<void> _shareScreenshot() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final directory = await Directory.systemTemp.createTemp();
        final imagePath = '${directory.path}/tier_screen.jpg';
        final imageFile = File(imagePath)..writeAsBytesSync(image);

        await Share.shareXFiles(
          [XFile(imageFile.path)],
          text: 'Check out my Tier Information!',
        );
      }
    } catch (e) {
      print("Error capturing and sharing screenshot: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const CustomText(
          text: 'Tier Information',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareScreenshot,
            tooltip: 'Share Tier Info',
          ),
        ],
      ),
      body: Screenshot(
        controller: screenshotController,
        child: RepaintBoundary(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const CustomText(
                    text: 'Performance Overview',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      primaryYAxis: NumericAxis(
                        minimum: 0,
                        maximum: 3,
                        interval: 1,
                        title: AxisTitle(
                          text: 'Tier Level',
                          textStyle: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        labelFormat: '{value}',
                      ),
                      series: <ChartSeries>[
                        LineSeries<ChartData, String>(
                          dataSource: _generateTierData(),
                          xValueMapper: (ChartData data, _) => data.metric,
                          yValueMapper: (ChartData data, _) => data.tierValue,
                          markerSettings: const MarkerSettings(isVisible: true),
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTierSummary(),
                  const SizedBox(height: 20),
                  CustomText(
                    text: 'Timestamp: ${data.timestamp}',
                    fontSize: 16,
                    color: Colors.grey,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTierCard(
          icon: Icons.check_circle,
          title: 'Accuracy',
          value: '${data.accuracy}%',
          color: _getTierColor(data.accuracy),
        ),
        const SizedBox(height: 10),
        _buildTierCard(
          icon: Icons.timer,
          title: 'Avg Response Time',
          value: '${data.averageResponseTime.toStringAsFixed(2)} s',
          color: _getTierColor(data.averageResponseTime),
        ),
        const SizedBox(height: 10),
        _buildTierCard(
          icon: Icons.thumb_up,
          title: 'Score Correct',
          value: '${data.scoreCorrect}',
          color: _getTierColor(data.scoreCorrect),
        ),
        const SizedBox(height: 10),
        _buildTierCard(
          icon: Icons.thumb_down,
          title: 'Score Wrong',
          value: '${data.scoreWrong}',
          color: _getTierColor(data.scoreWrong),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: title,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  const SizedBox(height: 4),
                  CustomText(
                    text: value,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTierColor(num value) {
    if (value is double) {
      if (value <= 1.5) return Colors.green;
      if (value <= 3.0) return Colors.orange;
      return Colors.red;
    } else {
      if (value >= 80) return Colors.green;
      if (value >= 50) return Colors.orange;
      return Colors.red;
    }
  }
}

class ChartData {
  final String metric;
  final double tierValue;

  ChartData(this.metric, this.tierValue);
}
