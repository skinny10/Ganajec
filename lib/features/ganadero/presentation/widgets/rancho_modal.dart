import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/token_storage.dart';
import '../viewmodels/rancho_modal_viewmodel.dart';

Future<bool> mostrarRanchoModal(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider(
      create: (_) => RanchoModalViewModel(),
      child: const _RanchoModalSheet(),
    ),
  );
  return result == true;
}

class _RanchoModalSheet extends StatefulWidget {
  const _RanchoModalSheet();
  @override
  State<_RanchoModalSheet> createState() => _RanchoModalSheetState();
}

class _RanchoModalSheetState extends State<_RanchoModalSheet> {
  // 0 = Unirse, 1 = Crear
  int _tab = 0;

  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RanchoModalViewModel>();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final esDueno = TokenStorage.role == 'dueno';

    // Si ya creó el rancho y obtuvo código → vista de éxito
    if (vm.isSuccess && _tab == 1 && vm.codigoGenerado != null) {
      return _sheet(
        bottom: bottom,
        child: _CodigoGeneradoView(codigo: vm.codigoGenerado!),
      );
    }

    return _sheet(
      bottom: bottom,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            '🏡  Sin rancho asignado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            esDueno
                ? 'Únete a un rancho con un código, o crea el tuyo propio.'
                : 'Ingresa el código de invitación que te dio el dueño del rancho.',
            style: const TextStyle(fontSize: 13, color: _kTextSecondary),
          ),
          const SizedBox(height: 20),

          // Segmented control manual (evita TabBarView sin altura acotada)
          // Solo dueños pueden crear ranchos
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

          // Error
          if (vm.error != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDEDEC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(vm.error!,
                  style: const TextStyle(
                      color: Color(0xFFC0392B), fontSize: 13)),
            ),
            const SizedBox(height: 12),
          ],

          // Contenido: ganaderos siempre ven solo "Unirse"
          if (!esDueno || _tab == 0)
            _TabUnirse(vm: vm)
          else
            _TabCrear(vm: vm),
        ],
      ),
    );
  }

  Widget _sheet({required Widget child, required double bottom}) =>
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFAFAF7),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
  const _TabChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2E7D32) : const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE8E5DC),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : const Color(0xFF888880),
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _field(
          controller: vm.codigoCtrl,
          hint: 'XXXXXXXX',
          icon: Icons.key_outlined,
          extra: TextInputType.text,
          caps: TextCapitalization.characters,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        _btn(
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
        _field(
            controller: vm.nombreRanchoCtrl,
            hint: 'Nombre del rancho',
            icon: Icons.home_outlined),
        const SizedBox(height: 8),
        _field(
            controller: vm.municipioCtrl,
            hint: 'Municipio',
            icon: Icons.location_city_outlined),
        const SizedBox(height: 8),
        _field(
            controller: vm.estadoCtrl,
            hint: 'Estado',
            icon: Icons.map_outlined),
        const SizedBox(height: 14),
        _btn(
          label: 'Crear mi rancho',
          isLoading: vm.isLoading,
          onTap: () => vm.crearRancho(),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Helpers compartidos ───────────────────────────────────────────────────────

Widget _field({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType? extra,
  TextCapitalization caps = TextCapitalization.none,
  TextStyle? style,
}) =>
    Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E5DC)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: extra,
        textCapitalization: caps,
        style: style ??
            const TextStyle(fontSize: 14, color: Color(0xFF1A1A1A)),
        decoration: InputDecoration(
          prefixIcon:
              Icon(icon, color: const Color(0xFF888880), size: 18),
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFFAEADA6)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );

Widget _btn({
  required String label,
  required bool isLoading,
  required VoidCallback onTap,
}) =>
    SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );

// ── Vista código generado ─────────────────────────────────────────────────────

class _CodigoGeneradoView extends StatelessWidget {
  final String codigo;
  const _CodigoGeneradoView({required this.codigo});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        const Text('🎉', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 12),
        const Text(
          '¡Rancho creado!',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A)),
        ),
        const SizedBox(height: 6),
        const Text(
          'Comparte este código para que tus ganaderos se unan',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Color(0xFF888880)),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF2E7D32).withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  codigo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 4,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(Icons.copy_outlined,
                    color: Color(0xFF2E7D32), size: 18),
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
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('Continuar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
