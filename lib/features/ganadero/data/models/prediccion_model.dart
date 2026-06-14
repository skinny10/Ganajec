import 'package:ganajec/share/domain/entities/prediccion.dart';

class PrediccionModel extends Prediccion {
  const PrediccionModel({
    required super.id,
    required super.animalId,
    required super.animalNombre,
    required super.enfermedad,
    required super.confianza,
    required super.fecha,
  });

  /// Parsea un elemento de la lista `predicciones` de la API.
  ///
  /// Casos:
  ///  - GET /ganadero/{id}/predicciones  → cada item trae `bovino: {id, nombre}`
  ///  - GET /ganadero/bovinos/{id}/predicciones → no trae `bovino`; pasa [animalId]/[animalNombre]
  ///  - POST /registros-sintomas → respuesta.prediccion; pasa [animalId]/[animalNombre]
  factory PrediccionModel.fromJson(
    Map<String, dynamic> json, {
    String? animalId,
    String? animalNombre,
  }) {
    final bovino = json['bovino'] as Map<String, dynamic>?;
    return PrediccionModel(
      id: json['id'] as String,
      animalId: animalId ?? (bovino?['id'] as String? ?? ''),
      animalNombre: animalNombre ?? (bovino?['nombre'] as String? ?? ''),
      enfermedad: json['enfermedad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      // La API usa `generado_en`; fallback por si algún endpoint usa otra clave.
      fecha: DateTime.parse(
        (json['generado_en'] ?? json['fecha'] ?? DateTime.now().toIso8601String())
            as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_id': animalId,
        'animal_nombre': animalNombre,
        'enfermedad': enfermedad,
        'confianza': confianza,
        'generado_en': fecha.toIso8601String(),
      };
}
