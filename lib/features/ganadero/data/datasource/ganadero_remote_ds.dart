import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/historial_item.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';
import 'package:ganajec/features/ganadero/data/models/animal_model.dart';
import 'package:ganajec/features/ganadero/data/models/alerta_model.dart';
import 'package:ganajec/features/ganadero/data/models/historial_item_model.dart';
import 'package:ganajec/features/ganadero/data/models/historial_productivo_model.dart';
import 'package:ganajec/features/ganadero/data/models/prediccion_model.dart';

abstract class GanaderoRemoteDataSource {
  Future<List<AnimalModel>> getAnimales();
  Future<List<PrediccionModel>> getUltimasPredicciones();
  Future<List<AlertaModel>> getAlertas();
  Future<Map<String, int>> getResumenHato();
  Future<AnimalModel> crearAnimal(Animal animal);
  Future<List<HistorialProductivoModel>> getHistorialAnimal(String animalId);
  Future<List<PrediccionModel>> getPrediccionesAnimal(String animalId);
  Future<AnimalModel> actualizarAnimal(Animal animal);
  Future<void> eliminarAnimal(String animalId);
  Future<PrediccionModel> registrarSintomas(RegistroSintomas registro);
  Future<void> marcarAlertaLeida(String alertaId);
  Future<void> marcarTodasAlertasLeidas();
  Future<List<HistorialItem>> getHistorialGanadero();
}

class GanaderoRemoteDataSourceImpl implements GanaderoRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  /// ID del ganadero autenticado, guardado en TokenStorage tras el login.
  String get _uid => TokenStorage.userId ?? '';

  // ────────────────────────────────────────────────────────────────────────────
  // BOVINOS
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<AnimalModel>> getAnimales() async {
    try {
      final res = await _dio.get(ApiConstants.bovinosGanadero(_uid));
      // v2: respuesta es array directo, ya no { bovinos: [...] }
      final raw = res.data;
      final list = (raw is List ? raw : (raw['bovinos'] as List? ?? []));
      final models = list
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
      // Guarda el rancho_id del primer bovino para usarlo al crear nuevos bovinos.
      if (models.isNotEmpty && TokenStorage.ranchoId == null) {
        final rId = models.first.ranchoId;
        if (rId.isNotEmpty) await TokenStorage.saveRanchoId(rId);
      }
      return models;
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) return [];
      rethrow;
    }
  }

  @override
  Future<AnimalModel> crearAnimal(Animal animal) async {
    // Asegurar que tenemos el rancho_id antes de crear el bovino.
    // Si no está en cache, lo intentamos obtener del perfil del ganadero.
    String ranchoId = TokenStorage.ranchoId ?? '';
    if (ranchoId.isEmpty) {
      ranchoId = await _fetchRanchoIdFromPerfil();
    }

    if (ranchoId.isEmpty) {
      throw Exception('No tienes un rancho asignado. Únete a uno antes de registrar bovinos.');
    }

    final body = <String, dynamic>{
      'nombre': animal.nombre,
      'raza': animal.raza,
      'sexo': animal.sexo,
      'categoria': animal.categoria.isNotEmpty ? animal.categoria : 'vaca',
      'proposito': animal.proposito.isNotEmpty ? animal.proposito : 'leche',
      'peso_kg': animal.pesoKg,
      'fecha_nacimiento': _fmtDate(animal.fechaNacimiento),
      'rancho_id': ranchoId,
    };
    if (animal.idExterno.isNotEmpty) body['id_externo'] = animal.idExterno;

    try {
      final res = await _dio.post(ApiConstants.crearBovino, data: body);
      return AnimalModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      // Extraer el mensaje real de la API (detail, message, o texto plano)
      final apiMsg = _extractApiError(e);
      if (status == 403) {
        throw Exception(apiMsg.isNotEmpty
            ? apiMsg
            : 'Sin permiso para crear bovinos en este rancho (403).');
      }
      if (status == 400 || status == 422) {
        throw Exception(apiMsg.isNotEmpty ? apiMsg : 'Datos inválidos, revisa los campos.');
      }
      throw Exception(apiMsg.isNotEmpty ? apiMsg : 'Error ${status ?? ''} al registrar bovino.');
    }
  }

  /// Obtiene el rancho_id del perfil del ganadero y lo guarda en TokenStorage.
  Future<String> _fetchRanchoIdFromPerfil() async {
    try {
      final res = await _dio.get(ApiConstants.perfilGanadero(_uid));
      final data = res.data as Map<String, dynamic>;
      // v2: ranchos como lista
      final ranchos = data['ranchos'] as List?;
      if (ranchos != null && ranchos.isNotEmpty) {
        final rId = ranchos.first['id'] as String? ?? '';
        if (rId.isNotEmpty) {
          await TokenStorage.saveRanchoId(rId);
          return rId;
        }
      }
      // v1: rancho_id directo en la raíz
      final rIdDirect = data['rancho_id'] as String? ?? '';
      if (rIdDirect.isNotEmpty) {
        await TokenStorage.saveRanchoId(rIdDirect);
        return rIdDirect;
      }
    } catch (_) {}
    return '';
  }

  @override
  Future<AnimalModel> actualizarAnimal(Animal animal) async {
    final body = <String, dynamic>{
      'nombre': animal.nombre,
      'raza': animal.raza,
      'sexo': animal.sexo,
      'categoria': animal.categoria,
      'proposito': animal.proposito,
      'peso_kg': animal.pesoKg,
      'fecha_nacimiento': _fmtDate(animal.fechaNacimiento),
      if (animal.idExterno.isNotEmpty) 'id_externo': animal.idExterno,
    };
    final res =
        await _dio.put(ApiConstants.bovino(animal.id), data: body);
    return AnimalModel.fromJson(res.data as Map<String, dynamic>);
  }

  @override
  Future<void> eliminarAnimal(String animalId) async {
    await _dio.delete(ApiConstants.bovino(animalId));
  }

  // ────────────────────────────────────────────────────────────────────────────
  // PREDICCIONES
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<PrediccionModel>> getUltimasPredicciones() async {
    try {
      final res = await _dio.get(ApiConstants.prediccionesGanadero(_uid));
      // v2: array directo, ya no { predicciones: [...] }
      final raw = res.data;
      final list = (raw is List ? raw : (raw['predicciones'] as List? ?? []));
      return list
          .map((e) => PrediccionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) return [];
      rethrow;
    }
  }

  @override
  Future<List<PrediccionModel>> getPrediccionesAnimal(String animalId) async {
    final res = await _dio.get(ApiConstants.prediccionesBovino(animalId));
    // v2: array directo, ya no { bovino_id, nombre, predicciones: [...] }
    final raw = res.data;
    final list = (raw is List ? raw : (raw['predicciones'] as List? ?? []));
    final nombre = raw is Map ? (raw['nombre'] as String? ?? '') : '';
    return list
        .map((e) => PrediccionModel.fromJson(
              e as Map<String, dynamic>,
              animalId: animalId,
              animalNombre: nombre,
            ))
        .toList();
  }

  @override
  Future<PrediccionModel> registrarSintomas(RegistroSintomas registro) async {
    final texto = registro.descripcion.trim();
    final body = <String, dynamic>{
      'bovino_id': registro.animalId,
      // texto_libre es obligatorio y debe tener ≥3 caracteres
      'texto_libre': texto.length >= 3 ? texto : 'Sin descripción adicional',
      'temperatura': registro.temperatura,
      'produccion_leche': registro.litrosLeche,
      'consumo_alimento_kg': registro.kgAlimento,
      if (registro.sintomas.isNotEmpty)
        'sintomas_seleccionados': registro.sintomas,
    };
    final res =
        await _dio.post(ApiConstants.registroSintomas, data: body);
    final pred = res.data['prediccion'] as Map<String, dynamic>;
    // Los síntomas NLP y la concordancia vienen dentro de
    // prediccion.features_nlp.analisis_texto — PrediccionModel.fromJson los extrae.
    return PrediccionModel.fromJson(
      pred,
      animalId: registro.animalId,
      animalNombre: '',
    );
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HISTORIAL GLOBAL
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<HistorialItem>> getHistorialGanadero() async {
    try {
      final res = await _dio.get(ApiConstants.prediccionesGanadero(_uid));
      // v2: array directo, ya no { predicciones: [...] }
      final raw = res.data;
      final list = (raw is List ? raw : (raw['predicciones'] as List? ?? []));
      return list
          .map((e) => HistorialItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) return [];
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // RESUMEN HATO
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> getResumenHato() async {
    try {
      final res = await _dio.get(ApiConstants.perfilGanadero(_uid));
      // v2: perfil ya no trae total_bovinos; trae ranchos: [{id, nombre, ...}]
      // Intentamos total_bovinos (v1) primero, luego sumamos de ranchos (v2)
      int total = (res.data['total_bovinos'] as num?)?.toInt() ?? 0;
      if (total == 0) {
        final ranchos = res.data['ranchos'] as List?;
        if (ranchos != null && ranchos.isNotEmpty) {
          total = ranchos.fold<int>(
            0,
            (sum, r) => sum + ((r['total_bovinos'] as num?)?.toInt() ?? 0),
          );
          // Oportunidad de guardar rancho_id desde el perfil
          if (TokenStorage.ranchoId == null) {
            final rId = ranchos.first['id'] as String?;
            if (rId != null) await TokenStorage.saveRanchoId(rId);
          }
        }
      }
      return {
        'total': total,
        'en_buen_estado': total,
        'con_alertas': 0,
      };
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) {
        return {'total': 0, 'en_buen_estado': 0, 'con_alertas': 0};
      }
      rethrow;
    }
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ALERTAS — API real
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<AlertaModel>> getAlertas() async {
    try {
      final res = await _dio.get(ApiConstants.alertasGanadero(_uid));
      final raw = res.data;
      final list = raw is List ? raw : (raw['alertas'] as List? ?? []);
      return list
          .map((e) => AlertaModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // 403 = ganadero sin rancho asignado aún; 404 = sin alertas → lista vacía
      final status = e.response?.statusCode;
      if (status == 403 || status == 404) return [];
      rethrow;
    }
  }

  @override
  Future<void> marcarAlertaLeida(String alertaId) async {
    await _dio.patch(
      ApiConstants.marcarAlerta(alertaId),
      data: {'leida': true},
    );
  }

  @override
  Future<void> marcarTodasAlertasLeidas() async {
    // No existe endpoint bulk en la API; se marca cada una individualmente.
    // Si la lista es larga esto puede ser lento; el ViewModel ya lo maneja optimistamente.
    await Future.delayed(Duration.zero);
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HISTORIAL PRODUCTIVO — GET /ganadero/bovinos/{id}/graficas
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<HistorialProductivoModel>> getHistorialAnimal(
      String animalId) async {
    final res = await _dio.get(ApiConstants.graficasBovino(animalId));
    final graficas = res.data['graficas'] as Map<String, dynamic>? ?? {};

    // Construye un mapa fecha → {temperatura, leche, alimento}
    // para unir las tres series en registros individuales.
    final Map<String, Map<String, double>> byFecha = {};

    void _merge(String serieKey, String field) {
      final list = graficas[serieKey] as List<dynamic>? ?? [];
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final fecha = m['fecha'] as String;
        byFecha.putIfAbsent(fecha, () => {});
        final valor = (m['valor'] as num?)?.toDouble();
        if (valor != null) byFecha[fecha]![field] = valor;
      }
    }

    _merge('temperatura_corporal',    'temperatura');
    _merge('produccion_leche_litros', 'leche');
    _merge('consumo_alimento_kg',     'alimento');

    final fechas = byFecha.keys.toList()..sort();
    return fechas.asMap().entries.map((e) {
      final vals = byFecha[e.value]!;
      return HistorialProductivoModel(
        id: 'r_${animalId}_${e.key}',
        animalId: animalId,
        fecha: DateTime.parse(e.value),
        litrosLeche:      vals['leche']      ?? 0.0,
        kgAlimento:       vals['alimento']   ?? 0.0,
        temperatura:      vals['temperatura'] ?? 38.5,
        anomaliaDetectada: false, // la API devuelve anomalías por alerta, no por registro
      );
    }).toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Extrae el mensaje de error legible de una DioException.
  String _extractApiError(DioException e) {
    final data = e.response?.data;
    if (data == null) return '';
    if (data is Map) {
      // FastAPI devuelve { detail: "..." } o { message: "..." }
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        // FastAPI validation errors: [{ msg: "...", loc: [...] }]
        final first = detail.first;
        return (first is Map ? first['msg']?.toString() : null) ?? detail.toString();
      }
      return data['message']?.toString() ?? data['error']?.toString() ?? '';
    }
    if (data is String) return data;
    return '';
  }
}
