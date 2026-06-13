import 'package:flutter/material.dart';
import 'package:ganajec/features/dueno/domain/entities/dueno_dashboard.dart';

class GanaderoListTile extends StatelessWidget {
  final GanaderoResumen ganadero;

  const GanaderoListTile({super.key, required this.ganadero});

  Color _colorAvatar() {
    final colores = [
      const Color(0xFF4CAF50),
      const Color(0xFF7B5EA7),
      const Color(0xFFBF6030),
    ];
    return colores[ganadero.id.hashCode % colores.length];
  }

  String _tiempoRelativo(DateTime? fecha) {
    if (fecha == null) return '';
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'Ayer';
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: _colorAvatar(),
            child: Text(
              ganadero.iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ganadero.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${ganadero.totalBovinos}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ganadero.activoHoy ? 'Activo hoy' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    Text(
                      _tiempoRelativo(ganadero.ultimaActividad),
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (ganadero.alertasAltas > 0)
                      _tag(
                          '${ganadero.alertasAltas} alerta alta',
                          const Color(0xFFFFEBEE),
                          const Color(0xFFE53935)),
                    if (ganadero.alertasAltas > 0)
                      const SizedBox(width: 6),
                    _tag(
                        '${ganadero.animalesSanos} sanos',
                        const Color(0xFFE8F5E9),
                        const Color(0xFF43A047)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(String texto, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style:
            TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }
}
