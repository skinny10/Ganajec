import 'package:flutter/material.dart';

class ElegirPlanPromoHeader extends StatelessWidget {
  final String planActualNombre;

  const ElegirPlanPromoHeader({super.key, required this.planActualNombre});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: cs.onSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.surface.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MEJORA TU EXPERIENCIA',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: cs.surface.withValues(alpha: 0.6),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Desbloquea todo\nGANAJEC',
                style: tt.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: cs.surface,
                  letterSpacing: -0.6,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Alertas automáticas, historial extendido y reportes para tu hato.',
                style: tt.bodySmall?.copyWith(
                  fontSize: 12.5,
                  color: cs.surface.withValues(alpha: 0.65),
                  fontWeight: FontWeight.w300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: cs.surface.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '🐄 Actualmente en Plan $planActualNombre',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: cs.surface.withValues(alpha: 0.8),
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
