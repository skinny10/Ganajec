class Animal {
  final String id;
  final String ranchoId;
  final String ganaderoId;
  final String nombre;
  final String raza;
  final String sexo;
  final DateTime fechaNacimiento;
  final double pesoKg;
  final String idExterno;
  final DateTime creadoEn;

  const Animal({
    required this.id,
    required this.ranchoId,
    required this.ganaderoId,
    required this.nombre,
    required this.raza,
    required this.sexo,
    required this.fechaNacimiento,
    required this.pesoKg,
    required this.idExterno,
    required this.creadoEn,
  });
}