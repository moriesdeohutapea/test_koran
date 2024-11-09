import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import 'custom_button.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late String _currentQuestion;
  late bool _isAnswerCorrect;
  int _scoreCorrect = 0;
  int _scoreWrong = 0;
  int _remainingTime = 60;
  Timer? _timer;
  bool _isTestActive = false;
  final Map<String, int> _timeOptions = {
    '30 Detik': 30,
    '1 Menit': 60,
    '1.5 Menit': 90,
    '2 Menit': 120,
  };
  String _selectedTime = '1 Menit';

  Future<void> _playSound() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource('microwave_button.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _generateQuestion();
    _remainingTime = _timeOptions[_selectedTime]!;
  }

  void _startTest() {
    if (!_isTestActive) {
      _isTestActive = true;
      _remainingTime = _timeOptions[_selectedTime]!;
      _startTimer();
    }
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
    setState(() => _isTestActive = false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time’s Up!'),
        content: Text('Correct: $_scoreCorrect\nWrong: $_scoreWrong'),
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

  void _resetTest() {
    _timer?.cancel();
    setState(() {
      _isTestActive = false;
      _scoreCorrect = 0;
      _scoreWrong = 0;
      _remainingTime = _timeOptions[_selectedTime]!;
      _generateQuestion();
    });
  }

  void _generateQuestion() {
    final random = Random();
    int number1 = random.nextInt(10);
    int number2 = random.nextInt(10);
    int answer = number1 + number2;
    _isAnswerCorrect = answer % 2 == 0; // True if even, false if odd
    _currentQuestion = "$number1 + $number2 = ?";
  }

  void _checkAnswer(bool isEvenSelected) {
    if (!_isTestActive) return;
    setState(() {
      if (isEvenSelected == _isAnswerCorrect) {
        _scoreCorrect++;
      } else {
        _scoreWrong++;
      }
      _generateQuestion(); // Generate a new question after answering
    });
  }

  Widget _buildNumberButton(int number) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: CustomButton(
        label: '$number',
        onPressed: () {
          if (_isTestActive) {
            _checkAnswer(number % 2 == 0);
            _playSound();
          }
        },
        isEnabled: _isTestActive,
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton(1),
                    _buildNumberButton(2),
                    _buildNumberButton(3),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton(4),
                    _buildNumberButton(5),
                    _buildNumberButton(6),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildNumberButton(7),
                    _buildNumberButton(8),
                    _buildNumberButton(9),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Spacer(),
                    _buildNumberButton(0),
                    Spacer(),
                  ],
                ),
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
