import 'package:flutter/material.dart';
import 'package:test_koran/second_screen.dart';
import 'package:test_koran/widgets/summary_widget.dart';

import 'auth_service.dart';
import 'component/custom_button.dart';
import 'component/text_view.dart';
import 'first_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  bool isLoggedIn = false;
  bool isLoading = true;
  String userName = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await _authService.isUserLoggedIn();
    if (loggedIn) {
      final name = await _authService.getUserName();
      setState(() {
        isLoggedIn = loggedIn;
        userName = name ?? 'Guest';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoggedIn = false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Pilih Tes',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _authService.signOut();
                setState(() {
                  isLoggedIn = false;
                  userName = '';
                });
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : isLoggedIn
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SummaryWidget(),
                        CustomText(
                          text: 'Selamat datang, $userName!',
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 20),
                        CustomButton(
                          label: 'Tes Koran',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TestScreen(),
                              ),
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
                              MaterialPageRoute(
                                builder: (context) => const OddEvenTestScreen(),
                              ),
                            );
                          },
                          isEnabled: true,
                        ),
                      ],
                    )
                  : CustomButton(
                      label: "Login",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      isEnabled: true,
                    ),
        ),
      ),
    );
  }
}

