import 'package:ganajec/share/domain/entities/historial_item.dart';

/// Parsea un elemento de `predicciones[]` del endpoint
/// GET /ganadero/{ganadero_id}/predicciones
class HistorialItemModel extends HistorialItem {
  const HistorialItemModel({
    required super.id,
    required super.animalId,
    required super.animalNombre,
    required super.animalIdExterno,
    required super.enfermedad,
    required super.emoji,
    required super.confianza,
    required super.severidad,
    required super.fecha,
  });

  factory HistorialItemModel.fromJson(Map<String, dynamic> json) {
    final bovino = json['bovino'] as Map<String, dynamic>? ?? {};
    final enfermedadStr = json['enfermedad'] as String? ?? '';
    final severidadStr = json['severidad'] as String? ?? 'leve';

    return HistorialItemModel(
      id: json['id'] as String,
      animalId: bovino['id'] as String? ?? '',
      animalNombre: bovino['nombre'] as String? ?? '',
      animalIdExterno: bovino['id_externo'] as String? ?? '',
      enfermedad: enfermedadStr,
      emoji: _emojiPara(enfermedadStr),
      confianza: (json['confianza'] as num).toDouble(),
      severidad: _severidadDesde(enfermedadStr, severidadStr),
      fecha: DateTime.parse(json['generado_en'] as String),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static HistorialSeveridad _severidadDesde(String enfermedad, String s) {
    final e = enfermedad.toLowerCase();
    if (e.contains('sin anomal') || e.contains('sin enfermedad')) {
      return HistorialSeveridad.sinEnfermedad;
    }
    switch (s.toLowerCase()) {
      case 'alta':
        return HistorialSeveridad.alta;
      case 'moderada':
        return HistorialSeveridad.moderada;
      default:
        return HistorialSeveridad.leve;
    }
  }

  static String _emojiPara(String enfermedad) {
    final e = enfermedad.toLowerCase();
    if (e.contains('sin anomal') || e.contains('sin enfermedad')) return '✅';
    if (e.contains('mastitis')) return '🦠';
    if (e.contains('laminitis')) return '🦷';
    if (e.contains('neumonia') || e.contains('neumonía') || e.contains('respirat')) {
      return '🫁';
    }
    if (e.contains('fiebre') || e.contains('hipertermia')) return '🌡️';
    if (e.contains('diarrea') || e.contains('entero')) return '💧';
    if (e.contains('dermat') || e.contains('hongos') || e.contains('micosis')) {
      return '🔬';
    }
    if (e.contains('antrax') || e.contains('bacterid') || e.contains('carbon')) {
      return '⚠️';
    }
    if (e.contains('aftosa') || e.contains('ampolla')) return '🦴';
    return '🔬';
  }
}
