import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

class PrediccionTile extends StatelessWidget {
  final Prediccion prediccion;

  const PrediccionTile({super.key, required this.prediccion});

  Color _confianzaColor(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (prediccion.enfermedad == 'Sin enfermedad') return cs.tertiary;
    if (prediccion.severidad == 'alta' || prediccion.confianza >= 0.8) {
      return cs.error;
    }
    return cs.secondary;
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
    final h = fecha.hour;
    final m = fecha.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }

  String _tiempoRelativo() {
    final diff = DateTime.now().difference(prediccion.fecha);
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) {
      return 'Hace ${diff.inHours} hora${diff.inHours == 1 ? '' : 's'}';
    }
    return 'Hace ${diff.inDays} día${diff.inDays == 1 ? '' : 's'}';
  }

  String _riesgoTexto() {
    if (prediccion.enfermedad == 'Sin enfermedad') {
      return 'Animal en buen estado. Continúa monitoreando.';
    }
    if (prediccion.confianza >= 0.8) {
      return 'Riesgo alto. Se recomienda atención veterinaria inmediata.';
    }
    if (prediccion.confianza >= 0.5) {
      return 'Riesgo moderado de presentar la enfermedad.';
    }
    return 'Riesgo bajo de presentar la enfermedad. Continúa monitoreando los síntomas.';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tieneContexto = prediccion.ganaderoNombre.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // ── Main row ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Disease icon circle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cs.secondary.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _enfermedadIcon(prediccion.enfermedad),
                    color: cs.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // Info column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prediccion.enfermedad,
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: cs.onSecondaryContainer,
                          fontSize: 14,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tieneContexto
                            ? '${prediccion.animalNombre} · ${prediccion.ganaderoNombre} · ${prediccion.ranchoNombre}'
                            : prediccion.animalIdExterno.isNotEmpty
                                ? '${prediccion.animalNombre} · ${prediccion.animalIdExterno}'
                                : prediccion.animalNombre,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSecondaryContainer.withOpacity(0.7),
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.secondary.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _tiempoRelativo(),
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Confidence ring + time
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: CircularProgressIndicator(
                            value: prediccion.confianza,
                            strokeWidth: 4.5,
                            backgroundColor: cs.secondary.withOpacity(0.2),
                            color: cs.onSecondaryContainer,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        Text(
                          '${(prediccion.confianza * 100).toStringAsFixed(0)}%',
                          style: tt.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onSecondaryContainer,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatHora(prediccion.fecha),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSecondaryContainer.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // ── Risk strip ──────────────────────────────────────────────
          Container(
            color: cs.secondary.withOpacity(0.15),
            padding: const EdgeInsets.fromLTRB(14, 9, 14, 9),
            child: Row(
              children: [
                Icon(Icons.shield_outlined,
                    size: 15,
                    color: cs.onSecondaryContainer.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _riesgoTexto(),
                    style: tt.labelSmall?.copyWith(
                      fontSize: 11,
                      color: cs.onSecondaryContainer.withOpacity(0.8),
                      height: 1.35,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right,
                    size: 15,
                    color: cs.onSecondaryContainer.withOpacity(0.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
