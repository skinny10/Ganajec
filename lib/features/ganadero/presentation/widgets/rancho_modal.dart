import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/token_storage.dart';
import '../viewmodels/rancho_modal_viewmodel.dart';

/// [initialTab] 0 = Unirse, 1 = Crear
Future<bool> mostrarRanchoModal(BuildContext context,
    {int initialTab = 0}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RanchoModalViewModel(),
      child: _RanchoModalSheet(initialTab: initialTab),
    ),
  );
  return result == true;
}

class _RanchoModalSheet extends StatefulWidget {
  final int initialTab;
  const _RanchoModalSheet({this.initialTab = 0});
  @override
  State<_RanchoModalSheet> createState() => _RanchoModalSheetState();
}

class _RanchoModalSheetState extends State<_RanchoModalSheet> {
  late int _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final vm     = context.watch<RanchoModalViewModel>();
    final cs     = Theme.of(context).colorScheme;
    final tt     = Theme.of(context).textTheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final esDueno = TokenStorage.role == 'dueno';

    if (vm.isSuccess && _tab == 1 && vm.codigoGenerado != null) {
      return _sheet(cs: cs, bottom: bottom,
          child: _CodigoGeneradoView(codigo: vm.codigoGenerado!));
    }

    return _sheet(
      cs: cs,
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            '🏡  Sin rancho asignado',
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            esDueno
                ? 'Únete a un rancho con un código, o crea el tuyo propio.'
                : 'Ingresa el código de invitación que te dio el dueño del rancho.',
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          if (esDueno)
            Row(
              children: [
                _TabChip(
                  label: 'Unirse con código',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Crear rancho',
                  selected: _tab == 1,
                  onTap: () => setState(() => _tab = 1),
                ),
              ],
            ),
          const SizedBox(height: 18),

          if (vm.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                vm.error!,
                style: tt.bodySmall?.copyWith(
                  color: cs.onErrorContainer,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          if (!esDueno || _tab == 0)
            _TabUnirse(vm: vm)
          else
            _TabCrear(vm: vm),
        ],
      ),
    );
  }

  Widget _sheet({required Widget child, required double bottom, required ColorScheme cs}) =>
      Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottom),
        child: SafeArea(top: false, child: child),
      );
}

// ── Chip de tab ──────────────────────────────────────────────────────────────

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.tertiary : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.tertiary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? cs.onTertiary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ── Tab: Unirse ──────────────────────────────────────────────────────────────

class _TabUnirse extends StatelessWidget {
  final RanchoModalViewModel vm;
  const _TabUnirse({required this.vm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModalField(
          controller: vm.codigoCtrl,
          hint: 'XXXXXXXX',
          icon: Icons.key_outlined,
          keyboardType: TextInputType.text,
          caps: TextCapitalization.characters,
          textStyle: tt.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 14),
        _ModalBtn(
          label: 'Unirme al rancho',
          isLoading: vm.isLoading,
          onTap: () async {
            await vm.unirse();
            if (vm.isSuccess && context.mounted) {
              Navigator.of(context).pop(true);
            }
          },
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Tab: Crear ───────────────────────────────────────────────────────────────

class _TabCrear extends StatelessWidget {
  final RanchoModalViewModel vm;
  const _TabCrear({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ModalField(controller: vm.nombreRanchoCtrl, hint: 'Nombre del rancho', icon: Icons.home_outlined),
        const SizedBox(height: 8),
        _ModalField(controller: vm.municipioCtrl, hint: 'Municipio', icon: Icons.location_city_outlined),
        const SizedBox(height: 8),
        _ModalField(controller: vm.estadoCtrl, hint: 'Estado', icon: Icons.map_outlined),
        const SizedBox(height: 14),
        _ModalBtn(
          label: 'Crear mi rancho',
          isLoading: vm.isLoading,
          onTap: () => vm.crearRancho(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Widgets helpers ───────────────────────────────────────────────────────────

class _ModalField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextCapitalization caps;
  final TextStyle? textStyle;

  const _ModalField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.caps = TextCapitalization.none,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
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
        textCapitalization: caps,
        style: textStyle ?? tt.bodyMedium?.copyWith(
          fontSize: 14,
          color: cs.onSurface,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: cs.onSurfaceVariant, size: 18),
          hintText: hint,
          hintStyle: tt.bodySmall?.copyWith(color: cs.outline),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _ModalBtn extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _ModalBtn({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.tertiary,
          foregroundColor: cs.onTertiary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(color: cs.onTertiary, strokeWidth: 2),
              )
            : Text(label,
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ── Vista código generado ─────────────────────────────────────────────────────

class _CodigoGeneradoView extends StatelessWidget {
  final String codigo;
  const _CodigoGeneradoView({required this.codigo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text('🎉', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        Text(
          '¡Rancho creado!',
          style: tt.titleLarge?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Comparte este código para que tus ganaderos se unan',
          textAlign: TextAlign.center,
          style: tt.bodySmall?.copyWith(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: codigo));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código copiado'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: cs.tertiaryContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.tertiary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  codigo,
                  style: tt.bodyLarge?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: cs.tertiary,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(Icons.copy_outlined, color: cs.tertiary, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.tertiary,
              foregroundColor: cs.onTertiary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Continuar',
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
