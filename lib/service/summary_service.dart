import '../model/data_model.dart';

class SummaryService {
  SummaryDataModel calculateSummary(List<Map<String, dynamic>> testResults) {
    int totalCorrect = 0;
    int totalWrong = 0;
    double totalResponseTime = 0.0;

    for (var result in testResults) {
      totalCorrect += (result['score_correct'] as num?)?.toInt() ?? 0;
      totalWrong += (result['score_wrong'] as num?)?.toInt() ?? 0;

      totalResponseTime +=
          (result['average_response_time'] as num?)?.toDouble() ?? 0.0;
    }

    int totalTests = testResults.length;
    double averageResponseTime =
        totalTests > 0 ? totalResponseTime / totalTests : 0.0;
    double overallAccuracy = (totalCorrect + totalWrong) > 0
        ? (totalCorrect / (totalCorrect + totalWrong)) * 100
        : 0.0;

    return SummaryDataModel(
      totalCorrect: totalCorrect,
      totalWrong: totalWrong,
      averageResponseTime: averageResponseTime,
      overallAccuracy: overallAccuracy,
    );
  }
}
