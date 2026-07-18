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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EditarPerfilViewModel>().addListener(_onVmChange);
    });
  }

  void _onVmChange() {
    final vm = context.read<EditarPerfilViewModel>();
    if (vm.isSuccess && mounted) {
      final cs = Theme.of(context).colorScheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil actualizado'),
          backgroundColor: cs.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  void dispose() {
    context.read<EditarPerfilViewModel>().removeListener(_onVmChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<EditarPerfilViewModel>();

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
          'Editar perfil',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          TextButton(
            onPressed: vm.isLoading
                ? null
                : () => context.read<EditarPerfilViewModel>().guardar(),
            child: vm.isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: cs.tertiary),
                  )
                : Text(
                    'Guardar',
                    style: tt.labelLarge?.copyWith(
                      color: cs.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
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
                    backgroundColor: cs.primary,
                    child: Text(
                      _initials(vm.nombreCtrl.text),
                      style: tt.titleMedium?.copyWith(
                        color: cs.onPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Foto de perfil — próximamente',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
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
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                vm.error!,
                style: tt.bodySmall?.copyWith(
                  color: cs.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Campo nombre
          _label(context, 'Nombre completo'),
          const SizedBox(height: 6),
          _field(
            context,
            controller: vm.nombreCtrl,
            hint: 'Tu nombre completo',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),

          // Campo email
          _label(context, 'Correo electrónico'),
          const SizedBox(height: 6),
          _field(
            context,
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
                  : () => context.read<EditarPerfilViewModel>().guardar(),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.tertiary,
                foregroundColor: cs.onTertiary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: vm.isLoading
                  ? CircularProgressIndicator(
                      color: cs.onTertiary, strokeWidth: 2)
                  : Text(
                      'Guardar cambios',
                      style: tt.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600),
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

  Widget _label(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Text(
      text,
      style: tt.labelSmall?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
        style: tt.bodyMedium?.copyWith(
          fontSize: 15,
          color: cs.onSurface,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant, size: 18),
          hintText: hint,
          hintStyle: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withOpacity(0.6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
