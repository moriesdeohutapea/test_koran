import 'dart:async';
import 'dart:math';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:test_koran/ui/test_result_screen.dart';

import '../component/text_view.dart';
import '../service/auth_service.dart';
import '../component/custom_button.dart';

class OddEvenTestScreen extends StatefulWidget {
  const OddEvenTestScreen({super.key});

  @override
  _OddEvenTestScreenState createState() => _OddEvenTestScreenState();
}

class _OddEvenTestScreenState extends State<OddEvenTestScreen> {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final AuthService _authService = AuthService();
  late String _currentQuestion;
  late bool _isAnswerEven;
  int _scoreBenar = 0;
  int _scoreSalah = 0;
  int _remainingTime = 60;
  Timer? _timer;
  bool _timerStarted = false;
  final List<int> _answerTimes = [];
  DateTime? _questionStartTime;
  double _accuracy = 0.0;

  final Map<String, int> _timeOptions = {
    '30 Detik': 30,
    '1 Menit': 60,
    '1.5 Menit': 90,
    '2 Menit': 120,
  };
  String _selectedTime = '1 Menit';

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  void _endTest() {
    _timer?.cancel();
    _accuracy = _calculateAccuracy(); // Hitung akurasi sebelum disimpan

    _logTestResult(); // Simpan hasil tes, termasuk akurasi

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const CustomText(text: 'Waktu Habis!'),
        content: CustomText(text:
          'Benar: $_scoreBenar\n'
          'Salah: $_scoreSalah\n'
          'Average Response Time: ${_calculateAverageResponseTime().toStringAsFixed(2)} detik\n'
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

  Future<void> _logTestResult() async {
    final averageResponseTime = _calculateAverageResponseTime();
    _authService.logOddEvenTestResult(
      scoreCorrect: _scoreBenar,
      scoreWrong: _scoreSalah,
      selectedTime: _selectedTime,
      averageResponseTime: averageResponseTime,
      accuracy: _accuracy, // Pastikan accuracy dipass saat log hasil tes
    );
  }

  void _toScreenResult() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const TestResultsScreen(collectionField: 'oddEvenTestResults'),
      ),
    );
  }

  void _startTimer() {
    if (_timer != null && _timer!.isActive) return;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        _endTest();
      }
    });
    setState(() {
      _timerStarted = true;
    });
  }

  void _resetTest() {
    _timer?.cancel();
    setState(() {
      _timerStarted = false;
      _scoreBenar = 0;
      _scoreSalah = 0;
      _remainingTime = _timeOptions[_selectedTime]!;
      _answerTimes.clear();
      _accuracy = 0.0;
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    final random = Random();
    int angka1 = random.nextInt(10);
    int angka2 = random.nextInt(10);
    int jawaban = angka1 + angka2;

    _currentQuestion = '$angka1 + $angka2 = ?';
    _isAnswerEven = jawaban % 2 == 0;
    _questionStartTime = DateTime.now();
  }

  void _checkAnswer(bool isEvenSelected) {
    if (!_timerStarted) return;

    final answerTime = DateTime.now().difference(_questionStartTime!).inSeconds;
    _answerTimes.add(answerTime);

    setState(() {
      if (isEvenSelected == _isAnswerEven) {
        _scoreBenar++;
      } else {
        _scoreSalah++;
      }
      _generateQuestion();
    });
  }

  double _calculateAverageResponseTime() {
    if (_answerTimes.isEmpty) return 0;
    return _answerTimes.reduce((a, b) => a + b) / _answerTimes.length;
  }

  double _calculateAccuracy() {
    if (_scoreBenar + _scoreSalah == 0) return 0;
    final correctRatio = (_scoreBenar / (_scoreBenar + _scoreSalah)) * 100;
    return (correctRatio - _calculateAverageResponseTime()).clamp(0, 100);
  }

  void _updateTimeSetting(String newValue) {
    setState(() {
      _selectedTime = newValue;
      _remainingTime = _timeOptions[newValue]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const CustomText(
            text: 'Tes Ganjil/Genap',
            fontSize: 20,
            fontWeight: FontWeight.bold),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _toScreenResult,
            ),
          ]
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedTime,
              onChanged: (String? newValue) {
                if (newValue != null) _updateTimeSetting(newValue);
              },
              items: _timeOptions.keys
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: CustomText(text: value), // Using CustomText here
                );
              }).toList(),
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            CustomButton(
              label: 'Start',
              onPressed: _startTimer,
              isEnabled: true,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            CustomButton(
              label: 'Reset',
              onPressed: _resetTest,
              isEnabled: true,
            ),
            const Padding(padding: EdgeInsets.symmetric(vertical: 8)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomText(
                    text: _currentQuestion,
                    fontSize: 36,
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 20),
                  CustomText(
                    text: 'Waktu: $_remainingTime detik',
                    fontSize: 18,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Ganjil',
                          onPressed:
                              _timerStarted ? () => _checkAnswer(false) : null,
                          isEnabled: _timerStarted,
                          isRounded: false,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomButton(
                          label: 'Genap',
                          onPressed:
                              _timerStarted ? () => _checkAnswer(true) : null,
                          isEnabled: _timerStarted,
                          isRounded: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
