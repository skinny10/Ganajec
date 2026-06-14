import 'package:ganajec/share/domain/entities/animal.dart';

class AnimalModel extends Animal {
  const AnimalModel({
    required super.id,
    required super.ranchoId,
    required super.ganaderoId,
    required super.nombre,
    required super.raza,
    required super.sexo,
    super.categoria = '',
    super.proposito = '',
    required super.fechaNacimiento,
    required super.pesoKg,
    required super.idExterno,
    required super.creadoEn,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'] as String,
      ranchoId: json['rancho_id'] as String? ?? '',
      ganaderoId: json['ganadero_id'] as String? ?? '',
      nombre: json['nombre'] as String,
      raza: json['raza'] as String? ?? '',
      sexo: json['sexo'] as String? ?? '',
      categoria: json['categoria'] as String? ?? '',
      proposito: json['proposito'] as String? ?? '',
      fechaNacimiento: DateTime.parse(json['fecha_nacimiento'] as String),
      pesoKg: (json['peso_kg'] as num).toDouble(),
      idExterno: json['id_externo'] as String? ?? '',
      creadoEn: DateTime.parse(json['creado_en'] as String),
    );
  }

  /// Body para POST /bovinos y PUT /bovinos/{id}
  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'raza': raza,
        'sexo': sexo,
        'categoria': categoria.isNotEmpty ? categoria : 'vaca',
        'proposito': proposito.isNotEmpty ? proposito : 'leche',
        'fecha_nacimiento': _fmtDate(fechaNacimiento),
        'peso_kg': pesoKg,
        if (idExterno.isNotEmpty) 'id_externo': idExterno,
      };

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
