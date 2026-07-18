import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';
import 'package:ganajec/features/ganadero/domain/usecase/registrar_sintomas_usecase.dart';



class SintomaItem {
  final String emoji;
  final String label;
  const SintomaItem(this.emoji, this.label);
}

const kSintomas = [
  SintomaItem('🍽️', 'No come'),
  SintomaItem('😴', 'Decaída'),
  SintomaItem('🦵', 'Cojea'),
  SintomaItem('👁️', 'Ojos llorosos'),
  SintomaItem('💧', 'Secreción nasal'),
  SintomaItem('🧍', 'Aislada'),
  SintomaItem('🫁', 'Dificultad respirar'),
  SintomaItem('🔥', 'Fiebre visible'),
  SintomaItem('💩', 'Diarrea'),
  SintomaItem('🐄', 'Ubre inflamada'),
  SintomaItem('⚖️', 'Pérdida de peso'),
  SintomaItem('🌡️', 'Temblores'),
];

// ─── Severidad estimada ───────────────────────────────────────────────────────

enum SeveridadEstimada { leve, moderada, alta }

extension SeveridadExt on SeveridadEstimada {
  String get titulo {
    switch (this) {
      case SeveridadEstimada.leve:     return 'Severidad leve';
      case SeveridadEstimada.moderada: return 'Severidad moderada';
      case SeveridadEstimada.alta:     return 'Severidad alta';
    }
  }

  String get descripcion {
    switch (this) {
      case SeveridadEstimada.leve:
        return 'Pocos síntomas detectados. Continúa observando al animal durante el día.';
      case SeveridadEstimada.moderada:
        return 'Síntomas presentes. Monitorea de cerca y consulta al veterinario si empeora.';
      case SeveridadEstimada.alta:
        return 'Múltiples síntomas + fiebre + producción muy baja. Se recomienda acción inmediata.';
    }
  }

  String get emoji {
    switch (this) {
      case SeveridadEstimada.leve:     return '🟢';
      case SeveridadEstimada.moderada: return '🟡';
      case SeveridadEstimada.alta:     return '🔴';
    }
  }

  /// Color de fondo según el ColorScheme del tema.
  Color bgColor(ColorScheme cs) {
    switch (this) {
      case SeveridadEstimada.leve:     return cs.tertiaryContainer;
      case SeveridadEstimada.moderada: return cs.secondaryContainer;
      case SeveridadEstimada.alta:     return cs.errorContainer;
    }
  }

  /// Color de borde según el ColorScheme del tema.
  Color borderColor(ColorScheme cs) {
    switch (this) {
      case SeveridadEstimada.leve:     return cs.tertiary.withOpacity(0.3);
      case SeveridadEstimada.moderada: return cs.secondary.withOpacity(0.3);
      case SeveridadEstimada.alta:     return cs.error.withOpacity(0.3);
    }
  }
}

// ─── Badge de temperatura ─────────────────────────────────────────────────────

enum TempBadge { hipotermia, normal, subfebril, fiebre }

extension TempBadgeExt on TempBadge {
  String get label {
    switch (this) {
      case TempBadge.hipotermia: return 'Hipotermia';
      case TempBadge.normal:     return 'Normal';
      case TempBadge.subfebril:  return 'Subfebril';
      case TempBadge.fiebre:     return 'Fiebre';
    }
  }

  /// Color de texto según el ColorScheme del tema.
  Color color(ColorScheme cs) {
    switch (this) {
      case TempBadge.hipotermia: return cs.secondary;
      case TempBadge.normal:     return cs.tertiary;
      case TempBadge.subfebril:  return cs.secondary;
      case TempBadge.fiebre:     return cs.error;
    }
  }

  /// Color de fondo según el ColorScheme del tema.
  Color bg(ColorScheme cs) {
    switch (this) {
      case TempBadge.hipotermia: return cs.secondaryContainer;
      case TempBadge.normal:     return cs.tertiaryContainer;
      case TempBadge.subfebril:  return cs.secondaryContainer;
      case TempBadge.fiebre:     return cs.errorContainer;
    }
  }
}

TempBadge tempBadgeFor(double temp) {
  if (temp < 38.0) return TempBadge.hipotermia;
  if (temp <= 39.0) return TempBadge.normal;
  if (temp <= 40.0) return TempBadge.subfebril;
  return TempBadge.fiebre;
}

// ─── Status ───────────────────────────────────────────────────────────────────

enum RegistrarSintomasStatus { idle, analyzing, done, error }

// ─── ViewModel ───────────────────────────────────────────────────────────────

class RegistrarSintomasViewModel extends ChangeNotifier {
  final Animal animal;
  final RegistrarSintomasUseCase _registrarSintomas;

  RegistrarSintomasViewModel({
    required this.animal,
    required RegistrarSintomasUseCase registrarSintomas,
  }) : _registrarSintomas = registrarSintomas;

  // ── Estado del formulario ─────────────────────────────────────────────────
  final Set<String> _seleccionados = {};
  double _leche = 10.0;
  double _alimento = 8.0;
  double _temperatura = 38.5;
  String _descripcion = '';

  // ── Estado de la operación ────────────────────────────────────────────────
  RegistrarSintomasStatus _status = RegistrarSintomasStatus.idle;
  Prediccion? _resultado;
  String? _error;

  // ── Getters ───────────────────────────────────────────────────────────────
  Set<String> get seleccionados => Set.unmodifiable(_seleccionados);
  double get leche => _leche;
  double get alimento => _alimento;
  double get temperatura => _temperatura;
  String get descripcion => _descripcion;

  RegistrarSintomasStatus get status => _status;
  Prediccion? get resultado => _resultado;
  String? get error => _error;
  bool get isAnalyzing => _status == RegistrarSintomasStatus.analyzing;

  TempBadge get tempBadge => tempBadgeFor(_temperatura);

  SeveridadEstimada get severidad {
    final sinCount = _seleccionados.length;
    int score = 0;
    score += sinCount >= 4 ? 3 : sinCount >= 2 ? 2 : sinCount >= 1 ? 1 : 0;
    score += _temperatura > 40 ? 3 : _temperatura > 39 ? 1 : 0;
    score += _leche <= 5 ? 2 : _leche <= 10 ? 1 : 0;
    score += _descripcion.length > 20 ? 1 : 0;
    if (score >= 6) return SeveridadEstimada.alta;
    if (score >= 3) return SeveridadEstimada.moderada;
    return SeveridadEstimada.leve;
  }

  // ── Mutaciones ────────────────────────────────────────────────────────────
  void toggleSintoma(String label) {
    if (_seleccionados.contains(label)) {
      _seleccionados.remove(label);
    } else {
      _seleccionados.add(label);
    }
    notifyListeners();
  }

  void setLeche(double v) {
    _leche = v.clamp(0, 50);
    notifyListeners();
  }

  void incrementLeche(int delta) => setLeche(_leche + delta);

  void setAlimento(double v) {
    _alimento = v.clamp(0, 30);
    notifyListeners();
  }

  void incrementAlimento(int delta) => setAlimento(_alimento + delta);

  void setTemperatura(double v) {
    _temperatura = double.parse(v.toStringAsFixed(1));
    notifyListeners();
  }

  void setDescripcion(String v) {
    _descripcion = v;
    notifyListeners();
  }

  // ── Analizar ──────────────────────────────────────────────────────────────
  Future<bool> analizarConIA() async {
    _status = RegistrarSintomasStatus.analyzing;
    _error = null;
    notifyListeners();

    try {
      final registro = RegistroSintomas(
        animalId: animal.id,
        fecha: DateTime.now(),
        sintomas: _seleccionados.toList(),
        litrosLeche: _leche,
        kgAlimento: _alimento,
        temperatura: _temperatura,
        descripcion: _descripcion,
      );
      _resultado = await _registrarSintomas(registro);
      _status = RegistrarSintomasStatus.done;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = RegistrarSintomasStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetStatus() {
    _status = RegistrarSintomasStatus.idle;
    _resultado = null;
    _error = null;
    notifyListeners();
  }
}
