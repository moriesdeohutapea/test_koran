import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final MaterialColor fillColor; // Changed to MaterialColor
  final Color iconColor;

  const PasswordTextField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.fillColor = Colors.grey, // Use MaterialColor for shades
    this.iconColor = Colors.grey,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _isObscured,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: Colors.grey[700]),
        filled: true,
        fillColor: widget.fillColor[200],
        // Access shade 200
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final bool isPassword;
  final IconData? icon;
  final Color fillColor;
  final Color iconColor;

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.icon,
    this.fillColor = Colors.white,
    this.iconColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
        prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      style: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}
