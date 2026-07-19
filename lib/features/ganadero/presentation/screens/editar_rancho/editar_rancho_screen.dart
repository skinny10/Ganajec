import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/services/mexico_geo_service.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/editar_rancho_viewmodel.dart';

class EditarRanchoScreen extends StatefulWidget {
  const EditarRanchoScreen({super.key});

  @override
  State<EditarRanchoScreen> createState() => _EditarRanchoScreenState();
}

class _EditarRanchoScreenState extends State<EditarRanchoScreen> {
  // Geo data
  Map<String, List<String>> _geoData = {};
  bool _geoLoading = true;
  String? _geoError;

  // Selección actual
  String? _estadoSel;
  String? _municipioSel;

  @override
  void initState() {
    super.initState();
    context.read<EditarRanchoViewModel>().addListener(_onVmChange);
    _cargarGeo();
  }

  @override
  void dispose() {
    context.read<EditarRanchoViewModel>().removeListener(_onVmChange);
    super.dispose();
  }

  Future<void> _cargarGeo() async {
    try {
      final data = await MexicoGeoService.cargar();
      if (!mounted) return;
      final vm = context.read<EditarRanchoViewModel>();

      // Pre-seleccionar con los valores actuales del rancho
      final estadoActual = vm.estadoCtrl.text.trim();
      final municipioActual = vm.municipioCtrl.text.trim();

      String? estadoMatch;
      String? municipioMatch;

      if (estadoActual.isNotEmpty) {
        // Buscar coincidencia exacta o parcial (case-insensitive)
        for (final k in data.keys) {
          if (k.toLowerCase() == estadoActual.toLowerCase()) {
            estadoMatch = k;
            break;
          }
        }
        estadoMatch ??= data.keys.firstWhere(
          (k) => k.toLowerCase().contains(estadoActual.toLowerCase()),
          orElse: () => '',
        );
        if (estadoMatch!.isEmpty) estadoMatch = null;
      }

      if (estadoMatch != null && municipioActual.isNotEmpty) {
        final mpios = data[estadoMatch] ?? [];
        for (final m in mpios) {
          if (m.toLowerCase() == municipioActual.toLowerCase()) {
            municipioMatch = m;
            break;
          }
        }
      }

      setState(() {
        _geoData = data;
        _geoLoading = false;
        _estadoSel = estadoMatch;
        _municipioSel = municipioMatch;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _geoLoading = false;
        _geoError = 'No se pudo cargar la lista de estados';
      });
    }
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

  List<String> get _municipiosDisponibles {
    if (_estadoSel == null) return [];
    return _geoData[_estadoSel!] ?? [];
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
            // Error banner API
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

            // Nombre del rancho (texto libre)
            _Field(
              label: 'Nombre del rancho',
              ctrl: vm.nombreCtrl,
              hint: 'Ej: Rancho La Esperanza',
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: 16),

            // ── Estado (dropdown) ───────────────────────────────────────────
            _DropdownLabel(label: 'Estado', icon: Icons.map_outlined),
            const SizedBox(height: 7),
            _geoLoading
                ? _LoadingDropdown()
                : _geoError != null
                    ? _ErrorDropdown(
                        error: _geoError!,
                        onRetry: () {
                          setState(() {
                            _geoLoading = true;
                            _geoError = null;
                          });
                          MexicoGeoService.limpiarCache();
                          _cargarGeo();
                        },
                      )
                    : _StyledDropdown<String>(
                        hint: 'Selecciona un estado',
                        value: _estadoSel,
                        items: _geoData.keys.toList(),
                        onChanged: (v) {
                          setState(() {
                            _estadoSel = v;
                            _municipioSel = null;
                            vm.estadoCtrl.text = v ?? '';
                            vm.municipioCtrl.text = '';
                          });
                        },
                      ),

            const SizedBox(height: 16),

            // ── Municipio (dropdown dependiente) ───────────────────────────
            _DropdownLabel(label: 'Municipio', icon: Icons.location_city_outlined),
            const SizedBox(height: 7),
            _geoLoading
                ? _LoadingDropdown()
                : _StyledDropdown<String>(
                    hint: _estadoSel == null
                        ? 'Primero selecciona un estado'
                        : 'Selecciona un municipio',
                    value: _municipioSel,
                    items: _municipiosDisponibles,
                    enabled: _estadoSel != null && _municipiosDisponibles.isNotEmpty,
                    onChanged: (v) {
                      setState(() {
                        _municipioSel = v;
                        vm.municipioCtrl.text = v ?? '';
                      });
                    },
                  ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.onSurface,
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
                          color: Colors.white,
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

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

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

class _DropdownLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _DropdownLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: cs.outline, size: 15),
        const SizedBox(width: 6),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

class _StyledDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final bool enabled;

  const _StyledDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      menuMaxHeight: 320,
      icon: Icon(Icons.keyboard_arrow_down_rounded,
          color: enabled ? cs.onSurface : cs.outline, size: 20),
      decoration: InputDecoration(
        filled: true,
        fillColor: enabled
            ? cs.surfaceContainerLowest
            : cs.surfaceContainerLowest.withOpacity(0.5),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outlineVariant.withOpacity(0.5)),
        ),
      ),
      hint: Text(
        hint,
        style: tt.bodyMedium?.copyWith(
          color: cs.outline,
          fontWeight: FontWeight.w300,
          fontSize: 14,
        ),
      ),
      style: tt.bodyMedium?.copyWith(fontSize: 14, color: cs.onSurface),
      dropdownColor: cs.surface,
      items: items
          .map((e) => DropdownMenuItem<T>(
                value: e,
                child: Text(e.toString()),
              ))
          .toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}

class _LoadingDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.outline,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Cargando estados...',
            style: TextStyle(color: cs.outline, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorDropdown extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorDropdown({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.errorContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.wifi_off_rounded, color: cs.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
