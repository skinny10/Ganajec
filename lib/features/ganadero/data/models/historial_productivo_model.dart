import '../../domain/entities/historial_productivo.dart';

class HistorialProductivoModel extends HistorialProductivo {
  const HistorialProductivoModel({
    required super.id,
    required super.animalId,
    required super.fecha,
    required super.litrosLeche,
    required super.kgAlimento,
    required super.temperatura,
    required super.anomaliaDetectada,
  });

  factory HistorialProductivoModel.fromJson(Map<String, dynamic> json) {
    return HistorialProductivoModel(
      id: json['id'] as String,
      animalId: json['animal_id'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      litrosLeche: (json['litros_leche'] as num).toDouble(),
      kgAlimento: (json['kg_alimento'] as num).toDouble(),
      temperatura: (json['temperatura'] as num).toDouble(),
      anomaliaDetectada: json['anomalia_detectada'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'animal_id': animalId,
        'fecha': fecha.toIso8601String(),
        'litros_leche': litrosLeche,
        'kg_alimento': kgAlimento,
        'temperatura': temperatura,
        'anomalia_detectada': anomaliaDetectada,
      };
}