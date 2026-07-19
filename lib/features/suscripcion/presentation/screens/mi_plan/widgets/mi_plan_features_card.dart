import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';

class MiPlanFeaturesCard extends StatelessWidget {
  final Plan plan;

  const MiPlanFeaturesCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              'Funcionalidades actuales',
              style: tt.bodyMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ...List.generate(plan.features.length, (i) {
            final f = plan.features[i];
            final isLast = i == plan.features.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: f.incluida
                              ? cs.tertiaryContainer
                              : cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(f.emoji,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          f.label,
                          style: tt.bodySmall?.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: f.incluida ? cs.onSurface : cs.outline,
                          ),
                        ),
                      ),
                      Text(
                        f.incluida ? '✅' : '🔒',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 0,
                      thickness: 0.5,
                      indent: 16,
                      endIndent: 16,
                      color: cs.outlineVariant),
              ],
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
