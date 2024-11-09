import 'package:flutter/material.dart';

import 'auth_service.dart';
import 'custom_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isLoginMode = false; // Menentukan mode: login atau registrasi

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
    _ageController.addListener(_validateForm);
  }

  void _validateForm() {
    final isEmailValid = _emailController.text.trim().isNotEmpty &&
        RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_emailController.text);
    final isPasswordValid = _passwordController.text.trim().length >= 6;
    bool isNameValid = true;
    bool isAgeValid = true;

    if (!_isLoginMode) {
      isNameValid = _nameController.text.trim().isNotEmpty;
      isAgeValid = _ageController.text.trim().isNotEmpty &&
          int.tryParse(_ageController.text) != null &&
          int.parse(_ageController.text) > 0;
    }

    setState(() {
      _isFormValid = isEmailValid && isPasswordValid && isNameValid && isAgeValid;
    });
  }

  Future<void> _handleAuth() async {
    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLoginMode) {
      // Mode login: panggil fungsi login
      await _authService.signInWithEmailAndPassword(email, password);
    } else {
      // Mode registrasi: panggil fungsi registrasi
      final name = _nameController.text.trim();
      final age = int.parse(_ageController.text.trim());
      await _authService.signUpWithEmail(email, password, name, age);
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Login' : 'Register'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isLoginMode)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama'),
                ),
              if (!_isLoginMode)
                const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              if (!_isLoginMode)
                TextField(
                  controller: _ageController,
                  decoration: const InputDecoration(labelText: 'Umur'),
                  keyboardType: TextInputType.number,
                ),
              if (!_isLoginMode)
                const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              CustomButton(
                label: _isLoginMode ? "Login" : "Register",
                onPressed: _isFormValid ? _handleAuth : null,
                isEnabled: _isFormValid,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLoginMode = !_isLoginMode;
                    _validateForm();
                  });
                },
                child: Text(
                  _isLoginMode
                      ? "Belum punya akun? Register"
                      : "Sudah punya akun? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}

