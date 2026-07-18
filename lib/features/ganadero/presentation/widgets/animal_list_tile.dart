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
    final cs = Theme.of(context).colorScheme;
    switch (estado.toLowerCase()) {
      case 'severidad alta':
        return cs.error;
      case 'observar':
        return cs.secondary;
      default:
        return cs.tertiary;
    }
  }

  String _estadoEmoji(String estado) {
    switch (estado.toLowerCase()) {
      case 'severidad alta':
        return '⚠️ ';
      case 'observar':
        return '👁 ';
      default:
        return '❤️ ';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _estadoColor(context, estado);
    final tieneContexto = animal.ganaderoNombre.isNotEmpty;
    final edad = DateTime.now().year - animal.fechaNacimiento.year;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            // Barn watermark
            Positioned(
              right: 50,
              bottom: -10,
              child: Icon(
                Icons.home_work_outlined,
                size: 80,
                color: cs.outlineVariant.withOpacity(0.3),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  // Animal image placeholder
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.pets, color: cs.primary, size: 34),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.nombre,
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: cs.onSurface,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          tieneContexto
                              ? '${animal.ganaderoNombre} · ${animal.raza}'
                              : '${animal.raza} · $edad año${edad == 1 ? '' : 's'} · ${animal.idExterno}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_estadoEmoji(estado)}$estado',
                            style: tt.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right,
                      color: cs.outlineVariant, size: 22),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
