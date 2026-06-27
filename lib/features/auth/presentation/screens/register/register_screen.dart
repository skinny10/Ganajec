import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_button.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_error_text.dart';
import 'register_components.dart';
import 'package:ganajec/core/router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String _selectedRole = 'ganadero';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole,
    );
    if (mounted && vm.status == AuthStatus.success) {
      context.push(AppRoutes.verificarEmail, extra: {
        'email': _emailController.text.trim(),
        'nombre': _nameController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Crear cuenta'),
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
                'Únete a GANAJEC',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Comienza a monitorear la salud de tu ganado hoy mismo.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              RegisterFormFields(
                nameController: _nameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmController: _confirmController,
                obscurePassword: _obscurePassword,
                obscureConfirm: _obscureConfirm,
                onTogglePassword: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onToggleConfirm: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 24),
              RegisterRoleSelector(
                selectedRole: _selectedRole,
                onRoleChanged: (r) => setState(() => _selectedRole = r),
              ),
              const SizedBox(height: 24),
              if (vm.status == AuthStatus.error && vm.errorMessage != null) ...[
                AuthErrorText(message: vm.errorMessage!),
                const SizedBox(height: 12),
              ],
              AuthButton(
                label: 'Crear cuenta',
                onPressed: _onRegister,
                isLoading: vm.isLoading,
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: const Text(
                    'Al registrarte, aceptas nuestros Términos de uso · Política de privacidad',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}