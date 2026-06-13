import 'plan.dart';

class SuscripcionInfo {
  final Plan planActual;
  final int bovinosUsados;
  final int analisisUsados;
  final DateTime? renovacion;

  const SuscripcionInfo({
    required this.planActual,
    required this.bovinosUsados,
    required this.analisisUsados,
    this.renovacion,
  });

  double get bovinosPct {
    final max = planActual.bovinosMax;
    if (max == null || max == 0) return 0;
    return (bovinosUsados / max).clamp(0.0, 1.0);
  }

  double get analisisPct {
    if (planActual.analisisMes <= 0) return 0;
    return (analisisUsados / planActual.analisisMes).clamp(0.0, 1.0);
  }

  String get bovinosTexto =>
      planActual.bovinosMax != null ? '$bovinosUsados de ${planActual.bovinosMax}' : '$bovinosUsados';

  String get analisisTexto =>
      planActual.analisisMes < 999 ? '$analisisUsados de ${planActual.analisisMes}' : '$analisisUsados';

  String get historialTexto => '${planActual.historialDias} días';

  int get bovinosDisponibles =>
      planActual.bovinosMax != null ? planActual.bovinosMax! - bovinosUsados : 999;
}
