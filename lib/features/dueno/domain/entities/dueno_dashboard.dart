class DuenoDashboard {
  final int totalAnimales;
  final int animalesConAlerta;
  final int animalesSanos;
  final int ganadoresEnCampo;
  final double produccionLecheHoy;
  final double produccionLecheAyer;
  final List<CasoCritico> casosCriticos;
  final List<GanaderoResumen> ganaderos;

  const DuenoDashboard({
    required this.totalAnimales,
    required this.animalesConAlerta,
    required this.animalesSanos,
    required this.ganadoresEnCampo,
    required this.produccionLecheHoy,
    required this.produccionLecheAyer,
    required this.casosCriticos,
    required this.ganaderos,
  });

  double get porcentajeCambioLeche {
    if (produccionLecheAyer == 0) return 0;
    return ((produccionLecheHoy - produccionLecheAyer) / produccionLecheAyer) * 100;
  }
}

class CasoCritico {
  final String id;
  final String nombreAnimal;
  final String raza;
  final String animalId;
  final double porcentajeRiesgo;
  final String severidad;
  final String ganaderoNombre;
  final DateTime fechaDeteccion;

  const CasoCritico({
    required this.id,
    required this.nombreAnimal,
    required this.raza,
    required this.animalId,
    required this.porcentajeRiesgo,
    required this.severidad,
    required this.ganaderoNombre,
    required this.fechaDeteccion,
  });
}

class GanaderoResumen {
  final String id;
  final String nombre;
  final String iniciales;
  final int totalBovinos;
  final int alertasAltas;
  final int animalesSanos;
  final bool activoHoy;
  final DateTime? ultimaActividad;

  const GanaderoResumen({
    required this.id,
    required this.nombre,
    required this.iniciales,
    required this.totalBovinos,
    required this.alertasAltas,
    required this.animalesSanos,
    required this.activoHoy,
    this.ultimaActividad,
  });
}
