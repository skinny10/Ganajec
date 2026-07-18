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
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ganadero registrado exitosamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.tertiary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrarGanaderoViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Registrar ganadero',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.tertiary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Text('👨‍🌾', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El ganadero recibirá acceso al rancho y podrá registrar y monitorear su hato.',
                      style: tt.bodySmall?.copyWith(
                        fontSize: 12.5,
                        color: cs.onTertiaryContainer,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            if (vm.error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: cs.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.error!,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onErrorContainer,
                          fontSize: 13,
                        ),
                      ),
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
                  backgroundColor: cs.onSurface,
                  foregroundColor: cs.surface,
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
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.surface,
                        ),
                      )
                    : Text(
                        'Registrar ganadero',
                        style: tt.labelLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
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

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: tt.bodyMedium?.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodySmall?.copyWith(
              color: cs.outline,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: Icon(icon, color: cs.outline, size: 18),
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.onSurface, width: 1.5),
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

  const _PasswordField({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.visible,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          obscureText: !visible,
          style: tt.bodyMedium?.copyWith(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodySmall?.copyWith(
              color: cs.outline,
              fontWeight: FontWeight.w300,
            ),
            prefixIcon: Icon(Icons.lock_outline, color: cs.outline, size: 18),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                visible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: cs.outline,
                size: 18,
              ),
            ),
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.onSurface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
