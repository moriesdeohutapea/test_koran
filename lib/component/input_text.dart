import 'package:flutter/material.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final MaterialColor fillColor;
  final Color iconColor;
  final IconData visibleIcon; // Icon for visible state
  final IconData hiddenIcon; // Icon for hidden state
  final int? maxLength; // Opsi max length yang baru ditambahkan

  const PasswordTextField({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    this.fillColor = Colors.grey,
    this.iconColor = Colors.grey,
    this.visibleIcon = Icons.visibility, // Default visible icon
    this.hiddenIcon = Icons.visibility_off, // Default hidden icon
    this.maxLength, // Tambahkan maxLength di konstruktor
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
      maxLength: widget.maxLength,
      // Terapkan maxLength pada TextFormField
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
            _isObscured ? widget.hiddenIcon : widget.visibleIcon,
            color: widget.iconColor,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
        counterText: '', // Hapus teks penghitung di bawah text field
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
  final int? maxLength; // Opsi max length yang baru ditambahkan

  const CustomTextField({
    super.key,
    required this.controller,
    this.labelText = '',
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.icon,
    this.fillColor = Colors.white,
    this.iconColor = Colors.grey,
    this.maxLength, // Tambahkan maxLength di konstruktor
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      maxLength: maxLength,
      // Terapkan maxLength pada TextFormField
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
        counterText: '', // Hapus teks penghitung di bawah text field
      ),
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
    );
  }
}
