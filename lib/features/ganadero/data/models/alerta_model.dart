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
    // Normaliza el tipo: la API puede devolver snake_case o camelCase
    // e.g. "isolation_forest" → isolationForest, "prediccion" → prediccion
    final tipoRaw = (json['tipo'] as String? ?? 'sistema')
        .toLowerCase()
        .replaceAll('_', '');
    final tipo = AlertaTipo.values.firstWhere(
      (e) => e.name.toLowerCase() == tipoRaw,
      orElse: () => AlertaTipo.sistema,
    );

    final sevRaw = (json['severidad'] as String? ?? 'ninguna').toLowerCase();
    final severidad = AlertaSeveridad.values.firstWhere(
      (e) => e.name.toLowerCase() == sevRaw,
      orElse: () => AlertaSeveridad.ninguna,
    );

    // accion: "ver_detalle" → verDetalle, "ver_resultado" → verResultado
    final accionRaw = (json['accion'] as String? ?? 'ninguna')
        .toLowerCase()
        .replaceAll('_', '');
    final accion = AlertaAccion.values.firstWhere(
      (e) => e.name.toLowerCase() == accionRaw,
      orElse: () => AlertaAccion.ninguna,
    );

    // fecha: puede venir como "fecha", "created_at", "generado_en"
    final fechaStr = json['fecha'] as String? ??
        json['created_at'] as String? ??
        json['generado_en'] as String? ??
        DateTime.now().toIso8601String();

    return AlertaModel(
      id: json['id'] as String? ?? '',
      tipo: tipo,
      severidad: severidad,
      titulo: json['titulo'] as String? ??
          json['message'] as String? ??
          json['mensaje'] as String? ??
          'Sin título',
      descripcion: json['descripcion'] as String? ??
          json['mensaje'] as String? ??
          '',
      animalId: json['animal_id'] as String? ?? json['bovino_id'] as String?,
      animalNombre: json['animal_nombre'] as String? ??
          json['nombre_bovino'] as String?,
      animalIdExterno: json['animal_id_externo'] as String?,
      fecha: DateTime.parse(fechaStr),
      leida: json['leida'] as bool? ?? false,
      accion: accion,
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
