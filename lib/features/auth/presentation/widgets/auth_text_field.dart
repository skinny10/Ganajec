import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscure = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}