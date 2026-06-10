class HistorialProductivo {
  final String id;
  final String animalId;
  final DateTime fecha;
  final double litrosLeche;
  final double kgAlimento;
  final double temperatura;
  final bool anomaliaDetectada;

  const HistorialProductivo({
    required this.id,
    required this.animalId,
    required this.fecha,
    required this.litrosLeche,
    required this.kgAlimento,
    required this.temperatura,
    required this.anomaliaDetectada,
  });
}