import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_alertas_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/marcar_alerta_leida_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/marcar_todas_alertas_leidas_usecase.dart';

enum AlertasStatus { idle, loading, loaded, error }

class AlertasGrupo {
  final String titulo;
  final List<Alerta> alertas;
  const AlertasGrupo({required this.titulo, required this.alertas});
}

class AlertasViewModel extends ChangeNotifier {
  final GetAlertasUseCase _getAlertas;
  final MarcarAlertaLeidaUseCase _marcarLeida;
  final MarcarTodasAlertasLeidasUseCase _marcarTodas;

  AlertasViewModel({
    required GetAlertasUseCase getAlertas,
    required MarcarAlertaLeidaUseCase marcarLeida,
    required MarcarTodasAlertasLeidasUseCase marcarTodas,
  })  : _getAlertas = getAlertas,
        _marcarLeida = marcarLeida,
        _marcarTodas = marcarTodas;

  // ── Estado ──────────────────────────────────────────────────────────────
  AlertasStatus _status = AlertasStatus.idle;
  List<Alerta> _alertas = [];
  String? _error;

  AlertasStatus get status => _status;
  bool get isLoading => _status == AlertasStatus.loading;
  String? get error => _error;

  int get unreadCount => _alertas.where((a) => !a.leida).length;

  // ── Grupos por fecha ─────────────────────────────────────────────────────
  List<AlertasGrupo> get grupos {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final hoy = _alertas
        .where((a) => _sameDay(a.fecha, today))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    final ayer = _alertas
        .where((a) => _sameDay(a.fecha, yesterday))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    final semana = _alertas
        .where((a) =>
            !_sameDay(a.fecha, today) &&
            !_sameDay(a.fecha, yesterday) &&
            a.fecha.isAfter(today.subtract(const Duration(days: 7))))
        .toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));

    return [
      if (hoy.isNotEmpty)
        AlertasGrupo(titulo: 'Hoy', alertas: hoy),
      if (ayer.isNotEmpty)
        AlertasGrupo(titulo: 'Ayer', alertas: ayer),
      if (semana.isNotEmpty)
        AlertasGrupo(titulo: 'Esta semana', alertas: semana),
    ];
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // ── Carga ────────────────────────────────────────────────────────────────
  Future<void> cargar() async {
    _status = AlertasStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _alertas = await _getAlertas();
      _status = AlertasStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = AlertasStatus.error;
    }
    notifyListeners();
  }

  // ── Marcar leída (optimistic) ─────────────────────────────────────────────
  Future<void> marcarLeida(String alertaId) async {
    final idx = _alertas.indexWhere((a) => a.id == alertaId);
    if (idx == -1 || _alertas[idx].leida) return;
    _alertas[idx] = _alertas[idx].copyWith(leida: true);
    notifyListeners();
    try {
      await _marcarLeida(alertaId);
    } catch (_) {
      // revert on error
      _alertas[idx] = _alertas[idx].copyWith(leida: false);
      notifyListeners();
    }
  }

  // ── Marcar todas leídas ───────────────────────────────────────────────────
  Future<void> marcarTodasLeidas() async {
    final prev = List<Alerta>.from(_alertas);
    _alertas = _alertas.map((a) => a.copyWith(leida: true)).toList();
    notifyListeners();
    try {
      await _marcarTodas();
    } catch (_) {
      _alertas = prev;
      notifyListeners();
    }
  }
}
