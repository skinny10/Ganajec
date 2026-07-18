import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import '../../viewmodels/historial_viewmodel.dart';

// ─── Barra de búsqueda + chips ───────────────────────────────────────────────

class HistorialFilterBar extends StatefulWidget {
  final HistorialViewModel vm;

  const HistorialFilterBar({super.key, required this.vm});

  @override
  State<HistorialFilterBar> createState() => _HistorialFilterBarState();
}

class _HistorialFilterBarState extends State<HistorialFilterBar> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final vm = widget.vm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buscador
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
          child: TextField(
            controller: _ctrl,
            onChanged: vm.setBusqueda,
            style: tt.bodyMedium?.copyWith(fontSize: 13.5, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Buscar por animal o enfermedad…',
              hintStyle: tt.bodyMedium?.copyWith(
                  color: cs.outline, fontWeight: FontWeight.w300),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search_rounded, color: cs.outline, size: 18),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: cs.surfaceContainerLowest,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: BorderSide(color: cs.onSurface, width: 1.5),
              ),
            ),
          ),
        ),
        // Chips de filtro
        SizedBox(
          height: 36,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            children: [
              _Chip(
                label: 'Todos',
                active: vm.filtroTipo == HistorialFiltroTipo.todos &&
                    vm.animalFiltro == null,
                onTap: () => vm.setFiltroTipo(HistorialFiltroTipo.todos),
              ),
              _Chip(
                label: '🔴 Severidad alta',
                active: vm.filtroTipo == HistorialFiltroTipo.alta,
                onTap: () => vm.setFiltroTipo(HistorialFiltroTipo.alta),
              ),
              _Chip(
                label: '🟡 Moderada',
                active: vm.filtroTipo == HistorialFiltroTipo.moderada,
                onTap: () => vm.setFiltroTipo(HistorialFiltroTipo.moderada),
              ),
              _Chip(
                label: '🟢 Leve / Sin',
                active: vm.filtroTipo == HistorialFiltroTipo.leve,
                onTap: () => vm.setFiltroTipo(HistorialFiltroTipo.leve),
              ),
              ...vm.animalesDisponibles.map((nombre) => _Chip(
                    label: nombre,
                    active: vm.animalFiltro == nombre,
                    onTap: () => vm.setAnimalFiltro(nombre),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? cs.onSurface : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? cs.onSurface : cs.outlineVariant,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: tt.labelSmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: active ? cs.surface : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

// ─── Quick Stats ──────────────────────────────────────────────────────────────

class HistorialQuickStats extends StatelessWidget {
  final int alta;
  final int total;
  final int sinEnfermedad;

  const HistorialQuickStats({
    super.key,
    required this.alta,
    required this.total,
    required this.sinEnfermedad,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        children: [
          _QStat(value: '$alta', label: 'Severidad alta', color: cs.error),
          const SizedBox(width: 8),
          _QStat(value: '$total', label: 'Total este mes', color: cs.onSurface),
          const SizedBox(width: 8),
          _QStat(value: '$sinEnfermedad', label: 'Sin enfermedad', color: cs.tertiary),
        ],
      ),
    );
  }
}

class _QStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _QStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: tt.titleMedium?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: tt.labelSmall?.copyWith(
                fontSize: 9.5,
                color: cs.outline,
                fontWeight: FontWeight.w300,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Grupo de fecha ───────────────────────────────────────────────────────────

class HistorialDateGroup extends StatelessWidget {
  final HistorialGrupo grupo;
  final void Function(HistorialItem item) onTap;

  const HistorialDateGroup({
    super.key,
    required this.grupo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            grupo.titulo.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: cs.outline,
              letterSpacing: 0.08 * 10,
            ),
          ),
        ),
        ...grupo.items.map(
          (item) => HistorialCard(item: item, onTap: () => onTap(item)),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Tarjeta de predicción ────────────────────────────────────────────────────

class HistorialCard extends StatelessWidget {
  final HistorialItem item;
  final VoidCallback onTap;

  const HistorialCard({super.key, required this.item, required this.onTap});

  static _SevConfig _configFor(HistorialSeveridad sev, ColorScheme cs) {
    return switch (sev) {
      HistorialSeveridad.alta => _SevConfig(
          bar: cs.error,
          bg: cs.errorContainer,
          text: cs.error,
          label: 'Alta',
        ),
      HistorialSeveridad.moderada => _SevConfig(
          bar: cs.secondary,
          bg: cs.secondaryContainer,
          text: cs.secondary,
          label: 'Moderada',
        ),
      HistorialSeveridad.leve => _SevConfig(
          bar: cs.tertiary,
          bg: cs.tertiaryContainer,
          text: cs.tertiary,
          label: 'Leve',
        ),
      HistorialSeveridad.sinEnfermedad => _SevConfig(
          bar: cs.tertiary,
          bg: cs.tertiaryContainer,
          text: cs.tertiary,
          label: 'Sano',
        ),
    };
  }

  String _horaOFecha(DateTime fecha) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final ayer = hoy.subtract(const Duration(days: 1));
    final d = DateTime(fecha.year, fecha.month, fecha.day);

    if (!d.isBefore(hoy) || !d.isBefore(ayer.add(const Duration(days: 1)))) {
      final h = fecha.hour;
      final m = fecha.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'pm' : 'am';
      final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$h12:$m $period';
    }
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cfg = _configFor(item.severidad, cs);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Barra lateral de color
                Container(width: 4, color: cfg.bar),
                // Contenido
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 11, 12, 11),
                    child: Row(
                      children: [
                        // Icono
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cfg.bg,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Center(
                            child: Text(
                              item.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.enfermedad,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodyMedium?.copyWith(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '🐄 ${item.animalNombre} · ${item.animalIdExterno}',
                                style: tt.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: cs.outline,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Derecha: confianza + badge + hora
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${item.confianzaPct}%',
                              style: tt.titleMedium?.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: cfg.bg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                cfg.label,
                                style: tt.labelSmall?.copyWith(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: cfg.text,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _horaOFecha(item.fecha),
                              style: tt.labelSmall?.copyWith(
                                fontSize: 10,
                                color: cs.outline,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SevConfig {
  final Color bar;
  final Color bg;
  final Color text;
  final String label;
  const _SevConfig({
    required this.bar,
    required this.bg,
    required this.text,
    required this.label,
  });
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class HistorialEmptyState extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onLimpiar;

  const HistorialEmptyState({
    super.key,
    required this.hasFilters,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Sin resultados',
            style: tt.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'No encontramos predicciones que coincidan\ncon tu búsqueda.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              fontSize: 12,
              color: cs.outline,
              fontWeight: FontWeight.w300,
              height: 1.6,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 14),
            GestureDetector(
              onTap: onLimpiar,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Limpiar filtros',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
