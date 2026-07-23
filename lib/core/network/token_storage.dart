import 'package:shared_preferences/shared_preferences.dart';

/// Almacena y recupera el token de acceso y datos de sesión del usuario.
/// Llama [TokenStorage.init()] una vez en main() antes de runApp().
class TokenStorage {
  TokenStorage._();

  static SharedPreferences? _prefs;

  static const _kToken        = 'access_token';
  static const _kUserId       = 'user_id';
  static const _kRanchoId     = 'rancho_id';
  static const _kRanchoNombre = 'rancho_nombre';
  static const _kRanchoMun    = 'rancho_municipio';
  static const _kRanchoEst    = 'rancho_estado';
  static const _kRole         = 'user_role';
  static const _kName         = 'user_name';
  static const _kEmail        = 'user_email';
  static const _kNotifBienvenida = 'notif_bienvenida_v2';

  // ── Inicialización ────────────────────────────────────────────────────────────
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Getters ───────────────────────────────────────────────────────────────────
  static String? get token        => _prefs?.getString(_kToken);
  static String? get userId       => _prefs?.getString(_kUserId);
  static String? get ranchoId     => _prefs?.getString(_kRanchoId);
  static String? get ranchoNombre => _prefs?.getString(_kRanchoNombre);
  static String? get ranchoMunicipio => _prefs?.getString(_kRanchoMun);
  static String? get ranchoEstado => _prefs?.getString(_kRanchoEst);
  static String? get role         => _prefs?.getString(_kRole);
  static String? get userName     => _prefs?.getString(_kName);
  static String? get email        => _prefs?.getString(_kEmail);
  static bool get notifBienvenida => _prefs?.getBool(_kNotifBienvenida) ?? false;

  static Future<void> setNotifBienvenida(bool value) async {
    await _prefs?.setBool(_kNotifBienvenida, value);
  }

  static bool get isLoggedIn {
    final t = token;
    return t != null && t.isNotEmpty;
  }

  // ── Persistencia ──────────────────────────────────────────────────────────────
  static Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveSession({
    required String token,
    required String userId,
    required String role,
    String? name,
    String? email,
  }) async {
    await _ensurePrefs();
    await Future.wait([
      _prefs!.setString(_kToken, token),
      _prefs!.setString(_kUserId, userId),
      _prefs!.setString(_kRole, role),
      if (name != null) _prefs!.setString(_kName, name),
      if (email != null) _prefs!.setString(_kEmail, email),
    ]);
  }

  /// Guarda el id del rancho (usado al unirse o al cargar bovinos por primera vez).
  static Future<void> saveRanchoId(String ranchoId) async {
    await _prefs?.setString(_kRanchoId, ranchoId);
  }

  /// Guarda los detalles del rancho tras unirse o crearlos.
  static Future<void> saveRanchoInfo({
    required String id,
    String? nombre,
    String? municipio,
    String? estado,
  }) async {
    final ops = <Future>[
      if (id.isNotEmpty) _prefs!.setString(_kRanchoId, id),
      if (nombre != null && nombre.isNotEmpty)
        _prefs!.setString(_kRanchoNombre, nombre),
      if (municipio != null && municipio.isNotEmpty)
        _prefs!.setString(_kRanchoMun, municipio),
      if (estado != null && estado.isNotEmpty)
        _prefs!.setString(_kRanchoEst, estado),
    ];
    if (ops.isNotEmpty) await Future.wait(ops);
  }

  static Future<void> clear() async {
    await Future.wait([
      _prefs!.remove(_kToken),
      _prefs!.remove(_kUserId),
      _prefs!.remove(_kRanchoId),
      _prefs!.remove(_kRanchoNombre),
      _prefs!.remove(_kRanchoMun),
      _prefs!.remove(_kRanchoEst),
      _prefs!.remove(_kRole),
      _prefs!.remove(_kName),
      _prefs!.remove(_kEmail),
      _prefs!.remove(_kNotifBienvenida),
    ]);
  }
}
