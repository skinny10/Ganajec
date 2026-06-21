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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kGreen = Color(0xFF2E7D32);
  static const _kRed = Color(0xFFC0392B);
  static const _kRedLight = Color(0xFFFDEDEC);

  bool _verActual = false;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada correctamente'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CambiarContrasenaViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.canPop() ? context.pop() : null,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(
              Icons.chevron_left_rounded,
              color: _kTextPrimary,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Cambiar contraseña',
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
        children: [
          // Ícono ilustrativo
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3EE),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _kBorder),
              ),
              child: const Center(
                child: Text('🔑', style: TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Nueva contraseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _kTextPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text(
              'Ingresa tu contraseña actual y define una nueva.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _kTextSecondary),
            ),
          ),
          const SizedBox(height: 28),

          // Error banner
          if (vm.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kRedLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFF5C6C2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: _kRed, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      vm.error!,
                      style: const TextStyle(color: _kRed, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Campo: contraseña actual
          _label('Contraseña actual'),
          const SizedBox(height: 6),
          _passwordField(
            controller: vm.actualCtrl,
            hint: '••••••••',
            visible: _verActual,
            onToggle: () => setState(() => _verActual = !_verActual),
          ),
          const SizedBox(height: 16),

          // Campo: nueva contraseña
          _label('Nueva contraseña'),
          const SizedBox(height: 6),
          _passwordField(
            controller: vm.nuevaCtrl,
            hint: 'Mínimo 6 caracteres',
            visible: _verNueva,
            onToggle: () => setState(() => _verNueva = !_verNueva),
          ),
          const SizedBox(height: 16),

          // Campo: confirmar nueva
          _label('Confirmar nueva contraseña'),
          const SizedBox(height: 6),
          _passwordField(
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
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: _kGreen.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Actualizar contraseña',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _kTextSecondary,
          letterSpacing: 0.3,
        ),
      );

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool visible,
    required VoidCallback onToggle,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: TextField(
          controller: controller,
          obscureText: !visible,
          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFAEADA6), fontSize: 13),
            prefixIcon: const Icon(Icons.lock_outline,
                color: _kTextSecondary, size: 18),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: _kTextSecondary,
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
