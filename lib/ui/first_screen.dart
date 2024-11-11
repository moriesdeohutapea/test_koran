import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:test_koran/ui/test_result_screen.dart';

import '../component/text_view.dart';
import '../service/auth_service.dart';
import '../component/custom_button.dart';
import '../service/fire_store_service.dart';

class TestOneScreen extends StatefulWidget {
  const TestOneScreen({super.key});

  @override
  _TestOneScreenState createState() => _TestOneScreenState();
}

class _TestOneScreenState extends State<TestOneScreen> {
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
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Time’s Up!'),
        content: CustomText(text:
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
            child: const CustomText(text: "Oke",),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const CustomText(
          text: 'Number Test',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.history),
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
        ],
      )
      ,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                  child: CustomText(text: value), // CustomText used here
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            CustomText(text: _currentQuestion, fontSize: 36, fontWeight: FontWeight.w600,),
            // CustomText used here
            const SizedBox(height: 20),
            CustomText(
              text: 'Time: $_remainingTime seconds', // CustomText used here
              fontSize: 18,
            ),
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
                CustomText(
                  text: 'Correct: $_scoreCorrect', // CustomText used here
                  fontSize: 18,
                ),
                CustomText(
                  text: 'Wrong: $_scoreWrong', // CustomText used here
                  fontSize: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
