class DataModel {
  final int accuracy;
  final double averageResponseTime;
  final int scoreCorrect;
  final int scoreWrong;
  final String selectedTime;
  final DateTime timestamp;

  DataModel({
    required this.accuracy,
    required this.averageResponseTime,
    required this.scoreCorrect,
    required this.scoreWrong,
    required this.selectedTime,
    required this.timestamp,
  });
}

class SummaryDataModel {
  final int totalCorrect;
  final int totalWrong;
  final double averageResponseTime;
  final double overallAccuracy;

  SummaryDataModel({
    required this.totalCorrect,
    required this.totalWrong,
    required this.averageResponseTime,
    required this.overallAccuracy,
  });
}