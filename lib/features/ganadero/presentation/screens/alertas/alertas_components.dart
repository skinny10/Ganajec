import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';

// ─── Paleta ──────────────────────────────────────────────────────────────────
const _kBg = Color(0xFFFAFAF7);
const _kSurface = Color(0xFFFFFFFF);
const _kBorder = Color(0xFFE8E5DC);
const _kCream = Color(0xFFF5F3EE);
const _kTextPrimary = Color(0xFF1A1A1A);
const _kTextSecondary = Color(0xFF888880);
const _kTextMuted = Color(0xFFAEADA6);
const _kRed = Color(0xFFC0392B);
const _kRedLight = Color(0xFFFDEDEC);
const _kRedBorder = Color(0xFFF5C6C2);
const _kYellow = Color(0xFFB8860B);
const _kYellowLight = Color(0xFFFEF9E7);
const _kGreen = Color(0xFF1D7A55);
const _kGreenLight = Color(0xFFE8F5EF);
const _kPurple = Color(0xFF534AB7);
const _kPurpleLight = Color(0xFFEEEDFE);

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

_TipoConfig _configFor(AlertaTipo tipo, AlertaSeveridad sev) {
  switch (tipo) {
    case AlertaTipo.prediccion:
      if (sev == AlertaSeveridad.alta) {
        return const _TipoConfig(
          iconBg: _kRedLight,
          labelColor: _kRed,
          emoji: '🦠',
          etiqueta: 'Predicción · Severidad alta',
        );
      }
      if (sev == AlertaSeveridad.moderada) {
        return const _TipoConfig(
          iconBg: _kYellowLight,
          labelColor: _kYellow,
          emoji: '🦷',
          etiqueta: 'Predicción · Severidad moderada',
        );
      }
      return const _TipoConfig(
        iconBg: _kGreenLight,
        labelColor: _kGreen,
        emoji: '✅',
        etiqueta: 'Predicción · Sin enfermedad',
      );
    case AlertaTipo.isolationForest:
      if (sev == AlertaSeveridad.alta) {
        return const _TipoConfig(
          iconBg: _kRedLight,
          labelColor: _kRed,
          emoji: '📉',
          etiqueta: 'Isolation Forest · Anomalía productiva',
        );
      }
      return const _TipoConfig(
        iconBg: _kYellowLight,
        labelColor: _kYellow,
        emoji: '📊',
        etiqueta: 'Isolation Forest · Resumen semanal',
      );
    case AlertaTipo.nlp:
      return const _TipoConfig(
        iconBg: _kPurpleLight,
        labelColor: _kPurple,
        emoji: '🧠',
        etiqueta: 'NLP · Síntoma nuevo detectado',
      );
    case AlertaTipo.sistema:
      return const _TipoConfig(
        iconBg: _kCream,
        labelColor: _kTextMuted,
        emoji: '⚙️',
        etiqueta: 'Sistema · Actualización',
      );
  }
}

// ─── Barra de resumen ─────────────────────────────────────────────────────────

class AlertasSummaryBar extends StatelessWidget {
  final int unreadCount;
  const AlertasSummaryBar({super.key, required this.unreadCount});

  @override
  Widget build(BuildContext context) {
    final hasUnread = unreadCount > 0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: hasUnread ? _kRedLight : _kGreenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasUnread ? _kRedBorder : const Color(0xFFA8D5BC),
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
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: hasUnread ? _kRed : _kGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasUnread
                      ? 'Tienes notificaciones pendientes de revisar'
                      : 'No tienes alertas sin leer',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    color: hasUnread
                        ? const Color(0xFFA93226)
                        : const Color(0xFF1A4731),
                  ),
                ),
              ],
            ),
          ),
          if (hasUnread) ...[
            const SizedBox(width: 8),
            Text(
              '$unreadCount',
              style: const TextStyle(
                fontFamily: 'serif',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: _kRed,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4, left: 2),
      child: Text(
        titulo.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _kTextMuted,
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
    final cfg = _configFor(alerta.tipo, alerta.severidad);
    final isUnread = !alerta.leida;
    final hasAnimal =
        alerta.animalNombre != null && alerta.animalNombre!.isNotEmpty;
    final hasAccion = alerta.accion != AlertaAccion.ninguna;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
        decoration: BoxDecoration(
          color: isUnread ? _kSurface : _kBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icono tipo
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
            // Cuerpo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etiqueta de tipo
                  Text(
                    cfg.etiqueta,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.06 * 9.5,
                      color: cfg.labelColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Título
                  Text(
                    alerta.titulo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isUnread ? FontWeight.w500 : FontWeight.w400,
                      color: isUnread ? _kTextPrimary : _kTextSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Descripción
                  Text(
                    alerta.descripcion,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: _kTextSecondary,
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
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: _kTextMuted,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (hasAccion) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        onAccion?.call();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: alerta.tipo == AlertaTipo.prediccion &&
                                    alerta.severidad == AlertaSeveridad.alta
                                ? _kRedBorder
                                : _kBorder,
                          ),
                        ),
                        child: Text(
                          alerta.accion == AlertaAccion.verDetalle
                              ? 'Ver detalle del animal →'
                              : 'Ver resultado →',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: alerta.tipo == AlertaTipo.prediccion &&
                                    alerta.severidad == AlertaSeveridad.alta
                                ? _kRed
                                : _kTextPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Columna derecha: hora + dot
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatHora(alerta.fecha),
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kTextMuted,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _kRed,
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
