import 'package:ganajec/core/domain/entities/animal.dart';

class AnimalModel extends Animal {
  const AnimalModel({
    required super.id,
    required super.ranchoId,
    required super.ganaderoId,
    required super.nombre,
    required super.raza,
    required super.sexo,
    required super.fechaNacimiento,
    required super.pesoKg,
    required super.idExterno,
    required super.creadoEn,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as String,
      ranchoId: json['rancho_id'] as String,
      ganaderoId: json['ganadero_id'] as String,
      nombre: json['nombre'] as String,
      raza: json['raza'] as String,
      sexo: json['sexo'] as String,
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      pesoKg: (json['peso_kg'] as num).toDouble(),
      idExterno: json['id_externo'] as String,
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'rancho_id': ranchoId,
        'ganadero_id': ganaderoId,
        'nombre': nombre,
        'raza': raza,
        'sexo': sexo,
        'fecha_nacimiento': fechaNacimiento.toIso8601String(),
        'peso_kg': pesoKg,
        'id_externo': idExterno,
        'creado_en': creadoEn.toIso8601String(),
      };
}