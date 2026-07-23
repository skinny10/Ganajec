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
    super.severidad,
    super.sintomasNlp,
    super.concordanciaNlp,
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
    List<String>? sintomasNlp,
    double? concordanciaNlp,
  }) {
    // features_nlp viene en la respuesta de POST /registros-sintomas
    final featuresNlp = json['features_nlp'] as Map<String, dynamic>? ?? {};
    final analisisTexto = featuresNlp['analisis_texto'] as Map<String, dynamic>? ?? {};

    // Síntomas detectados por NLP (se usa si no se pasan explícitamente)
    final sintomasFromFeatures = (analisisTexto['sintomas_detectados'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    // Concordancia NLP–RF (0.0 a 1.0)
    final concordanciaFromFeatures =
        (analisisTexto['concordancia_con_prediccion'] as num?)?.toDouble() ?? 0.0;

    final bovino = json['bovino'] as Map<String, dynamic>?;
    return PrediccionModel(
      // v2: POST /registros-sintomas ya no devuelve id en la prediccion
      id: json['id'] as String? ?? '',
      animalId: animalId ?? (bovino?['id'] as String? ?? ''),
      animalNombre: animalNombre ?? (bovino?['nombre'] as String? ?? ''),
      animalIdExterno: bovino?['id_externo'] as String? ?? '',
      enfermedad: json['enfermedad'] as String? ?? 'Sin diagnóstico',
      confianza: (json['confianza'] as num? ?? 0).toDouble(),
      severidad: json['severidad'] as String? ?? '',
      // v2: POST /registros-sintomas tampoco devuelve generado_en
      fecha: json['generado_en'] != null
          ? DateTime.parse(json['generado_en'] as String)
          : json['fecha'] != null
              ? DateTime.parse(json['fecha'] as String)
              : DateTime.now(),
      sintomasNlp: sintomasNlp ?? sintomasFromFeatures,
      concordanciaNlp: concordanciaNlp ?? concordanciaFromFeatures,
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
