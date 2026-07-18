import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/cambiar_contrasena_viewmodel.dart';

class CambiarContrasenaScreen extends StatefulWidget {
  const CambiarContrasenaScreen({super.key});

  @override
  State<CambiarContrasenaScreen> createState() =>
      _CambiarContrasenaScreenState();
}

class _CambiarContrasenaScreenState extends State<CambiarContrasenaScreen> {
  bool _verNueva = false;
  bool _verConfirmar = false;

  @override
  void initState() {
    super.initState();
    context.read<CambiarContrasenaViewModel>().addListener(_onVmChange);
  }

  @override
  void dispose() {
    context.read<CambiarContrasenaViewModel>().removeListener(_onVmChange);
    super.dispose();
  }

  void _onVmChange() {
    final vm = context.read<CambiarContrasenaViewModel>();
    if (!mounted) return;
    if (vm.isSuccess) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contraseña actualizada correctamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.tertiary,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<CambiarContrasenaViewModel>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : null,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(
              Icons.chevron_left_rounded,
              color: cs.onSurface,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Cambiar contraseña',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: [
          // Ícono ilustrativo
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Center(
                child: Text('🔑', style: TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Nueva contraseña',
              style: tt.titleSmall?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Define tu nueva contraseña de acceso.',
              textAlign: TextAlign.center,
              style: tt.bodySmall?.copyWith(
                fontSize: 13,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Error banner
          if (vm.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.error.withOpacity(0.3)),
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

          // Campo: nueva contraseña
          _label(context, 'Nueva contraseña'),
          const SizedBox(height: 6),
          _passwordField(
            context,
            controller: vm.nuevaCtrl,
            hint: 'Mínimo 6 caracteres',
            visible: _verNueva,
            onToggle: () => setState(() => _verNueva = !_verNueva),
          ),
          const SizedBox(height: 16),

          // Campo: confirmar nueva
          _label(context, 'Confirmar nueva contraseña'),
          const SizedBox(height: 6),
          _passwordField(
            context,
            controller: vm.confirmarCtrl,
            hint: 'Repite tu nueva contraseña',
            visible: _verConfirmar,
            onToggle: () => setState(() => _verConfirmar = !_verConfirmar),
          ),
          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading ? null : vm.cambiar,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.tertiary,
                foregroundColor: cs.onTertiary,
                disabledBackgroundColor: cs.tertiary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: cs.onTertiary, strokeWidth: 2),
                    )
                  : Text(
                      'Actualizar contraseña',
                      style: tt.labelLarge?.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      text,
      style: tt.labelSmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _passwordField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: TextField(
        controller: controller,
        obscureText: !visible,
        style: tt.bodyMedium?.copyWith(fontSize: 14, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: tt.bodySmall?.copyWith(
              color: cs.outline,
              fontSize: 13,
              fontWeight: FontWeight.w300),
          prefixIcon: Icon(Icons.lock_outline,
              color: cs.onSurfaceVariant, size: 18),
          suffixIcon: GestureDetector(
            onTap: onToggle,
            child: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: cs.onSurfaceVariant,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
