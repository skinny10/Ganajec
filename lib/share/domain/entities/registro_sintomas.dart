class RegistroSintomas {
  final String animalId;
  final DateTime fecha;
  final List<String> sintomas;
  final double litrosLeche;
  final double kgAlimento;
  final double temperatura;
  final String descripcion;

  const RegistroSintomas({
    required this.animalId,
    required this.fecha,
    required this.sintomas,
    required this.litrosLeche,
    required this.kgAlimento,
    required this.temperatura,
    required this.descripcion,
  });
}
