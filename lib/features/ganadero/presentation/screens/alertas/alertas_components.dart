import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';

// ─── Config visual por tipo ───────────────────────────────────────────────────

class _TipoConfig {
  final Color iconBg;
  final Color labelColor;
  final String emoji;
  final String etiqueta;

  const _TipoConfig({
    required this.iconBg,
    required this.labelColor,
    required this.emoji,
    required this.etiqueta,
  });
}

_TipoConfig _configFor(AlertaTipo tipo, AlertaSeveridad sev, ColorScheme cs) {
  switch (tipo) {
    case AlertaTipo.prediccion:
      if (sev == AlertaSeveridad.alta) {
        return _TipoConfig(
          iconBg: cs.errorContainer,
          labelColor: cs.error,
          emoji: '🦠',
          etiqueta: 'Predicción · Severidad alta',
        );
      }
      if (sev == AlertaSeveridad.moderada) {
        return _TipoConfig(
          iconBg: cs.secondaryContainer,
          labelColor: cs.secondary,
          emoji: '🦷',
          etiqueta: 'Predicción · Severidad moderada',
        );
      }
      return _TipoConfig(
        iconBg: cs.tertiaryContainer,
        labelColor: cs.tertiary,
        emoji: '✅',
        etiqueta: 'Predicción · Sin enfermedad',
      );
    case AlertaTipo.isolationForest:
      if (sev == AlertaSeveridad.alta) {
        return _TipoConfig(
          iconBg: cs.errorContainer,
          labelColor: cs.error,
          emoji: '📉',
          etiqueta: 'Isolation Forest · Anomalía productiva',
        );
      }
      return _TipoConfig(
        iconBg: cs.secondaryContainer,
        labelColor: cs.secondary,
        emoji: '📊',
        etiqueta: 'Isolation Forest · Resumen semanal',
      );
    case AlertaTipo.nlp:
      return _TipoConfig(
        iconBg: cs.secondaryContainer,
        labelColor: cs.onSecondaryContainer,
        emoji: '🧠',
        etiqueta: 'NLP · Síntoma nuevo detectado',
      );
    case AlertaTipo.sistema:
      return _TipoConfig(
        iconBg: cs.surfaceContainerLow,
        labelColor: cs.outline,
        emoji: '⚙️',
        etiqueta: 'Sistema · Actualización',
      );
    case AlertaTipo.clinica:
      if (sev == AlertaSeveridad.alta) {
        return _TipoConfig(
          iconBg: cs.errorContainer,
          labelColor: cs.error,
          emoji: '🩺',
          etiqueta: 'Clínica · Severidad alta',
        );
      }
      if (sev == AlertaSeveridad.moderada) {
        return _TipoConfig(
          iconBg: cs.secondaryContainer,
          labelColor: cs.secondary,
          emoji: '🩺',
          etiqueta: 'Clínica · Severidad moderada',
        );
      }
      return _TipoConfig(
        iconBg: cs.tertiaryContainer,
        labelColor: cs.tertiary,
        emoji: '🩺',
        etiqueta: 'Clínica · Sin anomalía',
      );
  }
}

// ─── Barra de resumen ─────────────────────────────────────────────────────────

class AlertasSummaryBar extends StatelessWidget {
  final int unreadCount;
  const AlertasSummaryBar({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasUnread = unreadCount > 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: hasUnread ? cs.errorContainer : cs.tertiaryContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasUnread
              ? cs.error.withOpacity(0.3)
              : cs.tertiary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            hasUnread ? '🔔' : '✅',
            style: const TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasUnread ? 'Alertas sin leer' : 'Todo al día',
                  style: tt.bodyMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hasUnread ? cs.error : cs.tertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasUnread
                      ? 'Tienes notificaciones pendientes de revisar'
                      : 'No tienes alertas sin leer',
                  style: tt.bodySmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: hasUnread
                        ? cs.onErrorContainer
                        : cs.onTertiaryContainer,
                  ),
                ),
              ],
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(width: 8),
            Text(
              '$unreadCount',
              style: tt.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.error,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Etiqueta de fecha ────────────────────────────────────────────────────────

class AlertasDateLabel extends StatelessWidget {
  final String titulo;
  const AlertasDateLabel({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 2),
      child: Text(
        titulo.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: cs.outline,
          letterSpacing: 0.08 * 10,
        ),
      ),
    );
  }
}

// ─── Tarjeta de notificación ──────────────────────────────────────────────────

class AlertaCard extends StatelessWidget {
  final Alerta alerta;
  final VoidCallback onTap;
  final VoidCallback? onAccion;

  const AlertaCard({
    super.key,
    required this.alerta,
    required this.onTap,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cfg = _configFor(alerta.tipo, alerta.severidad, cs);
    final isUnread = !alerta.leida;
    final hasAnimal =
        alerta.animalNombre != null && alerta.animalNombre!.isNotEmpty;
    final hasAccion = alerta.accion != AlertaAccion.ninguna;
    final isAltaPrediccion = alerta.tipo == AlertaTipo.prediccion &&
        alerta.severidad == AlertaSeveridad.alta;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
        decoration: BoxDecoration(
          color: isUnread ? cs.surfaceContainerLowest : cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cfg.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(cfg.emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cfg.etiqueta,
                    style: tt.labelSmall?.copyWith(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.06 * 9.5,
                      color: cfg.labelColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alerta.titulo,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 13,
                      fontWeight:
                          isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: isUnread ? cs.onSurface : cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    alerta.descripcion,
                    style: tt.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w300,
                      height: 1.5,
                    ),
                  ),
                  if (hasAnimal) ...[
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Text('🐄', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          '${alerta.animalNombre} · ${alerta.animalIdExterno ?? ''}',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 10.5,
                            color: cs.outline,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasAccion) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => onAccion?.call(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAltaPrediccion
                                ? cs.error.withOpacity(0.3)
                                : cs.outlineVariant,
                          ),
                        ),
                        child: Text(
                          alerta.accion == AlertaAccion.verDetalle
                              ? 'Ver detalle del animal →'
                              : 'Ver resultado →',
                          style: tt.labelSmall?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isAltaPrediccion
                                ? cs.error
                                : cs.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatHora(alerta.fecha),
                  style: tt.labelSmall?.copyWith(
                    fontSize: 10,
                    color: cs.outline,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: cs.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatHora(DateTime fecha) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final day = DateTime(fecha.year, fecha.month, fecha.day);

    if (day == today || day == yesterday) {
      final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
      final m = fecha.minute.toString().padLeft(2, '0');
      final ampm = fecha.hour < 12 ? 'am' : 'pm';
      return '$h:$m $ampm';
    }
    const meses = [
      '', 'ene', 'feb', 'mar', 'abr', 'may', 'jun',
      'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
    ];
    return '${fecha.day} ${meses[fecha.month]}';
  }
}
