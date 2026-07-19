import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/detalle_bovino_viewmodel.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

int _calcularEdad(DateTime fechaNacimiento) {
  final now = DateTime.now();
  int years = now.year - fechaNacimiento.year;
  if (now.month < fechaNacimiento.month ||
      (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
    years--;
  }
  return years;
}

String _severidadPrediccion(Prediccion p) {
  if (p.enfermedad.toLowerCase().contains('sin enfermedad')) return 'Leve';
  if (p.confianza >= 0.8) return 'Alta';
  if (p.confianza >= 0.6) return 'Media';
  return 'Leve';
}

String _fechaRelativa(DateTime fecha) {
  final diff = DateTime.now().difference(fecha);
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) {
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    if (m == 0) return 'Hace $h h';
    return 'Hoy, ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')} am';
  }
  if (diff.inDays == 1) return 'Ayer';
  return 'Hace ${diff.inDays} días';
}

// ─── Metadatos de métricas ────────────────────────────────────────────────────

class _MetricaMeta {
  final String label;
  final String unidad;
  const _MetricaMeta(this.label, this.unidad);
}

const _metricasMeta = <String, _MetricaMeta>{
  'temperatura_corporal':    _MetricaMeta('Temperatura corporal',   '°C'),
  'produccion_leche_litros': _MetricaMeta('Producción de leche',    'L'),
  'consumo_alimento_kg':     _MetricaMeta('Consumo de alimento',    'kg'),
  'consumo_agua_litros':     _MetricaMeta('Consumo de agua',        'L'),
  'frecuencia_cardiaca':     _MetricaMeta('Frecuencia cardíaca',    'bpm'),
  'frecuencia_respiratoria': _MetricaMeta('Frec. respiratoria',     'rpm'),
  'condicion_corporal':      _MetricaMeta('Condición corporal',     ''),
};

Color _metricaColor(String key, ColorScheme cs) {
  switch (key) {
    case 'temperatura_corporal':    return cs.error;
    case 'produccion_leche_litros': return cs.secondary;
    case 'consumo_alimento_kg':     return cs.tertiary;
    case 'consumo_agua_litros':     return cs.onTertiaryContainer;
    case 'frecuencia_cardiaca':     return cs.onSecondaryContainer;
    case 'frecuencia_respiratoria': return cs.onPrimaryContainer;
    case 'condicion_corporal':      return cs.primary;
    default:                        return cs.onSurface;
  }
}

// ─── Hero card ────────────────────────────────────────────────────────────────

class DetalleAnimalHero extends StatelessWidget {
  final Animal animal;
  final DetalleBovinoViewModel vm;

  const DetalleAnimalHero({
    super.key,
    required this.animal,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final edad = _calcularEdad(animal.fechaNacimiento);
    final esAlerta = vm.tieneAnomaliaActiva;
    final accentColor = esAlerta ? cs.error : cs.tertiary;
    final badgeBg    = esAlerta ? cs.errorContainer : cs.tertiaryContainer;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: cs.onSurface.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 5, color: accentColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 18, 18, 18),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: cs.primaryContainer,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('🐄', style: TextStyle(fontSize: 30)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            animal.nombre,
                            style: tt.titleMedium?.copyWith(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${animal.raza} · $edad años · ${animal.idExterno}',
                            style: tt.bodySmall?.copyWith(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  esAlerta ? '⚠️' : '❤️',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  vm.severidadLabel,
                                  style: tt.labelSmall?.copyWith(
                                    color: accentColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 0.4).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────

class DetalleInfoGrid extends StatelessWidget {
  final Animal animal;
  final DetalleBovinoViewModel vm;

  const DetalleInfoGrid({
    super.key,
    required this.animal,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final edad = _calcularEdad(animal.fechaNacimiento);
    final prodHoy = vm.produccionHoy;
    final prodColor = vm.tieneAnomaliaActiva ? cs.error : cs.tertiary;
    final prodLabel = vm.tieneAnomaliaActiva
        ? '${prodHoy.toStringAsFixed(0)} L ↓'
        : '${prodHoy.toStringAsFixed(0)} L';

    final isMacho = animal.sexo.toLowerCase() == 'macho';

    final items = [
      _InfoItem(
        label: 'Raza',
        value: animal.raza,
        icon: Icons.pets,
        iconBg: cs.primaryContainer,
        iconColor: cs.onPrimaryContainer,
      ),
      _InfoItem(
        label: 'Edad',
        value: '$edad años',
        icon: Icons.calendar_today_outlined,
        iconBg: cs.surfaceContainerLow,
        iconColor: cs.onSurfaceVariant,
      ),
      _InfoItem(
        label: 'Peso',
        value: '${animal.pesoKg.toStringAsFixed(1)} kg',
        icon: Icons.monitor_weight_outlined,
        iconBg: cs.surfaceContainerLow,
        iconColor: cs.onSurfaceVariant,
      ),
      _InfoItem(
        label: 'Sexo',
        value: _capitalized(animal.sexo),
        icon: isMacho ? Icons.male : Icons.female,
        iconBg: cs.tertiaryContainer,
        iconColor: cs.tertiary,
      ),
      _InfoItem(
        label: 'Prod. hoy',
        value: prodLabel,
        valueColor: prodColor,
        icon: Icons.water_drop_outlined,
        iconBg: cs.surfaceContainerLow,
        iconColor: cs.onSurfaceVariant,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          // Row 1: Raza | Edad
          Row(
            children: [
              Expanded(child: _InfoCard(item: items[0])),
              const SizedBox(width: 8),
              Expanded(child: _InfoCard(item: items[1])),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: Peso | Sexo
          Row(
            children: [
              Expanded(child: _InfoCard(item: items[2])),
              const SizedBox(width: 8),
              Expanded(child: _InfoCard(item: items[3])),
            ],
          ),
          const SizedBox(height: 8),
          // Row 3: Prod. hoy (full width)
          _InfoCard(item: items[4]),
        ],
      ),
    );
  }

  String _capitalized(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _InfoItem {
  final String label;
  final String value;
  final Color? valueColor;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconColor;
  const _InfoItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.icon,
    this.iconBg,
    this.iconColor,
  });
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;
  const _InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.iconBg ?? cs.surfaceContainerLow,
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.icon,
                color: item.iconColor ?? cs.onSurfaceVariant,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.label.toUpperCase(),
                  style: tt.labelSmall?.copyWith(
                    fontSize: 9.5,
                    color: cs.outline,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.value,
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: item.valueColor ?? cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab Bar personalizado ────────────────────────────────────────────────────

class DetalleTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const DetalleTabBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Predicciones',
              emoji: '📊',
              isActive: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
            _TabButton(
              label: 'Gráficas',
              emoji: '📈',
              isActive: selectedIndex == 1,
              onTap: () => onTabChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.emoji,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isActive ? cs.surfaceContainerLowest : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: tt.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? cs.onSurface : cs.outline,
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

// ─── Tab Producción ───────────────────────────────────────────────────────────

class DetalleProduccionTab extends StatelessWidget {
  final List<HistorialProductivo> historial;

  const DetalleProduccionTab({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hayAnomalia = historial.any((h) => h.anomaliaDetectada);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Producción de leche',
                        style: tt.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'Últimos 7 días · litros/día',
                        style: tt.bodySmall?.copyWith(
                          fontSize: 11,
                          color: cs.outline,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hayAnomalia)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: cs.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⚠ Anomalía detectada',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cs.error,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (historial.isNotEmpty)
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: ProductionChartPainter(
                    data: historial,
                    gridColor: cs.outlineVariant,
                    normalColor: cs.tertiary,
                    anomalyColor: cs.error,
                    labelColor: cs.outline,
                    anomalyFillColor: cs.errorContainer,
                  ),
                  child: const SizedBox.expand(),
                ),
              )
            else
              SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Sin datos de producción',
                    style: tt.bodySmall?.copyWith(
                      color: cs.outline,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                _LegendItem(color: cs.tertiary, label: 'Producción normal'),
                const SizedBox(width: 14),
                _LegendItem(color: cs.error, label: 'Caída anómala'),
                const SizedBox(width: 14),
                const _LegendItemDash(label: 'Alerta IA'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: tt.labelSmall?.copyWith(fontSize: 10, color: cs.outline),
        ),
      ],
    );
  }
}

class _LegendItemDash extends StatelessWidget {
  final String label;
  const _LegendItemDash({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 2,
          decoration: BoxDecoration(
            color: cs.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: tt.labelSmall?.copyWith(fontSize: 10, color: cs.outline),
        ),
      ],
    );
  }
}

// ─── CustomPainter: Gráfico de producción ────────────────────────────────────

class ProductionChartPainter extends CustomPainter {
  final List<HistorialProductivo> data;
  final Color gridColor;
  final Color normalColor;
  final Color anomalyColor;
  final Color labelColor;
  final Color anomalyFillColor;

  const ProductionChartPainter({
    required this.data,
    required this.gridColor,
    required this.normalColor,
    required this.anomalyColor,
    required this.labelColor,
    required this.anomalyFillColor,
  });

  static const _chartLeft = 28.0;
  static const _chartTopPad = 12.0;
  static const _chartBottomPad = 20.0;
  static const _yMin = 0.0;
  static const _yMax = 22.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final chartBottom = size.height - _chartBottomPad;
    final chartHeight = chartBottom - _chartTopPad;
    final chartWidth = size.width - _chartLeft;
    final n = data.length;
    final dx = chartWidth / math.max(n - 1, 1);

    double xOf(int i) => _chartLeft + i * dx;
    double yOf(double liters) =>
        chartBottom -
        ((liters - _yMin) / (_yMax - _yMin)) * chartHeight;

    // ── Grid lines ──
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 0.5;

    for (final v in [5.0, 10.0, 15.0, 20.0]) {
      final y = yOf(v);
      canvas.drawLine(
          Offset(_chartLeft, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, '${v.toInt()}L',
          Offset(0, y - 5), labelColor, 8);
    }

    // ── Puntos ──
    final points = List.generate(
        n, (i) => Offset(xOf(i), yOf(data[i].litrosLeche)));

    int? firstAnomalyIdx;
    for (int i = 0; i < n; i++) {
      if (data[i].anomaliaDetectada) {
        firstAnomalyIdx = i;
        break;
      }
    }

    final chartRect = Rect.fromLTRB(
        _chartLeft, _chartTopPad, size.width, chartBottom);

    // ── Área normal ──
    if (firstAnomalyIdx == null || firstAnomalyIdx > 0) {
      final endIdx = firstAnomalyIdx ?? n - 1;
      final normalPath = Path()
        ..moveTo(points[0].dx, chartBottom)
        ..lineTo(points[0].dx, points[0].dy);
      for (int i = 1; i <= endIdx; i++) {
        normalPath.lineTo(points[i].dx, points[i].dy);
      }
      normalPath
        ..lineTo(points[endIdx].dx, chartBottom)
        ..close();

      canvas.save();
      canvas.clipRect(chartRect);
      canvas.drawPath(
        normalPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              normalColor.withOpacity(0.18),
              normalColor.withOpacity(0.0),
            ],
          ).createShader(chartRect),
      );
      canvas.restore();
    }

    // ── Área anomalía ──
    if (firstAnomalyIdx != null) {
      final startIdx = firstAnomalyIdx == 0 ? 0 : firstAnomalyIdx - 1;
      final anomalyPath = Path()
        ..moveTo(points[startIdx].dx, chartBottom)
        ..lineTo(points[startIdx].dx, points[startIdx].dy);
      for (int i = startIdx + 1; i < n; i++) {
        anomalyPath.lineTo(points[i].dx, points[i].dy);
      }
      anomalyPath
        ..lineTo(points[n - 1].dx, chartBottom)
        ..close();

      canvas.save();
      canvas.clipRect(chartRect);
      canvas.drawPath(
        anomalyPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              anomalyColor.withOpacity(0.15),
              anomalyColor.withOpacity(0.0),
            ],
          ).createShader(chartRect),
      );
      canvas.restore();
    }

    // ── Segmentos de línea ──
    final greenLine = Paint()
      ..color = normalColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final redLine = Paint()
      ..color = anomalyColor
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (firstAnomalyIdx == null) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < n; i++) path.lineTo(points[i].dx, points[i].dy);
      canvas.drawPath(path, greenLine);
    } else {
      if (firstAnomalyIdx > 0) {
        final gPath = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i <= firstAnomalyIdx; i++) {
          gPath.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(gPath, greenLine);
      }
      final rStart = firstAnomalyIdx == 0 ? 0 : firstAnomalyIdx - 1;
      final rPath = Path()..moveTo(points[rStart].dx, points[rStart].dy);
      for (int i = rStart + 1; i < n; i++) {
        rPath.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(rPath, redLine);
    }

    // ── Puntos/círculos ──
    for (int i = 0; i < n; i++) {
      final isAnomaly = data[i].anomaliaDetectada;
      if (isAnomaly) {
        canvas.drawCircle(
            points[i], 4.5, Paint()..color = anomalyFillColor);
        canvas.drawCircle(
            points[i],
            4.5,
            Paint()
              ..color = anomalyColor
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke);
      } else {
        canvas.drawCircle(points[i], 3.0, Paint()..color = normalColor);
      }
    }

    // ── Línea vertical punteada de anomalía ──
    if (firstAnomalyIdx != null && firstAnomalyIdx > 0) {
      final vx = xOf(firstAnomalyIdx - 1) + dx * 0.4;
      _drawDashedLine(
        canvas,
        Offset(vx, _chartTopPad),
        Offset(vx, chartBottom),
        Paint()
          ..color = anomalyColor.withOpacity(0.5)
          ..strokeWidth = 0.8,
      );
      _drawText(canvas, 'Isolation Forest',
          Offset(vx + 3, _chartTopPad + 2), anomalyColor, 7.5, bold: true);
    }

    // ── Etiquetas eje X ──
    const days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    for (int i = 0; i < n; i++) {
      final dayIdx = (data[i].fecha.weekday - 1) % 7;
      final isAnomaly = data[i].anomaliaDetectada;
      _drawText(
        canvas,
        days[dayIdx],
        Offset(xOf(i) - 4, size.height - 13),
        isAnomaly ? anomalyColor : labelColor,
        8,
        bold: isAnomaly,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color,
    double fontSize, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawDashedLine(
      Canvas canvas, Offset start, Offset end, Paint paint) {
    const dash = 3.0;
    const gap = 3.0;
    final total = (end - start).distance;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    int count = (total / (dash + gap)).floor();
    for (int i = 0; i < count; i++) {
      final t1 = i * (dash + gap) / total;
      final t2 = (i * (dash + gap) + dash) / total;
      canvas.drawLine(
        Offset(start.dx + dx * t1, start.dy + dy * t1),
        Offset(start.dx + dx * t2, start.dy + dy * t2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ProductionChartPainter old) =>
      old.data != data;
}

// ─── Tab Predicciones ─────────────────────────────────────────────────────────

class DetallePrediccionesTab extends StatelessWidget {
  final List<Prediccion> predicciones;

  const DetallePrediccionesTab({super.key, required this.predicciones});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (predicciones.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Text(
            'Sin predicciones registradas',
            style: tt.bodySmall?.copyWith(color: cs.outline, fontSize: 13),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historial de predicciones',
                style: tt.bodyMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver todo',
                      style: tt.labelMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.primary,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: cs.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...predicciones.map((p) => _PrediccionCard(prediccion: p)),
        ],
      ),
    );
  }
}

class _PrediccionCard extends StatelessWidget {
  final Prediccion prediccion;

  const _PrediccionCard({required this.prediccion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final sev = _severidadPrediccion(prediccion);
    final isAlta = sev == 'Alta';
    final isMedia = sev == 'Media';
    final accentColor = isAlta
        ? cs.error
        : isMedia
            ? cs.secondary
            : cs.tertiary;
    final cardColor = isAlta
        ? cs.errorContainer
        : isMedia
            ? cs.secondaryContainer
            : cs.tertiaryContainer;
    final textColor = isAlta
        ? cs.onErrorContainer
        : isMedia
            ? cs.onSecondaryContainer
            : cs.onTertiaryContainer;
    final riesgoLabel = isAlta
        ? 'Alto riesgo'
        : isMedia
            ? 'Riesgo moderado'
            : 'Bajo riesgo';
    final emoji = isAlta ? '🦠' : '✅';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left accent bar
            Container(width: 4, color: accentColor),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Disease icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cardColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(emoji, style: const TextStyle(fontSize: 17)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Disease info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            prediccion.enfermedad,
                            style: tt.bodySmall?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Text('🕐',
                                  style: TextStyle(fontSize: 11)),
                              const SizedBox(width: 4),
                              Text(
                                _fechaRelativa(prediccion.fecha),
                                style: tt.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: cs.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Confidence + riesgo chip
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(prediccion.confianza * 100).round()}%',
                          style: tt.bodyMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: accentColor,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            riesgoLabel,
                            style: tt.labelSmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: textColor,
                            ),
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
    );
  }
}

// ─── Tab Gráficas ─────────────────────────────────────────────────────────────

class DetalleGraficasTab extends StatelessWidget {
  final Map<String, List<GraficaPunto>> graficas;

  const DetalleGraficasTab({super.key, required this.graficas});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (graficas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('📊', style: TextStyle(fontSize: 36)),
              const SizedBox(height: 12),
              Text(
                'Aún no hay gráficas disponibles',
                style: tt.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Registra más síntomas para ver la evolución.',
                textAlign: TextAlign.center,
                style: tt.bodySmall?.copyWith(
                  color: cs.outline,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    const orden = [
      'temperatura_corporal',
      'produccion_leche_litros',
      'consumo_alimento_kg',
      'consumo_agua_litros',
      'frecuencia_cardiaca',
      'frecuencia_respiratoria',
      'condicion_corporal',
    ];

    final keys = [
      ...orden.where(graficas.containsKey),
      ...graficas.keys.where((k) => !orden.contains(k)),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: keys
            .map((key) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _GraficaCard(
                    metricaKey: key,
                    puntos: graficas[key]!,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _GraficaCard extends StatelessWidget {
  final String metricaKey;
  final List<GraficaPunto> puntos;

  const _GraficaCard({required this.metricaKey, required this.puntos});

  String _formatFecha(DateTime d) => '${d.day}/${d.month}';

  String _formatValor(double v, String unidad) =>
      unidad.isEmpty ? v.toStringAsFixed(1) : '${v.toStringAsFixed(1)} $unidad';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final meta = _metricasMeta[metricaKey] ??
        _MetricaMeta(metricaKey, '');
    final color = _metricaColor(metricaKey, cs);
    final ultimo = puntos.last;
    final anterior = puntos.length > 1 ? puntos[puntos.length - 2] : null;
    final tendencia = anterior == null
        ? 0
        : ultimo.valor.compareTo(anterior.valor);

    final minVal = puntos.map((p) => p.valor).reduce(math.min);
    final maxVal = puntos.map((p) => p.valor).reduce(math.max);
    final rango = (maxVal - minVal).abs();
    final margen = rango < 1 ? 1.0 : rango * 0.2;
    final yMin = (minVal - margen);
    final yMax = (maxVal + margen);

    final spots = puntos
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (meta.unidad.isNotEmpty)
                      Text(
                        meta.unidad,
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          color: cs.outline,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatValor(ultimo.valor, meta.unidad),
                    style: tt.bodyMedium?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (tendencia != 0)
                    Icon(
                      tendencia > 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: tendencia > 0 ? cs.error : cs.tertiary,
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: puntos.length == 1
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: color, size: 10),
                        const SizedBox(height: 4),
                        Text(
                          _formatFecha(ultimo.fecha),
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            color: cs.outline,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Solo un registro',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 11,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : LineChart(
                    LineChartData(
                      minY: yMin,
                      maxY: yMax,
                      clipData: const FlClipData.all(),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: rango < 1 ? 0.5 : rango / 3,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: cs.outlineVariant,
                          strokeWidth: 1,
                          dashArray: [4, 4],
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= puntos.length) {
                                return const SizedBox.shrink();
                              }
                              if (idx != 0 && idx != puntos.length - 1) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatFecha(puntos[idx].fecha),
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: cs.outline,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: color,
                          barWidth: 2,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, pct, bar, idx) =>
                                FlDotCirclePainter(
                              radius: idx == spots.length - 1 ? 4 : 2.5,
                              color: color,
                              strokeWidth: 1.5,
                              strokeColor: cs.surfaceContainerLowest,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.18),
                                color.withOpacity(0.02),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          if (puntos.length > 2) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatFecha(puntos.first.fecha),
                  style: tt.labelSmall?.copyWith(fontSize: 9, color: cs.outline),
                ),
                Text(
                  '${puntos.length} registros',
                  style: tt.labelSmall?.copyWith(fontSize: 9, color: cs.outline),
                ),
                Text(
                  _formatFecha(puntos.last.fecha),
                  style: tt.labelSmall?.copyWith(fontSize: 9, color: cs.outline),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Botón CTA inferior ───────────────────────────────────────────────────────

class DetalleBottomCta extends StatelessWidget {
  final Animal animal;
  final VoidCallback? onRegistrarSintomas;

  const DetalleBottomCta({
    super.key,
    required this.animal,
    this.onRegistrarSintomas,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.97),
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.onSurface,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.18),
          ),
          icon: const Icon(Icons.medical_services_outlined, size: 16),
          label: Text(
            'Registrar síntomas',
            style: tt.labelLarge?.copyWith(
              color: Colors.white,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: onRegistrarSintomas,
        ),
      ),
    );
  }
}
