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

  Animal copyWith({
    String? id,
    String? ranchoId,
    String? ganaderoId,
    String? nombre,
    String? raza,
    String? sexo,
    DateTime? fechaNacimiento,
    double? pesoKg,
    String? idExterno,
    DateTime? creadoEn,
  }) {
    return Animal(
      id: id ?? this.id,
      ranchoId: ranchoId ?? this.ranchoId,
      ganaderoId: ganaderoId ?? this.ganaderoId,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoKg: pesoKg ?? this.pesoKg,
      idExterno: idExterno ?? this.idExterno,
      creadoEn: creadoEn ?? this.creadoEn,
    );
  }
}