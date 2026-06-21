import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/dueno/data/models/estadisticas_model.dart';
import 'package:ganajec/features/dueno/presentation/viewmodels/dashboard_viewmodel.dart';

class DuenoDashboardScreen extends StatefulWidget {
  const DuenoDashboardScreen({super.key});

  @override
  State<DuenoDashboardScreen> createState() => _DuenoDashboardScreenState();
}

class _DuenoDashboardScreenState extends State<DuenoDashboardScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);

  static const _kNovillo = Color(0xFF1D7A55);
  static const _kVaca = Color(0xFF4A90D9);
  static const _kToro = Color(0xFFD4893B);

  static const _kAlta = Color(0xFFE53935);
  static const _kMedia = Color(0xFFFFC107);
  static const _kBaja = Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<DashboardViewModel>().cargar(),
            icon: const Icon(Icons.refresh_outlined,
                color: _kTextSecondary, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.status == DashboardStatus.error
              ? _ErrorView(
                  message: vm.error ?? 'Error al cargar estadísticas',
                  onRetry: () =>
                      context.read<DashboardViewModel>().cargar(),
                )
              : vm.status == DashboardStatus.idle
                  ? _NoRanchoView()
                  : _buildContent(context, vm),
    );
  }

  Widget _buildContent(BuildContext context, DashboardViewModel vm) {
    final est = vm.estadisticas;
    if (est == null) return _NoRanchoView();
    return RefreshIndicator(
      onRefresh: () => context.read<DashboardViewModel>().cargar(),
      child: ListView(
        padding: const EdgeInsets.only(top: 16, bottom: 40),
        children: [
          _KpiRow(estadisticas: est),
          const SizedBox(height: 20),
          _DonutChartSection(estadisticas: est),
          const SizedBox(height: 20),
          _BarChartSection(estadisticas: est),
          const SizedBox(height: 20),
          _PrediccionesSection(estadisticas: est),
        ],
      ),
    );
  }
}

// ── KPI Row ──────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  final EstadisticasModel estadisticas;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);

  const _KpiRow({required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              icon: '🐄',
              label: 'Bovinos',
              value: '${estadisticas.totalBovinos}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KpiCard(
              icon: '🔔',
              label: 'Alertas',
              value: '${estadisticas.totalAlertas}',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _KpiCard(
              icon: '📊',
              label: 'Predicciones',
              value: '${estadisticas.prediccionesMes.length}',
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _kTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: _kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Donut chart ──────────────────────────────────────────────────────────────

class _DonutChartSection extends StatelessWidget {
  final EstadisticasModel estadisticas;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kNovillo = Color(0xFF1D7A55);
  static const _kVaca = Color(0xFF4A90D9);
  static const _kToro = Color(0xFFD4893B);

  const _DonutChartSection({required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    final data = estadisticas.bovinosPorCategoria;
    if (data.isEmpty) return const SizedBox.shrink();

    const colors = [_kNovillo, _kVaca, _kToro];
    final entries = data.entries.toList();
    final total = data.values.fold(0, (sum, v) => sum + v);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bovinos por categoría',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: const Size(140, 140),
                      painter: _DonutPainter(
                        segments: entries
                            .asMap()
                            .entries
                            .map((e) => _DonutSegment(
                                  value: e.value.value.toDouble(),
                                  color: colors[e.key % colors.length],
                                ))
                            .toList(),
                        bgColor: const Color(0xFFFAFAF7),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.asMap().entries.map((e) {
                        final entry = e.value;
                        final color = colors[e.key % colors.length];
                        final pct = total > 0
                            ? (entry.value / total * 100).toStringAsFixed(0)
                            : '0';
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${entry.key}: ${entry.value} ($pct%)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _kTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final Color bgColor;

  _DonutPainter({required this.segments, required this.bgColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final total = segments.fold<double>(0, (sum, s) => sum + s.value);

    if (total == 0) {
      final paint = Paint()
        ..color = const Color(0xFFE8E5DC)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, paint);
      canvas.drawCircle(
        center,
        radius * 0.55,
        Paint()..color = bgColor,
      );
      return;
    }

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      final sweepAngle = (segment.value / total) * 2 * math.pi;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = bgColor,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => true;
}

// ── Bar chart ────────────────────────────────────────────────────────────────

class _BarChartSection extends StatelessWidget {
  final EstadisticasModel estadisticas;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kAlta = Color(0xFFE53935);
  static const _kMedia = Color(0xFFFFC107);
  static const _kBaja = Color(0xFF4CAF50);

  const _BarChartSection({required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    final data = estadisticas.alertasPorSeveridad;
    if (data.isEmpty) return const SizedBox.shrink();

    const colors = {
      'baja': _kBaja,
      'media': _kMedia,
      'alta': _kAlta,
    };
    const labels = {
      'baja': 'Baja',
      'media': 'Media',
      'alta': 'Alta',
    };
    final maxVal = data.values.fold<int>(0, math.max);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alertas por severidad',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _kTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...['baja', 'media', 'alta'].map((key) {
              final value = data[key] ?? 0;
              final color = colors[key] ?? _kBaja;
              final label = labels[key] ?? key;
              final fraction = maxVal > 0 ? value / maxVal : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _kTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _kTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: fraction,
                        backgroundColor: const Color(0xFFF0EFEA),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 10,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Predicciones section ─────────────────────────────────────────────────────

class _PrediccionesSection extends StatelessWidget {
  final EstadisticasModel estadisticas;

  static const _kSurface = Color(0xFFFFFFFF);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kAlta = Color(0xFFE53935);
  static const _kMedia = Color(0xFFFFC107);
  static const _kBaja = Color(0xFF4CAF50);
  static const _kAltaLight = Color(0xFFFDECEA);
  static const _kMediaLight = Color(0xFFFFF8E1);
  static const _kBajaLight = Color(0xFFE8F5E9);

  const _PrediccionesSection({required this.estadisticas});

  @override
  Widget build(BuildContext context) {
    final preds = estadisticas.prediccionesMes;
    if (preds.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Predicciones del mes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                Text(
                  '${preds.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: _kTextSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...preds.map((p) => _PrediccionTile(prediccion: p)),
          ],
        ),
      ),
    );
  }
}

class _PrediccionTile extends StatelessWidget {
  final PrediccionMes prediccion;

  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kAlta = Color(0xFFE53935);
  static const _kMedia = Color(0xFFFFC107);
  static const _kBaja = Color(0xFF4CAF50);
  static const _kAltaLight = Color(0xFFFDECEA);
  static const _kMediaLight = Color(0xFFFFF8E1);
  static const _kBajaLight = Color(0xFFE8F5E9);

  const _PrediccionTile({required this.prediccion});

  Color _severityColor() {
    switch (prediccion.severidad.toLowerCase()) {
      case 'alta':
        return _kAlta;
      case 'media':
        return _kMedia;
      case 'baja':
        return _kBaja;
      default:
        return _kTextSecondary;
    }
  }

  Color _severityBg() {
    switch (prediccion.severidad.toLowerCase()) {
      case 'alta':
        return _kAltaLight;
      case 'media':
        return _kMediaLight;
      case 'baja':
        return _kBajaLight;
      default:
        return const Color(0xFFF5F3EE);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _severityBg(),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              prediccion.severidad.substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _severityColor(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediccion.enfermedad,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _kTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${prediccion.bovino} · ${prediccion.fecha}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kTextSecondary,
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

// ── Empty / Error states ─────────────────────────────────────────────────────

class _NoRanchoView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.map_outlined,
                color: Color(0xFFAEADA6), size: 48),
            SizedBox(height: 12),
            Text(
              'No hay un rancho seleccionado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Selecciona o crea un rancho para ver sus estadísticas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Color(0xFF888880)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFC0392B), size: 48),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF888880))),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}
