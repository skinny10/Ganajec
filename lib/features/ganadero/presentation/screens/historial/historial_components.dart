import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import '../../viewmodels/historial_viewmodel.dart';

// ─── Paleta ──────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAF7);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kCream = Color(0xFFF5F3EE);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kGreen = Color(0xFF1D7A55);
const _kGreenLight = Color(0xFFE8F5EF);
const _kRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFFDEDEC);
const _kYellow = Color(0xFFB8860B);
const _kYellowLight = Color(0xFFFEF9E7);
const _kAmber = Color(0xFFD4A017);

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
            style: const TextStyle(fontSize: 13.5, color: _kTextPrimary),
            decoration: InputDecoration(
              hintText: 'Buscar por animal o enfermedad…',
              hintStyle: const TextStyle(
                  color: _kTextMuted, fontWeight: FontWeight.w300),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search_rounded, color: _kTextMuted, size: 18),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              filled: true,
              fillColor: _kSurface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _kBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(color: _kBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide:
                    const BorderSide(color: _kTextPrimary, width: 1.5),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? _kTextPrimary : _kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? _kTextPrimary : _kBorder,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: active ? Colors.white : _kTextSecondary,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      child: Row(
        children: [
          _QStat(value: '$alta', label: 'Severidad alta', color: _kRed),
          const SizedBox(width: 8),
          _QStat(value: '$total', label: 'Total este mes', color: _kTextPrimary),
          const SizedBox(width: 8),
          _QStat(
              value: '$sinEnfermedad',
              label: 'Sin enfermedad',
              color: _kGreen),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
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
              style: const TextStyle(
                fontSize: 9.5,
                color: _kTextMuted,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 2),
          child: Text(
            grupo.titulo.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _kTextMuted,
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

  static _SevConfig _configFor(HistorialSeveridad sev) {
    return switch (sev) {
      HistorialSeveridad.alta =>
        const _SevConfig(bar: _kRed, bg: _kRedLight, text: _kRed, label: 'Alta'),
      HistorialSeveridad.moderada => const _SevConfig(
          bar: _kAmber, bg: _kYellowLight, text: _kYellow, label: 'Moderada'),
      HistorialSeveridad.leve =>
        const _SevConfig(bar: _kGreen, bg: _kGreenLight, text: _kGreen, label: 'Leve'),
      HistorialSeveridad.sinEnfermedad =>
        const _SevConfig(bar: _kGreen, bg: _kGreenLight, text: _kGreen, label: 'Sano'),
    };
  }

  String _horaOFecha(DateTime fecha) {
    final now = DateTime.now();
    final hoy = DateTime(now.year, now.month, now.day);
    final ayer = hoy.subtract(const Duration(days: 1));
    final d = DateTime(fecha.year, fecha.month, fecha.day);

    if (!d.isBefore(hoy) || !d.isBefore(ayer.add(const Duration(days: 1)))) {
      // Hoy o ayer: mostrar hora
      final h = fecha.hour;
      final m = fecha.minute.toString().padLeft(2, '0');
      final period = h >= 12 ? 'pm' : 'am';
      final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
      return '$h12:$m $period';
    }
    // Esta semana / meses: mostrar "3 jun"
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final cfg = _configFor(item.severidad);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
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
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                  color: _kTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '🐄 ${item.animalNombre} · ${item.animalIdExterno}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: _kTextMuted,
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: _kTextPrimary,
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
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: cfg.text,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _horaOFecha(item.fecha),
                              style: const TextStyle(
                                fontSize: 10,
                                color: _kTextMuted,
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
  const _SevConfig(
      {required this.bar,
      required this.bg,
      required this.text,
      required this.label});
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Sin resultados',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _kTextPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'No encontramos predicciones que coincidan\ncon tu búsqueda.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _kTextMuted,
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
                  border: Border.all(color: _kBorder),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Limpiar filtros',
                  style: TextStyle(
                    fontSize: 12,
                    color: _kTextSecondary,
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
