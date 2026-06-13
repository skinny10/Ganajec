import 'package:flutter/material.dart';
import '../../domain/entities/dueno_dashboard.dart';

class GanaderoAvatarChip extends StatelessWidget {
  final GanaderoResumen ganadero;
  final VoidCallback onTap;

  const GanaderoAvatarChip({
    super.key,
    required this.ganadero,
    required this.onTap,
  });

  Color _colorAvatar(String id) {
    final colores = [
      const Color(0xFF4CAF50),
      const Color(0xFF7B5EA7),
      const Color(0xFFBF6030),
      const Color(0xFF2196F3),
      const Color(0xFFE91E63),
    ];
    return colores[id.hashCode % colores.length];
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final colorAvatar = _colorAvatar(ganadero.id);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: colorAvatar,
                child: Text(
                  ganadero.iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              if (ganadero.activoHoy)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ganadero.nombre.split(' ').first,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            '${ganadero.totalBovinos} bovinos',
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
