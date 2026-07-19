import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

class MiPlanTipCard extends StatelessWidget {
  final SuscripcionInfo suscripcion;

  const MiPlanTipCard({super.key, required this.suscripcion});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final disponibles = suscripcion.bovinosDisponibles;
    if (suscripcion.planActual.bovinosMax == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.secondary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Text('💡', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tienes $disponibles ${disponibles == 1 ? 'bovino disponible' : 'bovinos disponibles'}',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Con el Plan Pro puedes registrar tu hato completo y desbloquear todas las funciones.',
                  style: tt.labelSmall?.copyWith(
                    fontSize: 11,
                    color: cs.onSecondaryContainer.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w300,
                    height: 1.5,
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
