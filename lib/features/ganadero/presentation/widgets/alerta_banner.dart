import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';

class AlertaBanner extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback? onTap;

  const AlertaBanner({
    super.key,
    required this.alerta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: colors.onErrorContainer, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alerta.tipo == 'productiva'
                        ? 'Caída productiva detectada'
                        : alerta.tipo,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colors.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Text(
                    alerta.mensaje,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colors.onErrorContainer,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: colors.onErrorContainer, size: 14),
          ],
        ),
      ),
    );
  }
}
