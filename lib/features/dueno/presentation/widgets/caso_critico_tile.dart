import 'package:flutter/material.dart';
import '../../domain/entities/dueno_dashboard.dart';

class CasoCriticoTile extends StatelessWidget {
  final CasoCritico caso;

  const CasoCriticoTile({super.key, required this.caso});

  Color _colorSeveridad(BuildContext context) {
    switch (caso.severidad.toLowerCase()) {
      case 'alta':
        return Theme.of(context).colorScheme.error;
      case 'moderada':
        return const Color(0xFFE65100);
      default:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final colorSev = _colorSeveridad(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: colorSev, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, size: 36, color: Color(0xFF805611)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caso.nombreAnimal,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${caso.raza} · ${caso.animalId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 12, color: colors.primary),
                    const SizedBox(width: 4),
                    Text(
                      caso.ganaderoNombre,
                      style: TextStyle(fontSize: 11, color: colors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${caso.porcentajeRiesgo.toInt()}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorSev,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorSev.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  caso.severidad,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorSev,
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
