enum HistorialSeveridad { alta, moderada, leve, sinEnfermedad }

class HistorialItem {
  final String id;
  final String animalId;
  final String animalNombre;
  final String animalIdExterno;
  final String enfermedad;
  final String emoji;
  final double confianza; // 0.0–1.0
  final HistorialSeveridad severidad;
  final DateTime fecha;

  const HistorialItem({
    required this.id,
    required this.animalId,
    required this.animalNombre,
    required this.animalIdExterno,
    required this.enfermedad,
    required this.emoji,
    required this.confianza,
    required this.severidad,
    required this.fecha,
  });

  bool get esSinEnfermedad => severidad == HistorialSeveridad.sinEnfermedad;

  /// Porcentaje de confianza como entero (0–100)
  int get confianzaPct => (confianza * 100).round();
}
