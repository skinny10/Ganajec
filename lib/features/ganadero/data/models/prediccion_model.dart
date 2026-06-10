import 'package:ganajec/core/domain/entities/prediccion.dart';

class PrediccionModel extends Prediccion {
  const PrediccionModel({
    required super.id,
    required super.animalId,
    required super.animalNombre,
    required super.enfermedad,
    required super.confianza,
    required super.fecha,
  });

  factory PrediccionModel.fromJson(Map<String, dynamic> json) {
    return PrediccionModel(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      animalNombre: json['animal_nombre'] as String,
      enfermedad: json['enfermedad'] as String,
      confianza: (json['confianza'] as num).toDouble(),
      fecha: DateTime.parse(json['fecha'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_id': animalId,
        'animal_nombre': animalNombre,
        'enfermedad': enfermedad,
        'confianza': confianza,
        'fecha': fecha.toIso8601String(),
      };
}