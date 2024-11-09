import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'custom_button.dart';

class OddEvenTestScreen extends StatefulWidget {
  const OddEvenTestScreen({super.key});

  @override
  _OddEvenTestScreenState createState() => _OddEvenTestScreenState();
}

class _OddEvenTestScreenState extends State<OddEvenTestScreen> {
  late String _currentQuestion;
  late bool _isAnswerEven;
  int _scoreBenar = 0;
  int _scoreSalah = 0;
  int _remainingTime = 60; // Default 1 menit
  Timer? _timer;
  bool _timerStarted =
      false; // Menambahkan indikator apakah timer sudah dimulai
  final Map<String, int> _timeOptions = {
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
      _timerStarted = true; // Set timer telah dimulai
    });
  }

  void _endTest() {
    _timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Waktu Habis!'),
        content: Text('Benar: $_scoreBenar\nSalah: $_scoreSalah'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTest();
            },
            child: const Text('Mulai Lagi'),
          ),
        ],
      ),
    );
  }

  void _resetTest() {
    _timer?.cancel(); // Memastikan timer dihentikan saat reset
    setState(() {
      _timerStarted = false; // Reset status timer
      _scoreBenar = 0;
      _scoreSalah = 0;
      _remainingTime = _timeOptions[_selectedTime]!;
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
  }

  void _checkAnswer(bool isEvenSelected) {
    setState(() {
      if (isEvenSelected == _isAnswerEven) {
        _scoreBenar++;
      } else {
        _scoreSalah++;
      }
      _generateQuestion();
    });
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
      appBar: AppBar(title: const Text('Tes Ganjil/Genap')),
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
                  child: Text(value),
                );
              }).toList(),
            ),
            CustomButton(
              label: 'Start',
              onPressed: _startTimer,
              isEnabled: true,
            ),
            CustomButton(
              label: 'Reset',
              onPressed: _resetTest,
              isEnabled: true,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentQuestion,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text('Waktu: $_remainingTime detik',
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                        label: 'Ganjil',
                        onPressed:
                            _timerStarted ? () => _checkAnswer(false) : null,
                        isEnabled: _timerStarted,
                      ),
                      const SizedBox(width: 20),
                      CustomButton(
                        label: 'Genap',
                        onPressed:
                            _timerStarted ? () => _checkAnswer(true) : null,
                        isEnabled: _timerStarted,
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
