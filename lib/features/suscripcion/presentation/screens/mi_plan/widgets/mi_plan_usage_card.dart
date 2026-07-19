import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

class MiPlanUsageCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanUsageCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Uso actual del plan',
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 14),
          _UsageRow(
            label: 'Bovinos registrados',
            value: suscripcion.bovinosTexto,
            pct: suscripcion.bovinosPct,
          ),
          const SizedBox(height: 12),
          _UsageRow(
            label: 'Análisis este mes',
            value: suscripcion.analisisTexto,
            pct: suscripcion.analisisPct,
          ),
          const SizedBox(height: 12),
          _UsageRow(
            label: 'Historial guardado',
            value: suscripcion.historialTexto,
            pct: 1.0,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final String label;
  final String value;
  final double pct;

  const _UsageRow({required this.label, required this.value, required this.pct});

  Color _barColor(ColorScheme cs) {
    if (pct >= 0.9) return cs.error;
    if (pct >= 0.7) return cs.secondary;
    return cs.tertiary;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w400)),
            Text(value,
                style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Container(
            height: 6,
            color: cs.outlineVariant,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: pct),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOut,
              builder: (_, value, __) => FractionallySizedBox(
                widthFactor: value,
                alignment: Alignment.centerLeft,
                child: Container(color: _barColor(cs)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
