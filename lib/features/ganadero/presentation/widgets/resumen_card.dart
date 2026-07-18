import 'package:flutter/material.dart';

class ResumenCard extends StatelessWidget {
  final String valor;
  final String etiqueta;
  final IconData icono;
  final Color color;

  const ResumenCard({
    super.key,
    required this.valor,
    required this.etiqueta,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Watermark icon
            Positioned(
              bottom: -6,
              right: -6,
              child: Icon(icono, size: 58, color: color.withOpacity(0.07)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icono, color: color, size: 21),
                ),
                const SizedBox(height: 10),
                Text(
                  valor,
                  style: tt.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  etiqueta,
                  style: tt.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 10.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.chevron_right, size: 15, color: color),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
