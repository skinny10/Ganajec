class PrediccionMes {
  final String fecha;
  final String enfermedad;
  final String severidad;
  final String bovino;

  const PrediccionMes({
    required this.fecha,
    required this.enfermedad,
    required this.severidad,
    required this.bovino,
  });

  factory PrediccionMes.fromJson(Map<String, dynamic> json) => PrediccionMes(
        fecha: json['fecha'] as String? ?? '',
        enfermedad: json['enfermedad'] as String? ?? '',
        severidad: json['severidad'] as String? ?? '',
        bovino: json['bovino'] as String? ?? '',
      );
}

class EstadisticasModel {
  final String rancho;
  final Map<String, int> bovinosPorCategoria;
  final Map<String, int> alertasPorSeveridad;
  final List<PrediccionMes> prediccionesMes;

  const EstadisticasModel({
    required this.rancho,
    required this.bovinosPorCategoria,
    required this.alertasPorSeveridad,
    required this.prediccionesMes,
  });

  factory EstadisticasModel.fromJson(Map<String, dynamic> json) {
    final bovinosRaw =
        json['grafica_bovinos_por_categoria'] as Map<String, dynamic>? ?? {};
    final alertasRaw =
        json['grafica_alertas_por_severidad'] as Map<String, dynamic>? ?? {};
    final predsRaw = json['grafica_predicciones_mes'] as List<dynamic>? ?? [];

    return EstadisticasModel(
      rancho: json['rancho'] as String? ?? '',
      bovinosPorCategoria:
          bovinosRaw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      alertasPorSeveridad:
          alertasRaw.map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      prediccionesMes: predsRaw
          .map((e) => PrediccionMes.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  int get totalBovinos =>
      bovinosPorCategoria.values.fold(0, (sum, v) => sum + v);

  int get totalAlertas =>
      alertasPorSeveridad.values.fold(0, (sum, v) => sum + v);
}
