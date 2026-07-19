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
    String planStr = 'gratuito';

    // Backend nuevo: plan es un objeto {nombre: "Pro", ...}
    if (json['plan'] is Map) {
      planStr = (json['plan']['nombre'] as String? ?? 'gratuito').toLowerCase();
    }
    // Backend legacy: plan_actual o plan como string
    else if (json['plan_actual'] is String) {
      planStr = (json['plan_actual'] as String).toLowerCase();
    } else if (json['plan'] is String) {
      planStr = (json['plan'] as String).toLowerCase();
    }

    final tipo = PlanTipo.values.firstWhere(
      (p) => p.name.toLowerCase() == planStr,
      orElse: () => PlanTipo.gratuito,
    );
    final planActual = kPlanes.firstWhere(
      (p) => p.tipo == tipo,
      orElse: () => kPlanes.first,
    );

    final renovStr = json['fin'] as String? ??
        json['fecha_renovacion'] as String? ??
        json['renovacion'] as String?;

    return SuscripcionModel(
      planActual: planActual,
      bovinosUsados: (json['bovinos_usados'] as num? ?? 0).toInt(),
      analisisUsados:
          (json['analisis_usados'] as num? ?? json['analisis_mes_usados'] as num? ?? 0)
              .toInt(),
      renovacion: renovStr != null ? DateTime.tryParse(renovStr) : null,
    );
  }
}
