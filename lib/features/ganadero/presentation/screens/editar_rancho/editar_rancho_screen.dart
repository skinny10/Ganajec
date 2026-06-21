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
  static const _kBg = Color(0xFFFAFAF7);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);
  static const _kGreen = Color(0xFF1D7A55);
  static const _kRed = Color(0xFFC0392B);

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
      context.pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rancho actualizado'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF1D7A55),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditarRanchoViewModel>();

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
          'Editar rancho',
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
                  backgroundColor: _kTextPrimary,
                  foregroundColor: Colors.white,
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
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w500),
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

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextMuted = Color(0xFFAEADA6);

  const _Field({
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.icon,
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
          style: const TextStyle(fontSize: 14, color: _kTextPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _kTextMuted, fontWeight: FontWeight.w300),
            prefixIcon:
                Icon(icon, color: _kTextMuted, size: 18),
            filled: true,
            fillColor: _kSurface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
