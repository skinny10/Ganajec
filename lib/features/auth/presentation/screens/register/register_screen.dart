import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_button.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:ganajec/features/auth/presentation/widgets/auth_text_field.dart';
import 'register_components.dart';
import 'package:ganajec/core/router/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey            = GlobalKey<FormState>();
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool   _obscurePassword   = true;
  bool   _obscureConfirm    = true;
  String _selectedRole      = 'ganadero';
  int    _strengthScore     = 0;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateStrength);
  }

  void _updateStrength() {
    final pwd = _passwordController.text;
    int s = 0;
    if (pwd.length >= 8) s++;
    if (pwd.contains(RegExp(r'[A-Z]'))) s++;
    if (pwd.contains(RegExp(r'[0-9]'))) s++;
    if (pwd.contains(RegExp(r'[^A-Za-z0-9]'))) s++;
    setState(() => _strengthScore = s);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updateStrength);
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
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      password: _passwordController.text,
      role:     _selectedRole,
    );
    if (mounted && vm.status == AuthStatus.success) {
      context.push(AppRoutes.verificarEmail, extra: {
        'email':  _emailController.text.trim(),
        'nombre': _nameController.text.trim(),
      });
    }
  }

  // ── Helpers de layout ────────────────────────────────────────────────────

  Widget _sectionHeader(String label, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              fontSize:      10,
              fontWeight:    FontWeight.w600,
              color:         cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(color: cs.outlineVariant, thickness: 0.5, height: 1),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: tt.labelSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color:      cs.onSurfaceVariant,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Botón atrás ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: cs.outlineVariant, width: 0.5),
                    ),
                    child: Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
                  ),
                ),
              ),
            ),

            // ── Contenido scrollable ──────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 36),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Título + subtítulo ──────────────────────────────
                      Text(
                        'Únete a GANAJEC',
                        style: tt.headlineSmall?.copyWith(
                          fontSize:      26,
                          fontWeight:    FontWeight.w500,
                          letterSpacing: -0.6,
                          color:         cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Comienza a monitorear la salud de tu ganado con inteligencia artificial.',
                        style: tt.bodyMedium?.copyWith(
                          fontSize:   13,
                          color:      cs.onSurfaceVariant,
                          fontWeight: FontWeight.w300,
                          height:     1.5,
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ── Información personal ────────────────────────────
                      _sectionHeader('INFORMACIÓN PERSONAL', cs),

                      _fieldLabel('Nombre completo', cs),
                      AuthTextField(
                        hint:                'Tu nombre completo',
                        prefixIcon:          Icons.person_outline,
                        controller:          _nameController,
                        textCapitalization:  TextCapitalization.words,
                        suffixIcon: ListenableBuilder(
                          listenable: _nameController,
                          builder: (_, __) => _nameController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(Icons.check_rounded, color: cs.tertiary, size: 16),
                                )
                              : const SizedBox.shrink(),
                        ),
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Ingresa tu nombre' : null,
                      ),
                      const SizedBox(height: 12),

                      _fieldLabel('Correo electrónico', cs),
                      AuthTextField(
                        hint:         'correo@ejemplo.com',
                        prefixIcon:   Icons.mail_outline_rounded,
                        controller:   _emailController,
                        keyboardType: TextInputType.emailAddress,
                        suffixIcon: ListenableBuilder(
                          listenable: _emailController,
                          builder: (_, __) => _emailController.text.contains('@')
                              ? Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: Icon(Icons.check_rounded, color: cs.tertiary, size: 16),
                                )
                              : const SizedBox.shrink(),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa tu correo';
                          if (!v.contains('@')) return 'Correo inválido';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Seguridad ───────────────────────────────────────
                      _sectionHeader('SEGURIDAD', cs),

                      _fieldLabel('Contraseña', cs),
                      AuthTextField(
                        hint:       'Mínimo 8 caracteres',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        obscure:    _obscurePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: cs.outline,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                          if (v.length < 8) return 'Mínimo 8 caracteres';
                          return null;
                        },
                      ),
                      ListenableBuilder(
                        listenable: _passwordController,
                        builder: (_, __) => _passwordController.text.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: StrengthBars(score: _strengthScore),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 12),

                      _fieldLabel('Confirmar contraseña', cs),
                      AuthTextField(
                        hint:       'Repite tu contraseña',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _confirmController,
                        obscure:    _obscureConfirm,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(
                              _obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: cs.outline,
                              size: 18,
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                          if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // ── Rol ─────────────────────────────────────────────
                      RegisterRoleSelector(
                        selectedRole:  _selectedRole,
                        onRoleChanged: (r) => setState(() => _selectedRole = r),
                      ),

                      // ── Error ────────────────────────────────────────────
                      if (vm.status == AuthStatus.error && vm.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        AuthErrorText(message: vm.errorMessage!),
                      ],

                      // ── Botón ─────────────────────────────────────────────
                      const SizedBox(height: 20),
                      AuthButton(
                        label:     'Crear cuenta',
                        onPressed: _onRegister,
                        isLoading: vm.isLoading,
                      ),
                      const SizedBox(height: 12),

                      // ── Términos ───────────────────────────────────────────
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: tt.bodySmall?.copyWith(
                              fontSize:   11,
                              color:      cs.onSurfaceVariant,
                              fontWeight: FontWeight.w300,
                              height:     1.6,
                            ),
                            children: [
                              const TextSpan(text: 'Al registrarte aceptas nuestros '),
                              TextSpan(
                                text: 'Términos de uso',
                                style: TextStyle(color: cs.primary),
                              ),
                              const TextSpan(text: ' y '),
                              TextSpan(
                                text: 'Política de privacidad',
                                style: TextStyle(color: cs.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Login row ──────────────────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta? ',
                            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Iniciar sesión',
                              style: tt.bodySmall?.copyWith(
                                color:      cs.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
