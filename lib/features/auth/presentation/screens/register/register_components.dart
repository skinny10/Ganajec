import 'package:flutter/material.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/auth_role_card.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool obscurePassword;
  final bool obscureConfirm;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirm;

  const RegisterFormFields({
    super.key,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTogglePassword,
    required this.onToggleConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthTextField(
          hint: AppStrings.nameLabel,
          prefixIcon: Icons.person_outline,
          controller: nameController,
          validator: (v) =>
              v == null || v.isEmpty ? AppStrings.nameRequired : null,
        ),
        const SizedBox(height: 14),
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
            icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: onTogglePassword,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.passwordRequired;
            if (v.length < 6) return AppStrings.passwordShort;
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          hint: AppStrings.confirmPasswordLabel,
          prefixIcon: Icons.lock_outline,
          controller: confirmController,
          obscure: obscureConfirm,
          suffixIcon: IconButton(
            icon: Icon(
                obscureConfirm ? Icons.visibility_off : Icons.visibility),
            onPressed: onToggleConfirm,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return AppStrings.passwordRequired;
            if (v != passwordController.text) return AppStrings.passwordsNoMatch;
            return null;
          },
        ),
      ],
    );
  }
}

class RegisterRoleSelector extends StatelessWidget {
  final String selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RegisterRoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  static const _roles = [
    (
      role: 'ganadero',
      label: 'Ganadero',
      description: 'Registro mis animales y recibo alertas de salud.',
      icon: Icons.pets,
    ),
    (
      role: 'dueno',
      label: 'Dueño del rancho',
      description: 'Superviso el hato completo y coordino a mi equipo.',
      icon: Icons.agriculture,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona tu rol',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                letterSpacing: 0.8,
              ),
        ),
        const SizedBox(height: 10),
        ..._roles.map(
          (r) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: AuthRoleCard(
              role: r.label,
              description: r.description,
              icon: r.icon,
              selected: selectedRole == r.role,
              onTap: () => onRoleChanged(r.role),
            ),
          ),
        ),
      ],
    );
  }
}