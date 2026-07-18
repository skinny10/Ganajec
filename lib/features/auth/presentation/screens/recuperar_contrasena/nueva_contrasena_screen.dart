import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_button.dart';

class NuevaContrasenaScreen extends StatefulWidget {
  final String email;

  const NuevaContrasenaScreen({
    super.key,
    required this.email,
  });

  @override
  State<NuevaContrasenaScreen> createState() => _NuevaContrasenaScreenState();
}

class _NuevaContrasenaScreenState extends State<NuevaContrasenaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _cambiarContrasena() async {
    if (!_formKey.currentState!.validate()) return;
    if (_codeController.text.length != 6) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.post(
        ApiConstants.baseUrl + ApiConstants.restablecerPassword,
        data: {
          'email': widget.email,
          'codigo': _codeController.text,
          'nueva_password': _passwordController.text,
        },
      );
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Contraseña actualizada'),
            content: const Text(
              'Tu contraseña ha sido restablecida exitosamente.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go(AppRoutes.login);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } on DioException {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'Código inválido o expirado. Intenta de nuevo.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Restablecer contraseña'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Restablecer contraseña',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Ingresa el código de 6 dígitos que recibiste en ${widget.email} y crea tu nueva contraseña.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              Center(
                child: SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 12,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AuthTextField(
                hint: 'Nueva contraseña',
                prefixIcon: Icons.lock_outline,
                controller: _passwordController,
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'La contraseña es obligatoria';
                  }
                  if (v.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              AuthTextField(
                hint: 'Confirmar contraseña',
                prefixIcon: Icons.lock_outline,
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Confirma tu contraseña';
                  }
                  if (v != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthButton(
                label: 'Cambiar contraseña',
                onPressed: _cambiarContrasena,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
