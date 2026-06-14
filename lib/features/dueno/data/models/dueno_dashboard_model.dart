import '../../domain/entities/dueno_dashboard.dart';

class CasoCriticoModel extends CasoCritico {
  const CasoCriticoModel({
    required super.id,
    required super.nombreAnimal,
    required super.raza,
    required super.animalId,
    required super.porcentajeRiesgo,
    required super.severidad,
    required super.ganaderoNombre,
    required super.fechaDeteccion,
  });

  factory CasoCriticoModel.fromJson(Map<String, dynamic> json) {
    return CasoCriticoModel(
      id: json['id'],
      nombreAnimal: json['nombre_animal'],
      raza: json['raza'],
      animalId: json['animal_id'],
      porcentajeRiesgo: (json['porcentaje_riesgo'] as num).toDouble(),
      severidad: json['severidad'],
      ganaderoNombre: json['ganadero_nombre'],
      fechaDeteccion: DateTime.parse(json['fecha_deteccion']),
    );
  }
}

class GanaderoResumenModel extends GanaderoResumen {
  const GanaderoResumenModel({
    required super.id,
    required super.nombre,
    required super.iniciales,
    required super.totalBovinos,
    required super.alertasAltas,
    required super.animalesSanos,
    required super.activoHoy,
    super.ultimaActividad,
  });

  factory GanaderoResumenModel.fromJson(Map<String, dynamic> json) {
    final nombre = json['nombre'] as String;
    final partes = nombre.split(' ');
    final iniciales = partes.length >= 2
        ? '${partes[0][0]}${partes[1][0]}'.toUpperCase()
        : nombre.substring(0, 2).toUpperCase();
    return GanaderoResumenModel(
      id: json['id'],
      nombre: nombre,
      iniciales: iniciales,
      totalBovinos: json['total_bovinos'] ?? 0,
      alertasAltas: 0,
      animalesSanos: 0,
      activoHoy: true,
    );
  }
}

class DuenoDashboardModel extends DuenoDashboard {
  const DuenoDashboardModel({
    required super.totalAnimales,
    required super.animalesConAlerta,
    required super.animalesSanos,
    required super.ganadoresEnCampo,
    required super.produccionLecheHoy,
    required super.produccionLecheAyer,
    required super.casosCriticos,
    required super.ganaderos,
    super.nombreDueno,
    super.nombreRancho,
  });

  factory DuenoDashboardModel.fromJson(Map<String, dynamic> json) {
    return DuenoDashboardModel(
      totalAnimales: json['total_animales'],
      animalesConAlerta: json['animales_con_alerta'],
      animalesSanos: json['animales_sanos'],
      ganadoresEnCampo: json['ganaderos_en_campo'],
      produccionLecheHoy: (json['produccion_leche_hoy'] as num).toDouble(),
      produccionLecheAyer: (json['produccion_leche_ayer'] as num).toDouble(),
      casosCriticos: (json['casos_criticos'] as List)
          .map((e) => CasoCriticoModel.fromJson(e))
          .toList(),
      ganaderos: (json['ganaderos'] as List)
          .map((e) => GanaderoResumenModel.fromJson(e))
          .toList(),
      nombreDueno: json['nombre_dueno'] ?? '',
      nombreRancho: json['nombre_rancho'] ?? '',
    );
  }
}
