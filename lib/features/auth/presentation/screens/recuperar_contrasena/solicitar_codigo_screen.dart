import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/router/app_router.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_button.dart';

class SolicitarCodigoScreen extends StatefulWidget {
  const SolicitarCodigoScreen({super.key});

  @override
  State<SolicitarCodigoScreen> createState() => _SolicitarCodigoScreenState();
}

class _SolicitarCodigoScreenState extends State<SolicitarCodigoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ApiClient.instance.post(
        ApiConstants.baseUrl + ApiConstants.solicitarRecuperacion,
        data: {
          'email': _emailController.text.trim(),
        },
      );
      if (mounted) {
        context.push(
          AppRoutes.nuevaContrasena,
          extra: {'email': _emailController.text.trim()},
        );
      }
    } on DioException {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Error'),
            content: const Text(
              'No se pudo enviar el código. Verifica tu correo e intenta de nuevo.',
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
        title: const Text('Recuperar contraseña'),
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
                '¿Olvidaste tu contraseña?',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Ingresa tu correo electrónico y te enviaremos un código para restablecer tu contraseña.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                hint: 'Correo electrónico',
                prefixIcon: Icons.mail_outline,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'El correo es obligatorio';
                  if (!v.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              AuthButton(
                label: 'Enviar código',
                onPressed: _enviarCodigo,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Volver al inicio de sesión'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
