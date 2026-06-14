import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/share/domain/entities/alerta.dart';
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
    final res = await _dio.get(ApiConstants.bovinosGanadero(_uid));
    final list = res.data['bovinos'] as List;
    final models = list
        .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
        .toList();
    // Guarda el rancho_id del primer bovino para usarlo al crear nuevos bovinos.
    if (models.isNotEmpty && TokenStorage.ranchoId == null) {
      await TokenStorage.saveRanchoId(models.first.ranchoId);
    }
    return models;
  }

  @override
  Future<AnimalModel> crearAnimal(Animal animal) async {
    final ranchoId = TokenStorage.ranchoId ?? '';
    final body = <String, dynamic>{
      'nombre': animal.nombre,
      'raza': animal.raza,
      'sexo': animal.sexo,
      'categoria': animal.categoria.isNotEmpty ? animal.categoria : 'vaca',
      'proposito': animal.proposito.isNotEmpty ? animal.proposito : 'leche',
      'peso_kg': animal.pesoKg,
      'fecha_nacimiento': _fmtDate(animal.fechaNacimiento),
    };
    if (ranchoId.isNotEmpty) body['rancho_id'] = ranchoId;
    if (animal.idExterno.isNotEmpty) body['id_externo'] = animal.idExterno;

    final res = await _dio.post(ApiConstants.crearBovino, data: body);
    return AnimalModel.fromJson(res.data as Map<String, dynamic>);
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
    final res =
        await _dio.get(ApiConstants.prediccionesGanadero(_uid));
    final list = res.data['predicciones'] as List;
    return list
        .map((e) => PrediccionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<PrediccionModel>> getPrediccionesAnimal(String animalId) async {
    final res =
        await _dio.get(ApiConstants.prediccionesBovino(animalId));
    final list = res.data['predicciones'] as List;
    final nombre = res.data['nombre'] as String? ?? '';
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
    final res =
        await _dio.get(ApiConstants.prediccionesGanadero(_uid));
    final list = res.data['predicciones'] as List;
    return list
        .map((e) =>
            HistorialItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ────────────────────────────────────────────────────────────────────────────
  // RESUMEN HATO
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<Map<String, int>> getResumenHato() async {
    final res = await _dio.get(ApiConstants.perfilGanadero(_uid));
    final total = (res.data['total_bovinos'] as num? ?? 0).toInt();
    // La API no devuelve el desglose; se deduce del total.
    return {
      'total': total,
      'en_buen_estado': total,
      'con_alertas': 0,
    };
  }

  // ────────────────────────────────────────────────────────────────────────────
  // ALERTAS — MOCK (el usuario ajustará los campos tipo/mensaje al integrar)
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<AlertaModel>> getAlertas() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    return [
      AlertaModel(
        id: 'a1',
        tipo: AlertaTipo.isolationForest,
        severidad: AlertaSeveridad.alta,
        titulo: 'Caída anómala detectada en Lupita',
        descripcion:
            'La producción bajó de 18 L a 5 L en 3 días — patrón estadísticamente anormal.',
        animalId: '1',
        animalNombre: 'Lupita',
        animalIdExterno: 'ID-0021',
        fecha: DateTime(now.year, now.month, now.day, 8, 5),
        leida: false,
        accion: AlertaAccion.verDetalle,
      ),
      AlertaModel(
        id: 'a2',
        tipo: AlertaTipo.prediccion,
        severidad: AlertaSeveridad.alta,
        titulo: 'Mastitis detectada — acción inmediata',
        descripcion:
            'El análisis de síntomas indica Mastitis con 87% de confianza.',
        animalId: '1',
        animalNombre: 'Lupita',
        animalIdExterno: 'ID-0021',
        fecha: DateTime(now.year, now.month, now.day, 8, 15),
        leida: false,
        accion: AlertaAccion.verResultado,
      ),
      AlertaModel(
        id: 'a3',
        tipo: AlertaTipo.prediccion,
        severidad: AlertaSeveridad.moderada,
        titulo: 'Posible laminitis en Canela',
        descripcion: 'Predicción con 72% de confianza.',
        animalId: '2',
        animalNombre: 'Canela',
        animalIdExterno: 'ID-0014',
        fecha: now.subtract(const Duration(days: 1, hours: 8, minutes: 19)),
        leida: false,
        accion: AlertaAccion.verResultado,
      ),
      AlertaModel(
        id: 'a4',
        tipo: AlertaTipo.nlp,
        severidad: AlertaSeveridad.ninguna,
        titulo: 'El NLP identificó decaimiento severo',
        descripcion:
            'Tu descripción de texto reveló señales de decaimiento no seleccionadas en el formulario.',
        animalId: '2',
        animalNombre: 'Canela',
        animalIdExterno: 'ID-0014',
        fecha: now.subtract(const Duration(days: 1, hours: 8, minutes: 20)),
        leida: false,
      ),
      AlertaModel(
        id: 'a5',
        tipo: AlertaTipo.prediccion,
        severidad: AlertaSeveridad.leve,
        titulo: 'Estrella está saludable',
        descripcion:
            'Análisis completado con 94% de confianza. No se detectaron enfermedades.',
        animalId: '3',
        animalNombre: 'Estrella',
        animalIdExterno: 'ID-0008',
        fecha: now.subtract(const Duration(days: 1, hours: 16)),
        leida: true,
      ),
      AlertaModel(
        id: 'a6',
        tipo: AlertaTipo.sistema,
        severidad: AlertaSeveridad.ninguna,
        titulo: 'Modelo actualizado a v1.2',
        descripcion:
            'La precisión mejoró del 82% al 87% en enfermedades respiratorias.',
        fecha: now.subtract(const Duration(days: 3)),
        leida: true,
      ),
      AlertaModel(
        id: 'a7',
        tipo: AlertaTipo.isolationForest,
        severidad: AlertaSeveridad.moderada,
        titulo: 'Resumen productivo de tu hato',
        descripcion:
            'Esta semana tu hato produjo en promedio 14.2 L por vaca/día.',
        fecha: now.subtract(const Duration(days: 4)),
        leida: true,
      ),
    ];
  }

  @override
  Future<void> marcarAlertaLeida(String alertaId) async {
    // Mock mientras las alertas no vengan de la API real.
    // Cuando conectes alertas: await _dio.patch(ApiConstants.marcarAlerta(alertaId), data: {'leida': true});
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> marcarTodasAlertasLeidas() async {
    // La API no tiene endpoint bulk; mock por ahora.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ────────────────────────────────────────────────────────────────────────────
  // HISTORIAL PRODUCTIVO — MOCK (no existe endpoint en la API)
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Future<List<HistorialProductivoModel>> getHistorialAnimal(
      String animalId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();

    if (animalId == '1') {
      return [
        HistorialProductivoModel(id: 'h1', animalId: animalId, fecha: now.subtract(const Duration(days: 6)), litrosLeche: 18.5, kgAlimento: 12.0, temperatura: 38.5, anomaliaDetectada: false),
        HistorialProductivoModel(id: 'h2', animalId: animalId, fecha: now.subtract(const Duration(days: 5)), litrosLeche: 18.0, kgAlimento: 12.0, temperatura: 38.4, anomaliaDetectada: false),
        HistorialProductivoModel(id: 'h3', animalId: animalId, fecha: now.subtract(const Duration(days: 4)), litrosLeche: 17.5, kgAlimento: 11.8, temperatura: 38.6, anomaliaDetectada: false),
        HistorialProductivoModel(id: 'h4', animalId: animalId, fecha: now.subtract(const Duration(days: 3)), litrosLeche: 19.0, kgAlimento: 12.2, temperatura: 38.3, anomaliaDetectada: false),
        HistorialProductivoModel(id: 'h5', animalId: animalId, fecha: now.subtract(const Duration(days: 2)), litrosLeche: 12.0, kgAlimento: 10.5, temperatura: 39.2, anomaliaDetectada: true),
        HistorialProductivoModel(id: 'h6', animalId: animalId, fecha: now.subtract(const Duration(days: 1)), litrosLeche: 8.0, kgAlimento: 9.0, temperatura: 39.5, anomaliaDetectada: true),
        HistorialProductivoModel(id: 'h7', animalId: animalId, fecha: now, litrosLeche: 5.0, kgAlimento: 8.5, temperatura: 39.8, anomaliaDetectada: true),
      ];
    }

    return List.generate(7, (i) {
      final liters = 14.0 + (i % 3) * 1.5;
      return HistorialProductivoModel(
        id: 'h_${animalId}_$i', animalId: animalId,
        fecha: now.subtract(Duration(days: 6 - i)),
        litrosLeche: liters, kgAlimento: 11.0, temperatura: 38.5,
        anomaliaDetectada: false,
      );
    });
  }

  // ────────────────────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────────────────────

  static String _fmtDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
