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
