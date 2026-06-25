import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_productivo.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/detalle_bovino_viewmodel.dart';

// ─── Paleta fija (del diseño HTML) ───────────────────────────────────────────
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kGreen = Color(0xFF1D7A55);
const _kGreenLight = Color(0xFFE8F5EF);
const _kRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFFDEDEC);
const _kCream = Color(0xFFF5F3EE);

// ─── Helpers ─────────────────────────────────────────────────────────────────

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
    final edad = _calcularEdad(animal.fechaNacimiento);
    final esAlerta = vm.tieneAnomaliaActiva;
    final accentColor = esAlerta ? _kRed : _kGreen;
    final badgeBg = esAlerta ? _kRedLight : _kGreenLight;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Franja de color izquierda
            Container(width: 5, color: accentColor),
            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 20, 18, 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _kRedLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text('🐄', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Datos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            animal.nombre,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: _kTextPrimary,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${animal.raza} · $edad años · ${animal.idExterno}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _kTextSecondary,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Badge de severidad
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
                                _PulsingDot(color: accentColor),
                                const SizedBox(width: 5),
                                Text(
                                  vm.severidadLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: accentColor,
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
    final edad = _calcularEdad(animal.fechaNacimiento);
    final prodHoy = vm.produccionHoy;
    final prodColor =
        vm.tieneAnomaliaActiva ? _kRed : _kGreen;
    final prodLabel = vm.tieneAnomaliaActiva
        ? '${prodHoy.toStringAsFixed(0)} L ↓'
        : '${prodHoy.toStringAsFixed(0)} L';

    final items = [
      _InfoItem(label: 'Raza', value: animal.raza),
      _InfoItem(label: 'Edad', value: '$edad años'),
      _InfoItem(label: 'Peso', value: '${animal.pesoKg.toStringAsFixed(1)} kg'),
      _InfoItem(label: 'Sexo', value: _capitalized(animal.sexo)),
      _InfoItem(label: 'Prod. hoy', value: prodLabel, valueColor: prodColor),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.4,
        children: items
            .map((item) => _InfoCard(item: item))
            .toList(),
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
  const _InfoItem({required this.label, required this.value, this.valueColor});
}

class _InfoCard extends StatelessWidget {
  final _InfoItem item;
  const _InfoCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              color: _kTextMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            item.value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: item.valueColor ?? _kTextPrimary,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: _kCream,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _TabButton(
              label: 'Predicciones',
              isActive: selectedIndex == 0,
              onTap: () => onTabChanged(0),
            ),
            _TabButton(
              label: 'Gráficas',
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
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? _kSurface : Colors.transparent,
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
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w500 : FontWeight.w400,
                color: isActive ? _kTextPrimary : _kTextMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tab Producción ──────────────────────────────────────────────────────────

class DetalleProduccionTab extends StatelessWidget {
  final List<HistorialProductivo> historial;

  const DetalleProduccionTab({super.key, required this.historial});

  @override
  Widget build(BuildContext context) {
    final hayAnomalia = historial.any((h) => h.anomaliaDetectada);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Producción de leche',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _kTextPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 1),
                      Text(
                        'Últimos 7 días · litros/día',
                        style: TextStyle(
                          fontSize: 11,
                          color: _kTextMuted,
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
                      color: _kRedLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⚠ Anomalía detectada',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: _kRed,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            // Chart
            if (historial.isNotEmpty)
              SizedBox(
                height: 140,
                child: CustomPaint(
                  painter: ProductionChartPainter(data: historial),
                  child: const SizedBox.expand(),
                ),
              )
            else
              const SizedBox(
                height: 100,
                child: Center(
                  child: Text(
                    'Sin datos de producción',
                    style: TextStyle(color: _kTextMuted, fontSize: 12),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Leyenda
            Row(
              children: [
                _LegendItem(color: _kGreen, label: 'Producción normal'),
                const SizedBox(width: 14),
                _LegendItem(color: _kRed, label: 'Caída anómala'),
                const SizedBox(width: 14),
                _LegendItemDash(label: 'Alerta IA'),
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 10, color: _kTextMuted)),
      ],
    );
  }
}

class _LegendItemDash extends StatelessWidget {
  final String label;
  const _LegendItemDash({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12, height: 2,
          decoration: BoxDecoration(
            color: _kTextMuted,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label,
            style: const TextStyle(fontSize: 10, color: _kTextMuted)),
      ],
    );
  }
}

// ─── CustomPainter: Gráfico de producción ────────────────────────────────────

class ProductionChartPainter extends CustomPainter {
  final List<HistorialProductivo> data;

  const ProductionChartPainter({required this.data});

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
      ..color = _kBorder
      ..strokeWidth = 0.5;

    for (final v in [5.0, 10.0, 15.0, 20.0]) {
      final y = yOf(v);
      canvas.drawLine(
          Offset(_chartLeft, y), Offset(size.width, y), gridPaint);
      _drawText(canvas, '${v.toInt()}L',
          Offset(0, y - 5), _kTextMuted, 8);
    }

    // ── Puntos ──
    final points = List.generate(
        n, (i) => Offset(xOf(i), yOf(data[i].litrosLeche)));

    // Índice del primer dato anómalo
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
              _kGreen.withOpacity(0.18),
              _kGreen.withOpacity(0.0),
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
              _kRed.withOpacity(0.15),
              _kRed.withOpacity(0.0),
            ],
          ).createShader(chartRect),
      );
      canvas.restore();
    }

    // ── Segmentos de línea ──
    final greenLine = Paint()
      ..color = _kGreen
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final redLine = Paint()
      ..color = _kRed
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (firstAnomalyIdx == null) {
      final path = Path()..moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < n; i++) path.lineTo(points[i].dx, points[i].dy);
      canvas.drawPath(path, greenLine);
    } else {
      // Verde: 0 → firstAnomalyIdx
      if (firstAnomalyIdx > 0) {
        final gPath = Path()..moveTo(points[0].dx, points[0].dy);
        for (int i = 1; i <= firstAnomalyIdx; i++) {
          gPath.lineTo(points[i].dx, points[i].dy);
        }
        canvas.drawPath(gPath, greenLine);
      }
      // Rojo: desde punto anterior a anomalía → fin
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
            points[i], 4.5, Paint()..color = const Color(0xFFFEF2F2));
        canvas.drawCircle(
            points[i],
            4.5,
            Paint()
              ..color = _kRed
              ..strokeWidth = 1.5
              ..style = PaintingStyle.stroke);
      } else {
        canvas.drawCircle(points[i], 3.0, Paint()..color = _kGreen);
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
          ..color = _kRed.withOpacity(0.5)
          ..strokeWidth = 0.8,
      );
      _drawText(canvas, 'Isolation Forest',
          Offset(vx + 3, _chartTopPad + 2), _kRed, 7.5, bold: true);
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
        isAnomaly ? _kRed : _kTextMuted,
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
    if (predicciones.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Center(
          child: Text(
            'Sin predicciones registradas',
            style: TextStyle(color: _kTextMuted, fontSize: 13),
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
              const Text(
                'Historial de predicciones',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _kTextPrimary,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _kTextSecondary,
                    decoration: TextDecoration.underline,
                  ),
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
    final sev = _severidadPrediccion(prediccion);
    final isAlta = sev == 'Alta';
    final cardColor = isAlta ? _kRedLight : _kGreenLight;
    final textColor = isAlta ? _kRed : _kGreen;
    final emoji = isAlta ? '🦠' : '✅';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediccion.enfermedad,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fechaRelativa(prediccion.fecha),
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          // Confianza + severidad
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(prediccion.confianza * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _kTextPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sev,
                  style: TextStyle(
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
    );
  }
}

// ─── Tab Gráficas ─────────────────────────────────────────────────────────────

/// Metadatos por clave de métrica
class _MetricaMeta {
  final String label;
  final String unidad;
  final Color color;
  const _MetricaMeta(this.label, this.unidad, this.color);
}

const _metricasMeta = <String, _MetricaMeta>{
  'temperatura_corporal':    _MetricaMeta('Temperatura corporal',   '°C',  Color(0xFFE74C3C)),
  'produccion_leche_litros': _MetricaMeta('Producción de leche',    'L',   Color(0xFF2980B9)),
  'consumo_alimento_kg':     _MetricaMeta('Consumo de alimento',    'kg',  Color(0xFF27AE60)),
  'consumo_agua_litros':     _MetricaMeta('Consumo de agua',        'L',   Color(0xFF1ABC9C)),
  'frecuencia_cardiaca':     _MetricaMeta('Frecuencia cardíaca',    'bpm', Color(0xFFE67E22)),
  'frecuencia_respiratoria': _MetricaMeta('Frec. respiratoria',     'rpm', Color(0xFF9B59B6)),
  'condicion_corporal':      _MetricaMeta('Condición corporal',     '',    Color(0xFF8B4A2B)),
};

class DetalleGraficasTab extends StatelessWidget {
  final Map<String, List<GraficaPunto>> graficas;

  const DetalleGraficasTab({super.key, required this.graficas});

  @override
  Widget build(BuildContext context) {
    if (graficas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📊', style: TextStyle(fontSize: 36)),
              SizedBox(height: 12),
              Text(
                'Aún no hay gráficas disponibles',
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Registra más síntomas para ver la evolución.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _kTextMuted, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // Orden preferido de métricas
    final orden = [
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

  String _formatFecha(DateTime d) =>
      '${d.day}/${d.month}';

  String _formatValor(double v, String unidad) =>
      unidad.isEmpty ? v.toStringAsFixed(1) : '${v.toStringAsFixed(1)} $unidad';

  @override
  Widget build(BuildContext context) {
    final meta = _metricasMeta[metricaKey] ??
        _MetricaMeta(metricaKey, '', const Color(0xFF2E7D32));
    final color = meta.color;
    final ultimo = puntos.last;
    final anterior = puntos.length > 1 ? puntos[puntos.length - 2] : null;
    final tendencia = anterior == null
        ? 0
        : ultimo.valor.compareTo(anterior.valor);

    // Rango Y con margen
    final minVal = puntos.map((p) => p.valor).reduce(math.min);
    final maxVal = puntos.map((p) => p.valor).reduce(math.max);
    final rango = (maxVal - minVal).abs();
    final margen = rango < 1 ? 1.0 : rango * 0.2;
    final yMin = (minVal - margen);
    final yMax = (maxVal + margen);

    // Spots de fl_chart
    final spots = puntos
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _kTextPrimary,
                      ),
                    ),
                    if (meta.unidad.isNotEmpty)
                      Text(
                        meta.unidad,
                        style: const TextStyle(
                            fontSize: 11, color: _kTextMuted),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    _formatValor(ultimo.valor, meta.unidad),
                    style: TextStyle(
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
                      color: tendencia > 0
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFF27AE60),
                      size: 16,
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Gráfica
          SizedBox(
            height: 120,
            child: puntos.length == 1
                // Un solo punto: solo mostramos el valor centrado
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: color, size: 10),
                        const SizedBox(height: 4),
                        Text(
                          _formatFecha(ultimo.fecha),
                          style: const TextStyle(
                              fontSize: 10, color: _kTextMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Solo un registro',
                          style: const TextStyle(
                              fontSize: 11, color: _kTextSecondary),
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
                          color: _kBorder,
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
                              // Solo primero y último (para no saturar)
                              if (idx != 0 && idx != puntos.length - 1) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatFecha(puntos[idx].fecha),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: _kTextMuted,
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
                              strokeColor: Colors.white,
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
          // Fechas mínima y máxima bajo el chart si hay más de 2 puntos
          if (puntos.length > 2) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatFecha(puntos.first.fecha),
                  style:
                      const TextStyle(fontSize: 9, color: _kTextMuted),
                ),
                Text(
                  '${puntos.length} registros',
                  style:
                      const TextStyle(fontSize: 9, color: _kTextMuted),
                ),
                Text(
                  _formatFecha(puntos.last.fecha),
                  style:
                      const TextStyle(fontSize: 9, color: _kTextMuted),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7).withOpacity(0.97),
        border: const Border(top: BorderSide(color: _kBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kTextPrimary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(13),
            ),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.18),
          ),
          icon: const Icon(Icons.medical_services_outlined, size: 16),
          label: const Text(
            'Registrar síntomas',
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
          onPressed: onRegistrarSintomas,
        ),
      ),
    );
  }
}
