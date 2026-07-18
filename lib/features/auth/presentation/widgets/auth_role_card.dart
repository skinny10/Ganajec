import 'package:flutter/material.dart';

class AuthRoleCard extends StatelessWidget {
  final String role;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const AuthRoleCard({
    super.key,
    required this.role,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
            width: selected ? 1.0 : 0.5,
          ),
          boxShadow: selected
              ? [BoxShadow(color: cs.primary.withOpacity(0.08), blurRadius: 0, spreadRadius: 3)]
              : [BoxShadow(color: cs.shadow.withOpacity(0.03), blurRadius: 4, offset: const Offset(0, 1))],
        ),
        child: Row(
          children: [
            // Ícono
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 38, height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary.withOpacity(0.18)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: selected ? cs.primary : cs.onSurfaceVariant,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: tt.labelMedium?.copyWith(
                      fontSize: 13,
                      color:    cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: tt.bodySmall?.copyWith(
                      color:      cs.onSurfaceVariant,
                      fontWeight: FontWeight.w300,
                      height:     1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Checkmark
            AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: selected ? 1.0 : 0.0,
              child: Icon(Icons.check_rounded, color: cs.primary, size: 17),
            ),
          ],
        ),
      ),
    );
  }
}
