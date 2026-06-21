import 'package:ganajec/share/domain/entities/prediccion.dart';

class PrediccionModel extends Prediccion {
  const PrediccionModel({
    required super.id,
    required super.animalId,
    required super.animalNombre,
    required super.enfermedad,
    required super.confianza,
    required super.fecha,
    super.animalIdExterno,
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
      // v2: POST /registros-sintomas ya no devuelve id en la prediccion
      id: json['id'] as String? ?? '',
      animalId: animalId ?? (bovino?['id'] as String? ?? ''),
      animalNombre: animalNombre ?? (bovino?['nombre'] as String? ?? ''),
      animalIdExterno: bovino?['id_externo'] as String? ?? '',
      enfermedad: json['enfermedad'] as String? ?? 'Sin diagnóstico',
      confianza: (json['confianza'] as num? ?? 0).toDouble(),
      // v2: POST /registros-sintomas tampoco devuelve generado_en
      fecha: json['generado_en'] != null
          ? DateTime.parse(json['generado_en'] as String)
          : json['fecha'] != null
              ? DateTime.parse(json['fecha'] as String)
              : DateTime.now(),
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
