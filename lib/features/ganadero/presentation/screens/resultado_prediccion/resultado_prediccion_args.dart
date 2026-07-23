import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

class ResultadoPrediccionArgs {
  final Animal animal;
  final Prediccion prediccion;
  final List<String> sintomasFormulario;
  /// Síntomas extraídos por el NLP de la API (vienen de prediccion.sintomasNlp).
  final List<String> sintomasNlp;
  final String descripcion;
  final double temperatura;
  final double litrosLeche;
  /// Concordancia entre síntomas NLP y enfermedad predicha por RF (0.0–1.0).
  final double concordanciaNlp;

  const ResultadoPrediccionArgs({
    required this.animal,
    required this.prediccion,
    required this.sintomasFormulario,
    required this.descripcion,
    required this.temperatura,
    required this.litrosLeche,
    this.sintomasNlp = const [],
    this.concordanciaNlp = 0.0,
  });
}
