import 'package:flutter/material.dart';
import 'package:ganajec/core/domain/entities/prediccion.dart';

class PrediccionTile extends StatelessWidget {
  final Prediccion prediccion;

  const PrediccionTile({super.key, required this.prediccion});

  Color _confianzaColor(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (prediccion.enfermedad == 'Sin enfermedad') return colors.tertiary;
    if (prediccion.confianza >= 0.8) return colors.error;
    return colors.secondary;
  }

  IconData _enfermedadIcon(String enfermedad) {
    switch (enfermedad.toLowerCase()) {
      case 'mastitis':
        return Icons.coronavirus_outlined;
      case 'sin enfermedad':
        return Icons.check_circle_outline;
      default:
        return Icons.medical_services_outlined;
    }
  }

  String _formatHora(DateTime fecha) {
    final hora = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$hora:$min am';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = _confianzaColor(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _enfermedadIcon(prediccion.enfermedad),
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediccion.enfermedad,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${prediccion.animalNombre} · ${prediccion.animalId}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(prediccion.confianza * 100).toStringAsFixed(0)}% conf.',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                _formatHora(prediccion.fecha),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}