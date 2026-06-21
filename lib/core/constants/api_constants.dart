/// Centraliza la URL base y todos los paths de la API GANAJEC AI.
///
/// Dev local  → http://192.168.1.17:8000/api  (tu IP LAN, para emulador/físico)
/// Emulador   → http://localhost:8000/api      (alias de localhost en AVD)
/// Producción → http://44.193.46.236:8000/api
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'http://localhost:8000/api';

  // ── Autenticación ────────────────────────────────────────────────────────────
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  /// POST /auth/change-password  { password_actual, nueva_password }
  static const String cambiarContrasena = '/auth/change-password';

  // ── Ganadero — perfil ────────────────────────────────────────────────────────
  /// GET /ganadero/{ganadero_id}
  static String perfilGanadero(String id) => '/ganadero/$id';

  // ── Dueño — perfil ───────────────────────────────────────────────────────────
  /// GET /dueno/{dueno_id}  — devuelve { id, nombre, email, rol, ranchos: [...] }
  static String perfilDueno(String id) => '/dueno/$id';

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

  // ── Ganadero — unirse a rancho ───────────────────────────────────────────────
  /// POST /ganadero/unirse-rancho  { codigo_invitacion: "XXXXXXXX" }
  static const String unirseRancho = '/ganadero/unirse-rancho';

  // ── Ganadero — alertas ───────────────────────────────────────────────────────
  /// GET /ganadero/{ganadero_id}/alertas
  static String alertasGanadero(String ganaderoId) =>
      '/ganadero/$ganaderoId/alertas';

  /// PATCH /ganadero/alertas/{alerta_id}
  static String marcarAlerta(String alertaId) =>
      '/ganadero/alertas/$alertaId';

  // ── Ganadero — editar perfil ─────────────────────────────────────────────────
  /// PATCH /ganadero/{ganadero_id}  { nombre?, email? }
  static String actualizarPerfilGanadero(String id) => '/ganadero/$id';

  // ── Rancho — crear ───────────────────────────────────────────────────────────
  /// POST /dueno/ranchos  { nombre, municipio, estado }
  static const String crearRancho = '/dueno/ranchos';

  /// GET /dueno/{dueno_id}  (los ranchos vienen dentro del objeto en el campo "ranchos")
  static String ranchosDueno(String duenoId) => '/dueno/$duenoId';

  // ── Rancho — ganaderos ───────────────────────────────────────────────────────
  /// GET /dueno/ranchos/{rancho_id}/ganaderos
  static String ganaderosDeRancho(String ranchoId) =>
      '/dueno/ranchos/$ranchoId/ganaderos';

  /// DELETE /dueno/ranchos/{rancho_id}/ganaderos/{ganadero_id}
  static String ganaderoEnRancho(String ranchoId, String ganaderoId) =>
      '/dueno/ranchos/$ranchoId/ganaderos/$ganaderoId';

  // ── Dueño — ranchos (dashboard y edición) ───────────────────────────────────
  /// GET /dueno/ranchos/{rancho_id}   (detalle del rancho + info)
  /// PUT /dueno/ranchos/{rancho_id}   (actualizar nombre/municipio/estado)
  static String ranchoDetalle(String ranchoId) => '/dueno/ranchos/$ranchoId';

  /// GET /dueno/ranchos/{rancho_id}/bovinos
  static String bovinosDeRancho(String ranchoId) =>
      '/dueno/ranchos/$ranchoId/bovinos';

  // ── Dueño — ganaderos (crear / actualizar) ───────────────────────────────────
  /// POST /dueno/ganaderos   { nombre, email }
  static const String crearGanadero = '/dueno/ganaderos';

  /// PUT /dueno/ganaderos/{ganadero_id}
  static String ganaderoDetalle(String ganaderoId) =>
      '/dueno/ganaderos/$ganaderoId';

  // ── Dueño — suscripción ──────────────────────────────────────────────────────
  /// GET /dueno/{dueno_id}/suscripcion
  static String suscripcionDueno(String duenoId) =>
      '/dueno/$duenoId/suscripcion';

  /// POST /dueno/suscripcion   { plan, es_anual }
  static const String suscribirse = '/dueno/suscripcion';

  // ── Dueño — estadísticas ─────────────────────────────────────────────────────
  /// GET /dueno/ranchos/{rancho_id}/estadisticas
  static String estadisticasRancho(String ranchoId) =>
      '/dueno/ranchos/$ranchoId/estadisticas';
}
