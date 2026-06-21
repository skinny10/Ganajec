class Rancho {
  final String id;
  final String nombre;
  final String municipio;
  final String estado;
  final String duenoId;
  final String duenoNombre;
  final DateTime creadoEn;

  const Rancho({
    required this.id,
    required this.nombre,
    required this.municipio,
    required this.estado,
    required this.duenoId,
    this.duenoNombre = '',
    required this.creadoEn,
  });
}