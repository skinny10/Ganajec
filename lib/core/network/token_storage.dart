import 'package:shared_preferences/shared_preferences.dart';

/// Almacena y recupera el token de acceso y datos de sesión del usuario.
/// Llama [TokenStorage.init()] una vez en main() antes de runApp().
class TokenStorage {
  TokenStorage._();

  static SharedPreferences? _prefs;

  static const _kToken = 'access_token';
  static const _kUserId = 'user_id';
  static const _kRanchoId = 'rancho_id';
  static const _kRole = 'user_role';

  // ── Inicialización ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Getters ───────────────────────────────────────────────────────────────────
  static String? get token => _prefs?.getString(_kToken);
  static String? get userId => _prefs?.getString(_kUserId);
  static String? get ranchoId => _prefs?.getString(_kRanchoId);
  static String? get role => _prefs?.getString(_kRole);

  static bool get isLoggedIn {
    final t = token;
    return t != null && t.isNotEmpty;
  }

  // ── Persistencia ──────────────────────────────────────────────────────────────
  static Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
  }) async {
    await Future.wait([
      _prefs!.setString(_kToken, token),
      _prefs!.setString(_kUserId, userId),
      _prefs!.setString(_kRole, role),
    ]);
  }

  /// Se guarda la primera vez que obtenemos bovinos con éxito.
  static Future<void> saveRanchoId(String ranchoId) async {
    await _prefs?.setString(_kRanchoId, ranchoId);
  }

  static Future<void> clear() async {
    await Future.wait([
      _prefs!.remove(_kToken),
      _prefs!.remove(_kUserId),
      _prefs!.remove(_kRanchoId),
      _prefs!.remove(_kRole),
    ]);
  }
}
