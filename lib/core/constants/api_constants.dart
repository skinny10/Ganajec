/// Centraliza la URL base y todos los paths de la API GANAJEC AI.
/// Base URL: http://44.193.46.236:8000/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://44.193.46.236:8000/api';

  // ── Autenticación ────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';

  // ── Ganadero — perfil ────────────────────────────────────────────────────────
  /// GET /ganadero/{ganadero_id}
  static String perfilGanadero(String id) => '/ganadero/$id';

  // ── Ganadero — bovinos ───────────────────────────────────────────────────────
  /// GET /ganadero/{ganadero_id}/bovinos
  static String bovinosGanadero(String ganaderoId) =>
      '/ganadero/$ganaderoId/bovinos';

  /// POST /ganadero/bovinos
  static const String crearBovino = '/ganadero/bovinos';

  /// GET /ganadero/bovinos/{bovino_id}
  /// PUT /ganadero/bovinos/{bovino_id}
  /// DELETE /ganadero/bovinos/{bovino_id}
  static String bovino(String bovinoId) => '/ganadero/bovinos/$bovinoId';

  // ── Ganadero — predicciones ──────────────────────────────────────────────────
  /// GET /ganadero/bovinos/{bovino_id}/predicciones
  static String prediccionesBovino(String bovinoId) =>
      '/ganadero/bovinos/$bovinoId/predicciones';

  /// GET /ganadero/{ganadero_id}/predicciones  (historial global)
  static String prediccionesGanadero(String ganaderoId) =>
      '/ganadero/$ganaderoId/predicciones';

  // ── Ganadero — síntomas ──────────────────────────────────────────────────────
  /// POST /ganadero/registros-sintomas
  static const String registroSintomas = '/ganadero/registros-sintomas';

  // ── Ganadero — alertas ───────────────────────────────────────────────────────
  /// GET /ganadero/{ganadero_id}/alertas
  static String alertasGanadero(String ganaderoId) =>
      '/ganadero/$ganaderoId/alertas';

  /// PATCH /ganadero/alertas/{alerta_id}
  static String marcarAlerta(String alertaId) =>
      '/ganadero/alertas/$alertaId';

  // ── Dueño — suscripción ──────────────────────────────────────────────────────
  /// GET /dueno/{dueno_id}/suscripcion
  static String suscripcionDueno(String duenoId) =>
      '/dueno/$duenoId/suscripcion';
}
