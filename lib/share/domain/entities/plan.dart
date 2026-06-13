enum PlanTipo { gratuito, basico, pro, cooperativa }

class PlanFeature {
  final String emoji;
  final String label;
  final bool incluida;
  const PlanFeature({required this.emoji, required this.label, required this.incluida});
}

class Plan {
  final PlanTipo tipo;
  final String nombre;
  final String descripcion;
  final int precioMensual;
  final int? bovinosMax;      // null = ilimitado
  final int analisisMes;
  final int historialDias;
  final List<PlanFeature> features;
  final bool popular;

  const Plan({
    required this.tipo,
    required this.nombre,
    required this.descripcion,
    required this.precioMensual,
    this.bovinosMax,
    required this.analisisMes,
    required this.historialDias,
    required this.features,
    this.popular = false,
  });

  bool get esGratuito => tipo == PlanTipo.gratuito;

  int get precioAnual => (precioMensual * 12 * 0.8).round();
  int get precioAnualMensual => (precioMensual * 0.8).round();

  String get precioTexto => precioMensual == 0
      ? 'Sin costo · Sin tarjeta requerida'
      : '\$$precioMensual MXN/mes';

  String get bovinosTexto =>
      bovinosMax == null ? 'Hato ilimitado' : 'Hasta $bovinosMax bovinos';
}

// Catálogo global de planes
const kPlanes = [
  Plan(
    tipo: PlanTipo.gratuito,
    nombre: 'Gratuito',
    descripcion: 'Para empezar sin compromiso',
    precioMensual: 0,
    bovinosMax: 5,
    analisisMes: 20,
    historialDias: 30,
    features: [
      PlanFeature(emoji: '🐄', label: 'Hasta 5 bovinos', incluida: true),
      PlanFeature(emoji: '🧠', label: 'Predicción de enfermedades', incluida: true),
      PlanFeature(emoji: '📝', label: 'Texto libre en español (NLP básico)', incluida: true),
      PlanFeature(emoji: '📊', label: 'Historial extendido (6 meses)', incluida: false),
      PlanFeature(emoji: '🔔', label: 'Alertas push automáticas', incluida: false),
      PlanFeature(emoji: '📄', label: 'Reportes PDF / CSV', incluida: false),
    ],
  ),
  Plan(
    tipo: PlanTipo.basico,
    nombre: 'Básico',
    descripcion: 'Para ganaderos activos',
    precioMensual: 149,
    bovinosMax: null,
    analisisMes: 999,
    historialDias: 180,
    features: [
      PlanFeature(emoji: '🐄', label: 'Hato ilimitado de bovinos', incluida: true),
      PlanFeature(emoji: '🔔', label: 'Alertas push automáticas', incluida: true),
      PlanFeature(emoji: '📊', label: 'Historial de 6 meses', incluida: true),
      PlanFeature(emoji: '📄', label: 'Reportes PDF / CSV', incluida: false),
    ],
  ),
  Plan(
    tipo: PlanTipo.pro,
    nombre: 'Pro',
    descripcion: 'Para ranchos en crecimiento',
    precioMensual: 349,
    bovinosMax: null,
    analisisMes: 999,
    historialDias: 365,
    popular: true,
    features: [
      PlanFeature(emoji: '✅', label: 'Todo lo del plan Básico', incluida: true),
      PlanFeature(emoji: '📄', label: 'Reportes PDF y CSV', incluida: true),
      PlanFeature(emoji: '🧠', label: 'NLP avanzado en texto libre', incluida: true),
      PlanFeature(emoji: '🩺', label: 'Dashboard veterinario', incluida: true),
    ],
  ),
  Plan(
    tipo: PlanTipo.cooperativa,
    nombre: 'Cooperativa',
    descripcion: 'Para múltiples usuarios',
    precioMensual: 1200,
    bovinosMax: null,
    analisisMes: 999,
    historialDias: 365,
    features: [
      PlanFeature(emoji: '👥', label: 'Hasta 20 usuarios', incluida: true),
      PlanFeature(emoji: '🗺️', label: 'Mapa de incidencia', incluida: true),
      PlanFeature(emoji: '👔', label: 'Supervisor regional incluido', incluida: true),
      PlanFeature(emoji: '🎯', label: 'Soporte prioritario', incluida: true),
    ],
  ),
];
