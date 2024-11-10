import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:test_koran/test_result_screen.dart';

import 'auth_service.dart';
import 'component/custom_button.dart';
import 'fire_store_service.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final AuthService _authService = AuthService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String _currentQuestion;
  late bool _isAnswerCorrect;
  int _scoreCorrect = 0;
  int _scoreWrong = 0;
  int _remainingTime = 60;
  double _accuracy = 0.0;
  Timer? _timer;
  bool _isTestActive = false;
  String _selectedTime = '1 Menit';
  final List<int> _answerTimes = [];
  DateTime? _questionStartTime;

  final Map<String, int> _timeOptions = {
    '30 Detik': 30,
    '1 Menit': 60,
    '1.5 Menit': 90,
    '2 Menit': 120,
  };

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _remainingTime = _timeOptions[_selectedTime]!;
  }

  void _startTest() {
    if (_isTestActive) return;
    setState(() {
      _isTestActive = true;
      _remainingTime = _timeOptions[_selectedTime]!;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _endTest();
      }
    });
  }

  void _endTest() {
    _timer?.cancel();
    setState(() {
      _isTestActive = false;
      _accuracy = _calculateAccuracy();
    });
    _logTestResult();
    _showTestResultsDialog();
  }

  void _resetTest() {
    _timer?.cancel();
    setState(() {
      _isTestActive = false;
      _scoreCorrect = 0;
      _scoreWrong = 0;
      _accuracy = 0.0;
      _remainingTime = _timeOptions[_selectedTime]!;
      _answerTimes.clear();
    });
    _generateQuestion();
  }

  void _generateQuestion() {
    final random = Random();
    final number1 = random.nextInt(10);
    final number2 = random.nextInt(10);
    final answer = number1 + number2;
    _isAnswerCorrect = answer % 2 == 0;
    _currentQuestion = "$number1 + $number2 = ?";
    _questionStartTime = DateTime.now();
  }

  void _checkAnswer(bool isEvenSelected) {
    if (!_isTestActive) return;
    _answerTimes.add(DateTime.now().difference(_questionStartTime!).inSeconds);
    setState(() {
      if (isEvenSelected == _isAnswerCorrect) {
        _scoreCorrect++;
      } else {
        _scoreWrong++;
      }
      _generateQuestion();
    });
  }

  double _calculateAverageResponseTime() {
    if (_answerTimes.isEmpty) return 0;
    return _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
  }

  double _calculateAccuracy() {
    if (_scoreCorrect + _scoreWrong == 0) return 0;
    final accuracyScore = (_scoreCorrect / (_scoreCorrect + _scoreWrong)) * 100;
    return (accuracyScore - _calculateAverageResponseTime()).clamp(0, 100);
  }

  Future<void> _logTestResult() async {
    final userId = _authService.getCurrentUserId();
    if (userId != null) {
      await FirestoreService().addDataToList(
        collection: 'users',
        documentId: userId,
        field: 'testResults',
        data: {
          'score_correct': _scoreCorrect,
          'score_wrong': _scoreWrong,
          'average_response_time': _calculateAverageResponseTime(),
          'accuracy': _accuracy,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      await _analytics.logEvent(
        name: 'test_result',
        parameters: {
          'user_id': userId,
          'score_correct': _scoreCorrect,
          'score_wrong': _scoreWrong,
          'selected_time': _selectedTime,
          'average_response_time': _calculateAverageResponseTime(),
          'accuracy': _accuracy,
        },
      );
    }
  }

  void _showTestResultsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time’s Up!'),
        content: Text(
          'Correct: $_scoreCorrect\n'
          'Wrong: $_scoreWrong\n'
          'Average Response Time: ${_calculateAverageResponseTime().toStringAsFixed(2)} seconds\n'
          'Accuracy: ${_accuracy.toStringAsFixed(2)}%',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTest();
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(int number) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: CustomButton(
          label: '$number',
          onPressed: () {
            if (_isTestActive) {
              _checkAnswer(number % 2 == 0);
            }
          },
          isEnabled: _isTestActive,
          isRounded: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: "Riwayat Hasil",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const TestResultsScreen(collectionField: 'testResults'),
                  ),
                );
              },
            ),
            DropdownButton<String>(
              value: _selectedTime,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedTime = newValue;
                    _remainingTime = _timeOptions[newValue]!;
                  });
                }
              },
              items: _timeOptions.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(_currentQuestion, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text('Time: $_remainingTime seconds',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                    label: 'Start',
                    onPressed: _startTest,
                    isEnabled: !_isTestActive),
                CustomButton(
                    label: 'Reset', onPressed: _resetTest, isEnabled: true),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: List.generate(3, (row) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (col) {
                        final number = row * 3 + col + 1;
                        return _buildNumberButton(number);
                      }),
                    );
                  }) +
                  [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        _buildNumberButton(0),
                        const Spacer(),
                      ],
                    )
                  ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Correct: $_scoreCorrect',
                    style: const TextStyle(fontSize: 18)),
                Text('Wrong: $_scoreWrong',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
