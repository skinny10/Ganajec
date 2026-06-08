import 'package:flutter/material.dart';
import '../../../../../core//constants/app_strings.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_error_text.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final bool rememberMe;
  final ValueChanged<bool?> onRememberMe;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.rememberMe,
    required this.onRememberMe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          hint: AppStrings.emailLabel,
          prefixIcon: Icons.mail_outline,
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.emailRequired;
            if (!v.contains('@')) return AppStrings.emailInvalid;
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          hint: AppStrings.passwordLabel,
          prefixIcon: Icons.lock_outline,
          controller: passwordController,
          obscure: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: onTogglePassword,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.passwordRequired;
            if (v.length < 6) return AppStrings.passwordShort;
            return null;
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Checkbox(value: rememberMe, onChanged: onRememberMe),
            const Text('Recuérdame', style: TextStyle(fontSize: 13)),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text('¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ],
    );
  }
}

class LoginActions extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onLogin;
  final VoidCallback onGoRegister;

  const LoginActions({
    super.key,
    required this.isLoading,
    required this.onLogin,
    required this.onGoRegister,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (errorMessage != null) ...[
          AuthErrorText(message: errorMessage!),
          const SizedBox(height: 12),
        ],
        AuthButton(
          label: AppStrings.loginButton,
          onPressed: onLogin,
          isLoading: isLoading,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onGoRegister,
          child: Text(AppStrings.noAccount),
        ),
      ],
    );
  }
}