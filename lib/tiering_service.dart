class TieringService {
  String getAccuracyTier(int accuracy) {
    if (accuracy >= 80) return 'High';
    if (accuracy >= 50) return 'Medium';
    return 'Low';
  }

  String getResponseTimeTier(double time) {
    if (time < 0.1) return 'High';
    if (time <= 0.5) return 'Medium';
    return 'Low';
  }

  String getScoreCorrectTier(int score) {
    if (score >= 40) return 'High';
    if (score >= 20) return 'Medium';
    return 'Low';
  }

  String getScoreWrongTier(int score) {
    if (score < 10) return 'High';
    if (score <= 30) return 'Medium';
    return 'Low';
  }
}
