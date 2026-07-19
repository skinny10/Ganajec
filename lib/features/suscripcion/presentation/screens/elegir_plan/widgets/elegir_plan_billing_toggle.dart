import 'package:flutter/material.dart';

class ElegirPlanBillingToggle extends StatelessWidget {
  final bool isAnual;
  final VoidCallback onToggle;

  const ElegirPlanBillingToggle({
    super.key,
    required this.isAnual,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (tt.bodyMedium ?? const TextStyle()).copyWith(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w400 : FontWeight.w500,
              color: isAnual ? cs.onSurfaceVariant : cs.onSurface,
            ),
            child: const Text('Mensual'),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 26,
              decoration: BoxDecoration(
                color: cs.onSurface,
                borderRadius: BorderRadius.circular(13),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment:
                    isAnual ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: cs.shadow.withValues(alpha: 0.26),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: (tt.bodyMedium ?? const TextStyle()).copyWith(
              fontSize: 13,
              fontWeight: isAnual ? FontWeight.w500 : FontWeight.w400,
              color: isAnual ? cs.onSurface : cs.onSurfaceVariant,
            ),
            child: const Text('Anual'),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isAnual ? 1.0 : 0.4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: cs.tertiary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Ahorra 17%',
                style: tt.labelSmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: cs.onTertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
