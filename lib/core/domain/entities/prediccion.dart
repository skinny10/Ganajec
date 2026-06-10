class Prediccion {
  final String id;
  final String animalId;
  final String animalNombre;
  final String enfermedad;
  final double confianza;
  final DateTime fecha;

  const Prediccion({
    required this.id,
    required this.animalId,
    required this.animalNombre,
    required this.enfermedad,
    required this.confianza,
    required this.fecha,
  });
}