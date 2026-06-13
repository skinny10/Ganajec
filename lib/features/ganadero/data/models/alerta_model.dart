import 'package:ganajec/share/domain/entities/alerta.dart';

class AlertaModel extends Alerta {
  const AlertaModel({
    required super.id,
    required super.tipo,
    required super.severidad,
    required super.titulo,
    required super.descripcion,
    super.animalId,
    super.animalNombre,
    super.animalIdExterno,
    required super.fecha,
    required super.leida,
    super.accion,
  });

  factory AlertaModel.fromJson(Map<String, dynamic> json) {
    return AlertaModel(
      id: json['id'] as String,
      tipo: AlertaTipo.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => AlertaTipo.sistema,
      ),
      severidad: AlertaSeveridad.values.firstWhere(
        (e) => e.name == json['severidad'],
        orElse: () => AlertaSeveridad.ninguna,
      ),
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
      animalId: json['animal_id'] as String?,
      animalNombre: json['animal_nombre'] as String?,
      animalIdExterno: json['animal_id_externo'] as String?,
      fecha: DateTime.parse(json['fecha'] as String),
      leida: json['leida'] as bool,
      accion: AlertaAccion.values.firstWhere(
        (e) => e.name == (json['accion'] ?? 'ninguna'),
        orElse: () => AlertaAccion.ninguna,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo.name,
        'severidad': severidad.name,
        'titulo': titulo,
        'descripcion': descripcion,
        'animal_id': animalId,
        'animal_nombre': animalNombre,
        'animal_id_externo': animalIdExterno,
        'fecha': fecha.toIso8601String(),
        'leida': leida,
        'accion': accion.name,
      };
}
