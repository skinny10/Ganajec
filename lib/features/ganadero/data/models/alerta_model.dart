import '../../domain/entities/alerta.dart';

class AlertaModel extends Alerta {
  const AlertaModel({
    required super.id,
    required super.animalId,
    required super.ganaderoId,
    required super.tipo,
    required super.severidad,
    required super.mensaje,
    required super.leida,
    required super.creadoEn,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      ganaderoId: json['ganadero_id'] as String,
      tipo: json['tipo'] as String,
      severidad: json['severidad'] as String,
      mensaje: json['mensaje'] as String,
      leida: json['leida'] as bool,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_id': animalId,
        'ganadero_id': ganaderoId,
        'tipo': tipo,
        'severidad': severidad,
        'mensaje': mensaje,
        'leida': leida,
        'creado_en': creadoEn.toIso8601String(),
      };
}