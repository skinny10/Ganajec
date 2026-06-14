import 'package:flutter/material.dart';
import 'package:ganajec/core/network/token_storage.dart';
import '../../domain/entities/dueno_dashboard.dart';
import '../../domain/usecases/get_dashboard_dueno_usecase.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  final GetDashboardDuenoUsecase getDashboardUsecase;

  DashboardViewModel({required this.getDashboardUsecase});

  DashboardState _state = DashboardState.initial;
  DuenoDashboard? _dashboard;
  String? _errorMessage;

  DashboardState get state => _state;
  DuenoDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  Future<void> cargarDashboard() async {
    final duenoId = TokenStorage.userId;
    debugPrint('📦 [DashboardViewModel] duenoId desde TokenStorage: $duenoId');

    if (duenoId == null || duenoId.isEmpty) {
      final causa = duenoId == null
          ? 'TokenStorage.userId retornó null — ¿SharedPreferences inicializado?'
          : 'TokenStorage.userId retornó cadena vacía — ¿sesión no guardada?';
      debugPrint('❌ [DashboardViewModel] $causa');
      _errorMessage = 'Usuario no identificado. $causa';
      _state = DashboardState.error;
      notifyListeners();
      return;
    }

    _state = DashboardState.loading;
    notifyListeners();

    try {
      _dashboard = await getDashboardUsecase(duenoId);
      _state = DashboardState.loaded;
    } catch (e) {
      debugPrint('❌ [DashboardViewModel] Error al cargar dashboard: $e');
      _errorMessage = e.toString();
      _state = DashboardState.error;
    }

    notifyListeners();
  }
}
