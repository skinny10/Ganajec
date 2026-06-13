import 'package:flutter/material.dart';
import 'package:ganajec/features/auth/domain/entities/user.dart';
import 'package:ganajec/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ganajec/share/domain/entities/rancho.dart';

// Configuración de notificaciones (en producción iría a SharedPreferences/API)
class NotificacionesConfig {
  final bool alertasPrediccion;
  final bool anomaliasProductivas;
  final bool resumenSemanal;

  const NotificacionesConfig({
    this.alertasPrediccion = true,
    this.anomaliasProductivas = true,
    this.resumenSemanal = false,
  });

  NotificacionesConfig copyWith({
    bool? alertasPrediccion,
    bool? anomaliasProductivas,
    bool? resumenSemanal,
  }) {
    return NotificacionesConfig(
      alertasPrediccion: alertasPrediccion ?? this.alertasPrediccion,
      anomaliasProductivas: anomaliasProductivas ?? this.anomaliasProductivas,
      resumenSemanal: resumenSemanal ?? this.resumenSemanal,
    );
  }
}

enum PerfilStatus { idle, loggingOut, loggedOut, error }

class PerfilViewModel extends ChangeNotifier {
  final LogoutUseCase _logoutUseCase;

  PerfilViewModel({required LogoutUseCase logoutUseCase})
      : _logoutUseCase = logoutUseCase;

  // ── Estado ────────────────────────────────────────────────────────────────
  PerfilStatus _status = PerfilStatus.idle;
  String? _error;
  NotificacionesConfig _notificaciones = const NotificacionesConfig();

  // Mock de usuario actual — cuando tengas sesión real, pasa el User desde login
  User get usuario => const User(
        id: 'g1',
        name: 'Juan Pérez',
        email: 'juan@ejemplo.com',
        role: 'ganadero',
      );

  // Mock de rancho — cuando tengas API, carga con GetRanchoUseCase
  Rancho get rancho => Rancho(
        id: 'r1',
        nombre: 'Rancho La Esmeralda',
        municipio: 'Tuxtla Gutiérrez',
        estado: 'Chiapas',
        duenoId: 'g1',
        creadoEn: DateTime(2023, 1, 15),
      );

  int get totalBovinos => 12;
  String get plan => 'Plan Gratuito';

  PerfilStatus get status => _status;
  String? get error => _error;
  bool get isLoggingOut => _status == PerfilStatus.loggingOut;
  NotificacionesConfig get notificaciones => _notificaciones;

  // ── Iniciales del avatar ──────────────────────────────────────────────────
  String get iniciales {
    final partes = usuario.name.trim().split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return usuario.name.substring(0, partes[0].length >= 2 ? 2 : 1).toUpperCase();
  }

  // ── Toggles ───────────────────────────────────────────────────────────────
  void toggleAlertasPrediccion() {
    _notificaciones = _notificaciones.copyWith(
      alertasPrediccion: !_notificaciones.alertasPrediccion,
    );
    notifyListeners();
  }

  void toggleAnomaliasProductivas() {
    _notificaciones = _notificaciones.copyWith(
      anomaliasProductivas: !_notificaciones.anomaliasProductivas,
    );
    notifyListeners();
  }

  void toggleResumenSemanal() {
    _notificaciones = _notificaciones.copyWith(
      resumenSemanal: !_notificaciones.resumenSemanal,
    );
    notifyListeners();
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<bool> cerrarSesion() async {
    _status = PerfilStatus.loggingOut;
    _error = null;
    notifyListeners();
    try {
      await _logoutUseCase();
      _status = PerfilStatus.loggedOut;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = PerfilStatus.error;
      notifyListeners();
      return false;
    }
  }
}
