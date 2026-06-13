import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';

class ResultadoPrediccionArgs {
  final Animal animal;
  final Prediccion prediccion;
  final List<String> sintomasFormulario;
  final String descripcion;
  final double temperatura;
  final double litrosLeche;

  const ResultadoPrediccionArgs({
    required this.animal,
    required this.prediccion,
    required this.sintomasFormulario,
    required this.descripcion,
    required this.temperatura,
    required this.litrosLeche,
  });
}
