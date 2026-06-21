import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/auth/domain/entities/user.dart';
import 'package:ganajec/features/auth/domain/usecase/logout_usecase.dart';
import 'package:ganajec/share/domain/entities/rancho.dart';

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
  }) =>
      NotificacionesConfig(
        alertasPrediccion: alertasPrediccion ?? this.alertasPrediccion,
        anomaliasProductivas: anomaliasProductivas ?? this.anomaliasProductivas,
        resumenSemanal: resumenSemanal ?? this.resumenSemanal,
      );
}

enum PerfilStatus { idle, loading, success, loggingOut, loggedOut, error }

class PerfilViewModel extends ChangeNotifier {
  final LogoutUseCase _logoutUseCase;
  final Dio _dio = ApiClient.instance;

  PerfilViewModel({required LogoutUseCase logoutUseCase})
      : _logoutUseCase = logoutUseCase;

  // ── Estado ────────────────────────────────────────────────────────────────
  PerfilStatus _status = PerfilStatus.idle;
  String? _error;
  NotificacionesConfig _notificaciones = const NotificacionesConfig();

  // ── Datos cargados desde TokenStorage + API ───────────────────────────────
  String _nombre = '';
  String _email = '';
  String _ranchoNombre = '—';
  String _ranchoMunicipio = '—';
  String _ranchoEstado = '—';
  String _ranchoId = '';
  String _duenoNombre = '';
  String _duenoId = '';
  int _totalBovinos = 0;

  // ── Getters con la misma API que antes (la screen no cambia) ──────────────
  User get usuario => User(
        id: TokenStorage.userId ?? '',
        name: _nombre.isNotEmpty ? _nombre : (TokenStorage.userName ?? 'Usuario'),
        email: _email.isNotEmpty ? _email : (TokenStorage.email ?? '—'),
        role: TokenStorage.role ?? 'ganadero',
      );

  Rancho get rancho => Rancho(
        id: _ranchoId,
        nombre: _ranchoNombre,
        municipio: _ranchoMunicipio,
        estado: _ranchoEstado,
        duenoId: _duenoId,
        duenoNombre: _duenoNombre,
        creadoEn: DateTime.now(),
      );

  int get totalBovinos => _totalBovinos;
  String get plan => 'Plan Gratuito';

  /// true si el ganadero ya pertenece a un rancho
  bool get tieneRancho => _ranchoId.isNotEmpty || TokenStorage.ranchoId != null;

  PerfilStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == PerfilStatus.loading;
  bool get isLoggingOut => _status == PerfilStatus.loggingOut;
  NotificacionesConfig get notificaciones => _notificaciones;

  // ── Iniciales del avatar ──────────────────────────────────────────────────
  String get iniciales {
    final name = usuario.name;
    final partes = name.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ── Cargar perfil desde la API ────────────────────────────────────────────
  Future<void> cargarPerfil() async {
    _status = PerfilStatus.loading;
    _error = null;
    notifyListeners();

    // Datos del usuario desde TokenStorage (ya disponibles desde el login)
    _nombre = TokenStorage.userName ?? '';
    _email = TokenStorage.email ?? '';

    try {
      final uid = TokenStorage.userId ?? '';
      final role = TokenStorage.role ?? 'ganadero';
      final endpoint = role == 'dueno'
          ? ApiConstants.perfilDueno(uid)
          : ApiConstants.perfilGanadero(uid);
      final res = await _dio.get(endpoint);
      final data = res.data as Map<String, dynamic>;

      // Si la API devuelve nombre/email más actualizado, los usamos
      final apiNombre = data['nombre'] as String?;
      final apiEmail = data['email'] as String?;
      if (apiNombre != null && apiNombre.isNotEmpty) _nombre = apiNombre;
      if (apiEmail != null && apiEmail.isNotEmpty) _email = apiEmail;

      // ── Rancho ──────────────────────────────────────────────────────────────
      // El endpoint del ganadero puede devolver el rancho de varias formas:
      //   v2: { ranchos: [{id, nombre, municipio, estado, dueno_id, ...}] }
      //   v1: { rancho_id: "...", rancho: {nombre, municipio, estado} }
      //   v0: solo { rancho_id: "..." } en la raíz
      // Como último recurso, usamos TokenStorage (persistido al unirse).

      final ranchos = data['ranchos'] as List?;
      if (ranchos != null && ranchos.isNotEmpty) {
        // ── Formato v2 (array) ───────────────────────────────────────────────
        final r = ranchos.first as Map<String, dynamic>;
        _ranchoId        = r['id']         as String? ?? '';
        _ranchoNombre    = r['nombre']     as String? ?? '—';
        _ranchoMunicipio = r['municipio']  as String? ?? '—';
        _ranchoEstado    = r['estado']     as String? ?? '—';
        _duenoId         = r['dueno_id']   as String? ?? '';
        _duenoNombre     = r['dueno_nombre']  as String?
                         ?? r['nombre_dueno'] as String?
                         ?? '';

        // Persistir para futuras sesiones
        await TokenStorage.saveRanchoInfo(
          id: _ranchoId,
          nombre: _ranchoNombre == '—' ? null : _ranchoNombre,
          municipio: _ranchoMunicipio == '—' ? null : _ranchoMunicipio,
          estado: _ranchoEstado == '—' ? null : _ranchoEstado,
        );

        _totalBovinos = ranchos.fold<int>(
          0,
          (sum, r) => sum + ((r['total_bovinos'] as num?)?.toInt() ?? 0),
        );
      } else {
        // ── Formatos v0/v1: rancho_id en raíz o objeto rancho ───────────────
        final inlineRancho = data['rancho'] as Map<String, dynamic>?;
        final rIdFromRoot  = data['rancho_id'] as String?
                           ?? inlineRancho?['id'] as String?
                           ?? '';

        if (rIdFromRoot.isNotEmpty || inlineRancho != null) {
          _ranchoId        = rIdFromRoot.isNotEmpty ? rIdFromRoot
                           : inlineRancho?['id'] as String?
                           ?? TokenStorage.ranchoId ?? '';
          _ranchoNombre    = inlineRancho?['nombre']    as String?
                           ?? TokenStorage.ranchoNombre ?? '—';
          _ranchoMunicipio = inlineRancho?['municipio'] as String?
                           ?? TokenStorage.ranchoMunicipio ?? '—';
          _ranchoEstado    = inlineRancho?['estado']    as String?
                           ?? TokenStorage.ranchoEstado ?? '—';
          _duenoId         = inlineRancho?['dueno_id']  as String? ?? '';
          _duenoNombre     = inlineRancho?['dueno_nombre'] as String?
                           ?? inlineRancho?['nombre_dueno'] as String?
                           ?? '';
          // Persistir detalles para próximas sesiones
          await TokenStorage.saveRanchoInfo(
            id: _ranchoId,
            nombre: _ranchoNombre == '—' ? null : _ranchoNombre,
            municipio: _ranchoMunicipio == '—' ? null : _ranchoMunicipio,
            estado: _ranchoEstado == '—' ? null : _ranchoEstado,
          );
        } else if (TokenStorage.ranchoId != null) {
          // ── v0 sin datos inline: usar lo que guardamos al unirse ──────────
          _ranchoId        = TokenStorage.ranchoId!;
          _ranchoNombre    = TokenStorage.ranchoNombre    ?? '—';
          _ranchoMunicipio = TokenStorage.ranchoMunicipio ?? '—';
          _ranchoEstado    = TokenStorage.ranchoEstado    ?? '—';
        }

        // Total bovinos en raíz (v1)
        _totalBovinos = (data['total_bovinos'] as num?)?.toInt() ?? 0;
      }

      // Si no vino nombre del dueño, intentar fetch silencioso
      if (_duenoNombre.isEmpty && _duenoId.isNotEmpty) {
        try {
          final duenoRes = await _dio.get(ApiConstants.perfilDueno(_duenoId));
          final dNombre = duenoRes.data['nombre'] as String?;
          if (dNombre != null && dNombre.isNotEmpty) _duenoNombre = dNombre;
        } catch (_) {}
      }

      _status = PerfilStatus.success;
    } catch (e) {
      // Si la API falla, al menos mostramos datos de TokenStorage
      _error = e.toString();
      _status = PerfilStatus.error;
    }
    notifyListeners();
  }

  // ── Toggles de notificaciones ─────────────────────────────────────────────
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
