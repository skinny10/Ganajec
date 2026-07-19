import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

class MiPlanHeroCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanHeroCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final p = suscripcion.planActual;
    final diasTexto = p.esGratuito ? '∞' : '${p.historialDias}';

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: cs.onSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 30,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PLAN ACTIVO',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.surface.withValues(alpha: 0.54),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                p.nombre,
                style: tt.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: cs.surface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.precioTexto,
                style: tt.bodySmall?.copyWith(
                  fontSize: 13,
                  color: cs.surface.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 18),
              IntrinsicHeight(
                child: Row(
                  children: [
                    _Stat(value: suscripcion.bovinosTexto, label: 'Bovinos'),
                    _StatDivider(color: cs.surface.withValues(alpha: 0.12)),
                    _Stat(value: suscripcion.analisisTexto, label: 'Análisis este mes'),
                    _StatDivider(color: cs.surface.withValues(alpha: 0.12)),
                    _Stat(value: diasTexto, label: 'Días restantes'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: tt.titleMedium?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.surface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: tt.labelSmall?.copyWith(
              fontSize: 9.5,
              color: cs.surface.withValues(alpha: 0.54),
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  final Color color;
  const _StatDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: color,
      margin: const EdgeInsets.symmetric(vertical: 4),
    );
  }
}
