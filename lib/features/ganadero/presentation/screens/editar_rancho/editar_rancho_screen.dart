import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/editar_rancho_viewmodel.dart';

class EditarRanchoScreen extends StatefulWidget {
  const EditarRanchoScreen({super.key});

  @override
  State<EditarRanchoScreen> createState() => _EditarRanchoScreenState();
}

class _EditarRanchoScreenState extends State<EditarRanchoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<EditarRanchoViewModel>().addListener(_onVmChange);
  }

  @override
  void dispose() {
    context.read<EditarRanchoViewModel>().removeListener(_onVmChange);
    super.dispose();
  }

  void _onVmChange() {
    final vm = context.read<EditarRanchoViewModel>();
    if (vm.isSuccess) {
      final cs = Theme.of(context).colorScheme;
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Rancho actualizado'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.tertiary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = context.watch<EditarRanchoViewModel>();

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
          'Editar rancho',
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
            // Error banner
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
              label: 'Nombre del rancho',
              ctrl: vm.nombreCtrl,
              hint: 'Ej: Rancho La Esperanza',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Municipio',
              ctrl: vm.municipioCtrl,
              hint: 'Ej: Ocosingo',
              icon: Icons.location_city_outlined,
            ),
            const SizedBox(height: 16),
            _Field(
              label: 'Estado',
              ctrl: vm.estadoCtrl,
              hint: 'Ej: Chiapas',
              icon: Icons.map_outlined,
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
                        .read<EditarRanchoViewModel>()
                        .guardar(),
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
                        'Guardar cambios',
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

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
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
            color: cs.onSurface,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: ctrl,
          style: tt.bodyMedium?.copyWith(fontSize: 14, color: cs.onSurface),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: tt.bodyMedium?.copyWith(
                color: cs.outline, fontWeight: FontWeight.w300),
            prefixIcon: Icon(icon, color: cs.outline, size: 18),
            filled: true,
            fillColor: cs.surfaceContainerLowest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
