class Alerta {
  final String id;
  final String animalId;
  final String ganaderoId;
  final String tipo;
  final String severidad;
  final String mensaje;
  final bool leida;
  final DateTime creadoEn;

  const Alerta({
    required this.id,
    required this.animalId,
    required this.ganaderoId,
    required this.tipo,
    required this.severidad,
    required this.mensaje,
    required this.leida,
    required this.creadoEn,
  });
}