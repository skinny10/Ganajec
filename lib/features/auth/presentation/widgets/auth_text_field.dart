import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  final String hint;
  final IconData prefixIcon;
  final bool obscure;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;

  const AuthTextField({
    super.key,
    required this.hint,
    required this.prefixIcon,
    required this.controller,
    this.obscure = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return TextFormField(
      controller:          controller,
      obscureText:         obscure,
      keyboardType:        keyboardType,
      textCapitalization:  textCapitalization,
      validator:           validator,
      style: TextStyle(fontSize: 14, color: cs.onSurface),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: TextStyle(
          color:      cs.outline,
          fontWeight: FontWeight.w300,
          fontSize:   14,
        ),
        filled:    true,
        fillColor: cs.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        prefixIcon: Icon(prefixIcon, color: cs.outline, size: 18),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: cs.error, width: 0.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: cs.error, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:   BorderSide(color: cs.outlineVariant, width: 0.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}
