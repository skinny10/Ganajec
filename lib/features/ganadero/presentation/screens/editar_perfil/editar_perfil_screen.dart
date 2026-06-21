import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/editar_perfil_viewmodel.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreen = Color(0xFF2E7D32);

  @override
  void initState() {
    super.initState();
    // Escuchamos cambios para reaccionar al éxito UNA sola vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditarPerfilViewModel>().addListener(_onVmChange);
    });
  }

  void _onVmChange() {
    final vm = context.read<EditarPerfilViewModel>();
    if (vm.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado'),
          backgroundColor: Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    // Removemos el listener para no llamar al vm después de dispose
    context.read<EditarPerfilViewModel>().removeListener(_onVmChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarPerfilViewModel>();

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
          'Editar perfil',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: vm.isLoading
                ? null
                : () => context.read<EditarPerfilViewModel>().guardar(),
            child: vm.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Guardar',
                    style: TextStyle(
                      color: _kGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                const SizedBox(height: 8),
                ListenableBuilder(
                  listenable: vm.nombreCtrl,
                  builder: (_, __) => CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFF4CAF50),
                    child: Text(
                      _initials(vm.nombreCtrl.text),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Foto de perfil — próximamente',
                  style:
                      TextStyle(fontSize: 12, color: _kTextSecondary),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),

          // Error
          if (vm.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                vm.error!,
                style: const TextStyle(
                    color: Color(0xFFC0392B), fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Campo nombre
          _label('Nombre completo'),
          const SizedBox(height: 6),
          _field(
            controller: vm.nombreCtrl,
            hint: 'Tu nombre completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Campo email
          _label('Correo electrónico'),
          const SizedBox(height: 6),
          _field(
            controller: vm.emailCtrl,
            hint: 'correo@ejemplo.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),

          // Botón guardar
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: vm.isLoading
                  ? null
                  : () =>
                      context.read<EditarPerfilViewModel>().guardar(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)
                  : const Text(
                      'Guardar cambios',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0]
        .substring(0, parts[0].length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: _kTextSecondary,
          letterSpacing: 0.3,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) =>
      Container(
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
              fontSize: 15,
              color: _kTextPrimary,
              fontWeight: FontWeight.w400),
          decoration: InputDecoration(
            prefixIcon:
                Icon(icon, color: _kTextSecondary, size: 18),
            hintText: hint,
            hintStyle:
                TextStyle(color: _kTextSecondary.withOpacity(0.6)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
          ),
        ),
      );
}
