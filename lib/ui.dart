import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'model.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late Pertanyaan _currentPertanyaan;
  int _scoreBenar = 0;
  int _scoreSalah = 0;
  int _remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _generatePertanyaan(); // Membuat pertanyaan awal secara dinamis
    _startTimer();
  }

  // Fungsi untuk memulai timer
  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
        title: Text('Waktu Habis!'),
        content: Text('Benar: $_scoreBenar\nSalah: $_scoreSalah'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTest();
            },
            child: Text('Mulai Lagi'),
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
      _generatePertanyaan();
    });
    _startTimer();
  }

  // Fungsi untuk membuat pertanyaan penjumlahan dinamis
  void _generatePertanyaan() {
    final random = Random();
    int angka1 = random.nextInt(10); // angka acak antara 0-9
    int angka2 = random.nextInt(10); // angka acak antara 0-9

    String teks = '$angka1 + $angka2 = ?';
    int jawabanBenar = angka1 + angka2;

    _currentPertanyaan = Pertanyaan(teks: teks, jawabanBenar: jawabanBenar);
  }

  // Fungsi untuk memeriksa jawaban
  void _checkJawaban(int jawaban) {
    int jawabanBenarDigitTerakhir =
        _currentPertanyaan.jawabanBenar % 10; // Mendapatkan digit terakhir

    setState(() {
      if (jawaban == jawabanBenarDigitTerakhir) {
        _scoreBenar++;
      } else {
        _scoreSalah++;
      }
      _generatePertanyaan(); // Membuat pertanyaan baru setelah jawaban
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
      appBar: AppBar(title: Text('Tes Koran')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentPertanyaan.teks,
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            // Menampilkan waktu yang tersisa
            Text('Waktu: $_remainingTime detik',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            // Layout khusus untuk tombol angka
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
            SizedBox(height: 20),
            // Menampilkan skor benar dan salah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Benar: $_scoreBenar', style: TextStyle(fontSize: 18)),
                Text('Salah: $_scoreSalah', style: TextStyle(fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun tombol angka
  Widget _buildNumberButton(int number) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ElevatedButton(
        onPressed: () => _checkJawaban(number),
        child: Text(
          '$number',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
