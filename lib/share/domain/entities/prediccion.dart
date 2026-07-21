class Prediccion {
  final String id;
  final String animalId;
  final String animalNombre;
  final String animalIdExterno; // ID de arete / registro
  final String enfermedad;
  final double confianza;
  final DateTime fecha;

  /// Campos de contexto — solo presentes en la vista del dueño
  final String ranchoNombre;
  final String ganaderoNombre;
  final String severidad; // baja · media · alta

  /// Síntomas extraídos por el NLP de la API (dccuchile/bert-base-spanish-wwm-cased).
  /// Solo se popula en la respuesta de POST /registros-sintomas.
  final List<String> sintomasNlp;

  const Prediccion({
    required this.id,
    required this.animalId,
    required this.animalNombre,
    required this.enfermedad,
    required this.confianza,
    required this.fecha,
    this.animalIdExterno = '',
    this.ranchoNombre = '',
    this.ganaderoNombre = '',
    this.severidad = '',
    this.sintomasNlp = const [],
  });
}
