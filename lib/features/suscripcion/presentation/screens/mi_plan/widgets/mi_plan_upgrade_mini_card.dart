import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/features/suscripcion/presentation/shared/utils/format_utils.dart';

class MiPlanUpgradeMiniCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback onTap;

  const MiPlanUpgradeMiniCard({
    super.key,
    required this.plan,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isFeatured = plan.popular;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isFeatured ? cs.surface : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isFeatured ? cs.onSurface : cs.outlineVariant,
            width: isFeatured ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      plan.nombre,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: cs.onSurface,
                      ),
                    ),
                    if (plan.popular) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Más popular',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: cs.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${formatNum(plan.precioMensual)}',
                      style: tt.titleSmall?.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'MXN / mes',
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
            const SizedBox(height: 8),
            ...plan.features
                .where((f) => f.incluida)
                .map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text('✓',
                            style: TextStyle(
                                color: cs.tertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Text(
                          f.label,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 11.5,
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w300,
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
