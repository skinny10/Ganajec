enum AlertaTipo { prediccion, isolationForest, nlp, sistema }

enum AlertaSeveridad { alta, moderada, leve, ninguna }

enum AlertaAccion { ninguna, verDetalle, verResultado }

class Alerta {
  final String id;
  final AlertaTipo tipo;
  final AlertaSeveridad severidad;
  final String titulo;
  final String descripcion;
  final String? animalId;
  final String? animalNombre;
  final String? animalIdExterno;
  final DateTime fecha;
  final bool leida;
  final AlertaAccion accion;

  const Alerta({
    required this.id,
    required this.tipo,
    required this.severidad,
    required this.titulo,
    required this.descripcion,
    this.animalId,
    this.animalNombre,
    this.animalIdExterno,
    required this.fecha,
    required this.leida,
    this.accion = AlertaAccion.ninguna,
  });

  Alerta copyWith({bool? leida}) {
    return Alerta(
      id: id,
      tipo: tipo,
      severidad: severidad,
      titulo: titulo,
      descripcion: descripcion,
      animalId: animalId,
      animalNombre: animalNombre,
      animalIdExterno: animalIdExterno,
      fecha: fecha,
      leida: leida ?? this.leida,
      accion: accion,
    );
  }
}
