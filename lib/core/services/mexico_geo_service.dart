import 'dart:convert';
import 'package:dio/dio.dart';

/// Carga estados y municipios de México desde GitHub (sin token, sin límite).
/// Formato esperado (marcovega/estados-municipios-json):
///   { "Estado": ["Mpio1", "Mpio2", ...], ... }
/// O formato lista:
///   [ { "nombre": "Estado", "municipios": [...] }, ... ]
class MexicoGeoService {
  static const _url =
      'https://raw.githubusercontent.com/marcovega/estados-municipios-json/master/estados.json';

  static Map<String, List<String>>? _cache;

  static Future<Map<String, List<String>>> cargar() async {
    if (_cache != null) return _cache!;

    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    // Forzar recepción como texto plano para evitar problemas con Content-Type
    final res = await dio.get<String>(
      _url,
      options: Options(responseType: ResponseType.plain),
    );

    final raw = res.data ?? '';
    if (raw.isEmpty) throw Exception('Respuesta vacía');

    final decoded = jsonDecode(raw);
    final result = _parsear(decoded);

    if (result.isEmpty) throw Exception('Sin datos');

    final sorted = Map.fromEntries(
      result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    _cache = sorted;
    return sorted;
  }

  static Map<String, List<String>> _parsear(dynamic decoded) {
    final result = <String, List<String>>{};

    if (decoded is Map) {
      decoded.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        }
      });
    } else if (decoded is List) {
      for (final item in decoded) {
        if (item is Map) {
          final nombre = (item['nombre'] ?? item['estado'] ?? item['name'] ?? '').toString();
          final mpios = item['municipios'] ?? item['cities'] ?? item['municipio'] ?? [];
          if (nombre.isNotEmpty && mpios is List) {
            result[nombre] = mpios.map((e) => e.toString()).toList();
          }
        }
      }
    }
    return result;
  }

  static void limpiarCache() => _cache = null;
}
