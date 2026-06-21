class Animal {
  final String id;
  final String ranchoId;
  final String ganaderoId;
  final String nombre;
  final String raza;
  final String sexo;

  /// Categoría del bovino según la API:
  /// vaca · toro · becerro · becerra · novillo · vaquilla · torete
  final String categoria;

  /// Propósito del bovino según la API:
  /// leche · carne · doble · cria
  final String proposito;

  final DateTime fechaNacimiento;
  final double pesoKg;
  final String idExterno;
  final DateTime creadoEn;

  /// Campos de contexto — solo presentes en la vista del dueño
  final String ranchoNombre;
  final String ganaderoNombre;

  const Animal({
    required this.id,
    required this.ranchoId,
    required this.ganaderoId,
    required this.nombre,
    required this.raza,
    required this.sexo,
    this.categoria = '',
    this.proposito = '',
    required this.fechaNacimiento,
    required this.pesoKg,
    required this.idExterno,
    required this.creadoEn,
    this.ranchoNombre = '',
    this.ganaderoNombre = '',
  });

  Animal copyWith({
    String? id,
    String? ranchoId,
    String? ganaderoId,
    String? nombre,
    String? raza,
    String? sexo,
    String? categoria,
    String? proposito,
    DateTime? fechaNacimiento,
    double? pesoKg,
    String? idExterno,
    DateTime? creadoEn,
    String? ranchoNombre,
    String? ganaderoNombre,
  }) {
    return Animal(
      id: id ?? this.id,
      ranchoId: ranchoId ?? this.ranchoId,
      ganaderoId: ganaderoId ?? this.ganaderoId,
      nombre: nombre ?? this.nombre,
      raza: raza ?? this.raza,
      sexo: sexo ?? this.sexo,
      categoria: categoria ?? this.categoria,
      proposito: proposito ?? this.proposito,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      pesoKg: pesoKg ?? this.pesoKg,
      idExterno: idExterno ?? this.idExterno,
      creadoEn: creadoEn ?? this.creadoEn,
      ranchoNombre: ranchoNombre ?? this.ranchoNombre,
      ganaderoNombre: ganaderoNombre ?? this.ganaderoNombre,
    );
  }
}
