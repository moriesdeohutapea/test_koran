import 'package:flutter/material.dart';
import 'package:test_koran/second_screen.dart';
import 'package:test_koran/first_screen.dart';

import 'custom_button.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aplikasi Tes',
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Tes')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              label: 'Tes Koran',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TestScreen()),
                );
              },
              isEnabled: true,
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: 'Tes Ganjil/Genap',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OddEvenTestScreen()),
                );
              },
              isEnabled: true,
            ),
          ],
        ),
      ),
    );
  }}
