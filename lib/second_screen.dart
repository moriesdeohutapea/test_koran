import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class OddEvenTestScreen extends StatefulWidget {
  const OddEvenTestScreen({super.key});

  @override
  _OddEvenTestScreenState createState() => _OddEvenTestScreenState();
}

class _OddEvenTestScreenState extends State<OddEvenTestScreen> {
  late String _currentQuestion;
  late bool
      _isAnswerEven; // True jika jawaban benar adalah genap, false jika ganjil
  int _scoreBenar = 0;
  int _scoreSalah = 0;
  int _remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generateQuestion(); // Membuat pertanyaan awal
    _startTimer();
  }

  // Fungsi untuk memulai timer
  void _startTimer() {
    // Pastikan untuk membatalkan timer sebelumnya jika ada
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _endTest();
        }
      });
    });
  }

  // Fungsi untuk menghentikan timer dan menampilkan hasil akhir
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

  // Fungsi untuk reset nilai awal
  void _resetTest() {
    setState(() {
      _scoreBenar = 0;
      _scoreSalah = 0;
      _remainingTime = 60;
      _generateQuestion();
    });
    _startTimer();
  }

  // Fungsi untuk membuat pertanyaan penjumlahan dan menentukan apakah jawaban ganjil/genap
  void _generateQuestion() {
    final random = Random();
    int angka1 = random.nextInt(10); // angka acak antara 0-9
    int angka2 = random.nextInt(10); // angka acak antara 0-9
    int jawaban = angka1 + angka2;

    _currentQuestion = '$angka1 + $angka2 = ?';
    _isAnswerEven = jawaban % 2 == 0;
  }

  // Fungsi untuk memeriksa apakah pilihan pengguna benar atau salah
  void _checkAnswer(bool isEvenSelected) {
    setState(() {
      if (isEvenSelected == _isAnswerEven) {
        _scoreBenar++;
      } else {
        _scoreSalah++;
      }
      _generateQuestion(); // Membuat pertanyaan baru setelah jawaban
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tes Ganjil/Genap')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentQuestion,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Menampilkan waktu yang tersisa
            Text('Waktu: $_remainingTime detik',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // Dua tombol untuk memilih Ganjil atau Genap
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _checkAnswer(false), // False untuk Ganjil
                  child: const Text('Ganjil'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _checkAnswer(true), // True untuk Genap
                  child: const Text('Genap'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Menampilkan skor benar dan salah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Benar: $_scoreBenar',
                    style: const TextStyle(fontSize: 18)),
                Text('Salah: $_scoreSalah',
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
