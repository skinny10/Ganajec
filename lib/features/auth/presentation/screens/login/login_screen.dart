import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/auth_viewmodel.dart';
import 'login_components.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = context.read<AuthViewModel>();
    await vm.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (mounted && vm.status == AuthStatus.success) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Form(
          key: _formKey,
          child: Stack(
            children: [
              // Layout principal
              Column(
                children: [
                  // Logo e info
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: Column(
                      children: [
                        Image.asset('assets/images/icon.png', height: 48),
                        const SizedBox(height: 4),
                        Text(
                          'GANAJEC AI',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xff4a2c0a),
                              ),
                        ),
                        Text(
                          'Sistema de Detección Temprana\nde Síntomas en Ganado Bovino',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: const Color(0xff4a2c0a)),
                        ),
                      ],
                    ),
                  ),

                  // Hero
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/fondo.png',
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: -50,
                          left: -40,
                          right: 0,
                          child: LayoutBuilder(
                            builder: (context, constraints) => Image.asset(
                              'assets/images/vaca.png',
                              height: constraints.maxWidth * 0.75,
                              fit: BoxFit.contain,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context).colorScheme.surface,
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bienvenido',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Ingresa tus credenciales para acceder al sistema',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Formulario + footer como fondo
                  Expanded(
                    flex: 6,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Footer como fondo de esta sección
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            'assets/images/footer.png',
                            width: double.infinity,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        // Formulario encima del footer
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              LoginFormFields(
                                emailController: _emailController,
                                passwordController: _passwordController,
                                obscurePassword: _obscurePassword,
                                onTogglePassword: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                rememberMe: _rememberMe,
                                onRememberMe: (v) => setState(
                                    () => _rememberMe = v ?? false),
                              ),
                              const SizedBox(height: 8),
                              LoginActions(
                                isLoading: vm.isLoading,
                                errorMessage: vm.status == AuthStatus.error
                                    ? vm.errorMessage
                                    : null,
                                onLogin: _onLogin,
                                onGoRegister: () =>
                                    context.push('/register'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}