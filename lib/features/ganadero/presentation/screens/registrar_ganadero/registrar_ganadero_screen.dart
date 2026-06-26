import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/registrar_ganadero_viewmodel.dart';

class RegistrarGanaderoScreen extends StatefulWidget {
  const RegistrarGanaderoScreen({super.key});

  @override
  State<RegistrarGanaderoScreen> createState() =>
      _RegistrarGanaderoScreenState();
}

class _RegistrarGanaderoScreenState
    extends State<RegistrarGanaderoScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kRed = Color(0xFFC0392B);

  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
    context
        .read<RegistrarGanaderoViewModel>()
        .addListener(_onVmChange);
  }

  @override
  void dispose() {
    context
        .read<RegistrarGanaderoViewModel>()
        .removeListener(_onVmChange);
    super.dispose();
  }

  void _onVmChange() {
    final vm = context.read<RegistrarGanaderoViewModel>();
    if (vm.isSuccess) {
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ganadero registrado exitosamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1D7A55),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrarGanaderoViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Registrar ganadero',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Descripción
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: _kGreen.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Text('👨‍🌾', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El ganadero recibirá acceso al rancho y podrá registrar y monitorear su hato.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF1D7A55),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Error banner
            if (vm.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDEDEC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: _kRed, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(vm.error!,
                          style: const TextStyle(
                              color: _kRed, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            _Field(
              label: 'Nombre completo',
              ctrl: vm.nombreCtrl,
              hint: 'Ej: Juan Pérez García',
              icon: Icons.person_outline,
              keyboardType: TextInputType.name,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Correo electrónico',
              ctrl: vm.emailCtrl,
              hint: 'ganadero@ejemplo.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _PasswordField(
              label: 'Contraseña',
              ctrl: vm.passwordCtrl,
              hint: 'Mínimo 6 caracteres',
              visible: _passwordVisible,
              onToggle: () =>
                  setState(() => _passwordVisible = !_passwordVisible),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kTextPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  elevation: 0,
                ),
                onPressed: vm.isLoading
                    ? null
                    : () => context
                        .read<RegistrarGanaderoViewModel>()
                        .registrar(),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Registrar ganadero',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _kTextMuted, fontWeight: FontWeight.w300),
            prefixIcon: Icon(icon, color: _kTextMuted, size: 18),
            filled: true,
            fillColor: _kSurface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _kTextPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final bool visible;
  final VoidCallback onToggle;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  const _PasswordField({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          obscureText: !visible,
          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _kTextMuted, fontWeight: FontWeight.w300),
            prefixIcon: const Icon(Icons.lock_outline,
                color: _kTextMuted, size: 18),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: _kTextMuted,
                size: 18,
              ),
            ),
            filled: true,
            fillColor: _kSurface,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _kBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: _kTextPrimary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
