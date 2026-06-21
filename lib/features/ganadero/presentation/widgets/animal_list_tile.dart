import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';

class AnimalListTile extends StatelessWidget {
  final Animal animal;
  final String estado;
  final VoidCallback? onTap;

  const AnimalListTile({
    super.key,
    required this.animal,
    required this.estado,
    this.onTap,
  });

  Color _estadoColor(BuildContext context, String estado) {
    final colors = Theme.of(context).colorScheme;
    switch (estado.toLowerCase()) {
      case 'severidad alta':
        return colors.error;
      case 'observar':
        return colors.secondary;
      default:
        return colors.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = _estadoColor(context, estado);
    final tieneContexto = animal.ganaderoNombre.isNotEmpty;
    final edad = DateTime.now().year - animal.fechaNacimiento.year;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.pets,
                color: colors.onSurfaceVariant,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.nombre,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (tieneContexto) ...[
                    Text(
                      '${animal.ganaderoNombre} · ${animal.raza}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ] else ...[
                    Text(
                      '${animal.raza} · $edad año${edad == 1 ? '' : 's'} · ${animal.idExterno}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                estado,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
