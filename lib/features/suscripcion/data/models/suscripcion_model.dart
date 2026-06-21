import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

class SuscripcionModel extends SuscripcionInfo {
  const SuscripcionModel({
    required super.planActual,
    required super.bovinosUsados,
    required super.analisisUsados,
    super.renovacion,
  });

  factory SuscripcionModel.fromJson(Map<String, dynamic> json) {
    // La API puede devolver "gratuito", "basico", "pro", "cooperativa"
    final planStr = (json['plan_actual'] as String? ??
            json['plan'] as String? ??
            'gratuito')
        .toLowerCase();

    final tipo = PlanTipo.values.firstWhere(
      (p) => p.name.toLowerCase() == planStr,
      orElse: () => PlanTipo.gratuito,
    );
    final planActual = kPlanes.firstWhere(
      (p) => p.tipo == tipo,
      orElse: () => kPlanes.first,
    );

    final renovStr = json['fecha_renovacion'] as String? ??
        json['renovacion'] as String?;

    return SuscripcionModel(
      planActual: planActual,
      bovinosUsados:
          (json['bovinos_usados'] as num? ?? 0).toInt(),
      analisisUsados: (json['analisis_usados'] as num? ??
              json['analisis_mes_usados'] as num? ??
              0)
          .toInt(),
      renovacion:
          renovStr != null ? DateTime.tryParse(renovStr) : null,
    );
  }
}
