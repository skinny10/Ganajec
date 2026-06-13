import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';
import 'package:ganajec/features/ganadero/data/models/animal_model.dart';
import 'package:ganajec/features/ganadero/data/models/alerta_model.dart';
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
}

class GanaderoRemoteDataSourceImpl implements GanaderoRemoteDataSource {
  @override
  Future<List<AnimalModel>> getAnimales() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      AnimalModel(
        id: '1',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Lupita',
        raza: 'Holstein',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2020, 3, 10),
        pesoKg: 480,
        idExterno: 'ID-0021',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '2',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Canela',
        raza: 'Suizo',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2021, 6, 15),
        pesoKg: 420,
        idExterno: 'ID-0014',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '3',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Estrella',
        raza: 'Angus',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2019, 1, 20),
        pesoKg: 510,
        idExterno: 'ID-0008',
        creadoEn: DateTime.now(),
      ),
      AnimalModel(
        id: '4',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: 'Rosita',
        raza: 'Holstein',
        sexo: 'hembra',
        fechaNacimiento: DateTime(2022, 8, 5),
        pesoKg: 390,
        idExterno: 'ID-0033',
        creadoEn: DateTime.now(),
      ),
    ];
  }

  @override
  Future<List<PrediccionModel>> getUltimasPredicciones() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      PrediccionModel(
        id: 'p1',
        animalId: '1',
        animalNombre: 'Lupita',
        enfermedad: 'Mastitis',
        confianza: 0.87,
        fecha: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      PrediccionModel(
        id: 'p2',
        animalId: '2',
        animalNombre: 'Canela',
        enfermedad: 'Laminitis leve',
        confianza: 0.72,
        fecha: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      PrediccionModel(
        id: 'p3',
        animalId: '3',
        animalNombre: 'Estrella',
        enfermedad: 'Sin enfermedad',
        confianza: 0.94,
        fecha: DateTime.now().subtract(const Duration(hours: 8)),
      ),
    ];
  }

  @override
  Future<List<AlertaModel>> getAlertas() async {
    await Future.delayed(const Duration(milliseconds: 700));
    final now = DateTime.now();
    return [
      // ── Hoy ──────────────────────────────────────────────────────────────
      AlertaModel(
        id: 'a1',
        tipo: AlertaTipo.isolationForest,
        severidad: AlertaSeveridad.alta,
        titulo: 'Caída anómala detectada en Lupita',
        descripcion: 'La producción bajó de 18 L a 5 L en 3 días — patrón estadísticamente anormal para este animal.',
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
        descripcion: 'El análisis de síntomas indica Mastitis con 87% de confianza. Revisa la ubre y contacta al veterinario.',
        animalId: '1',
        animalNombre: 'Lupita',
        animalIdExterno: 'ID-0021',
        fecha: DateTime(now.year, now.month, now.day, 8, 15),
        leida: false,
        accion: AlertaAccion.verResultado,
      ),
      // ── Ayer ─────────────────────────────────────────────────────────────
      AlertaModel(
        id: 'a3',
        tipo: AlertaTipo.prediccion,
        severidad: AlertaSeveridad.moderada,
        titulo: 'Posible laminitis en Canela',
        descripcion: 'Predicción con 72% de confianza. Observa si cojea o muestra dificultad para moverse.',
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
        descripcion: 'Tu descripción de texto reveló señales de decaimiento que no seleccionaste en el formulario. Fueron agregadas al análisis.',
        animalId: '2',
        animalNombre: 'Canela',
        animalIdExterno: 'ID-0014',
        fecha: now.subtract(const Duration(days: 1, hours: 8, minutes: 20)),
        leida: false,
      ),
      // ── Esta semana ───────────────────────────────────────────────────────
      AlertaModel(
        id: 'a5',
        tipo: AlertaTipo.prediccion,
        severidad: AlertaSeveridad.leve,
        titulo: 'Estrella está saludable',
        descripcion: 'Análisis completado con 94% de confianza. No se detectaron enfermedades ni anomalías.',
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
        descripcion: 'El modelo de clasificación fue actualizado. La precisión mejoró del 82% al 87% en enfermedades respiratorias.',
        fecha: now.subtract(const Duration(days: 3)),
        leida: true,
      ),
      AlertaModel(
        id: 'a7',
        tipo: AlertaTipo.isolationForest,
        severidad: AlertaSeveridad.moderada,
        titulo: 'Resumen productivo de tu hato',
        descripcion: 'Esta semana tu hato produjo en promedio 14.2 L por vaca/día. Lupita muestra tendencia a la baja desde el martes.',
        fecha: now.subtract(const Duration(days: 4)),
        leida: true,
      ),
    ];
  }

  @override
  Future<void> marcarAlertaLeida(String alertaId) async {
    // Cuando tengas API: PATCH /alertas/:id/leida
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> marcarTodasAlertasLeidas() async {
    // Cuando tengas API: POST /alertas/marcar-leidas
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<Map<String, int>> getResumenHato() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return {
      'total': 12,
      'en_buen_estado': 9,
      'con_alertas': 3,
    };
  }

  @override
  Future<AnimalModel> crearAnimal(Animal animal) async {
    await Future.delayed(const Duration(seconds: 1));
    return AnimalModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ranchoId: 'r1',
      ganaderoId: 'g1',
      nombre: animal.nombre,
      raza: animal.raza,
      sexo: animal.sexo,
      fechaNacimiento: animal.fechaNacimiento,
      pesoKg: animal.pesoKg,
      idExterno: animal.idExterno.isEmpty
          ? 'ID-${DateTime.now().millisecondsSinceEpoch}'
          : animal.idExterno,
      creadoEn: DateTime.now(),
    );
  }

  @override
  Future<List<HistorialProductivoModel>> getHistorialAnimal(
      String animalId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();

    // Mock: Lupita (id=1) tiene caída anómala los últimos 3 días
    if (animalId == '1') {
      return [
        HistorialProductivoModel(
          id: 'h1', animalId: animalId,
          fecha: now.subtract(const Duration(days: 6)),
          litrosLeche: 18.5, kgAlimento: 12.0, temperatura: 38.5,
          anomaliaDetectada: false,
        ),
        HistorialProductivoModel(
          id: 'h2', animalId: animalId,
          fecha: now.subtract(const Duration(days: 5)),
          litrosLeche: 18.0, kgAlimento: 12.0, temperatura: 38.4,
          anomaliaDetectada: false,
        ),
        HistorialProductivoModel(
          id: 'h3', animalId: animalId,
          fecha: now.subtract(const Duration(days: 4)),
          litrosLeche: 17.5, kgAlimento: 11.8, temperatura: 38.6,
          anomaliaDetectada: false,
        ),
        HistorialProductivoModel(
          id: 'h4', animalId: animalId,
          fecha: now.subtract(const Duration(days: 3)),
          litrosLeche: 19.0, kgAlimento: 12.2, temperatura: 38.3,
          anomaliaDetectada: false,
        ),
        HistorialProductivoModel(
          id: 'h5', animalId: animalId,
          fecha: now.subtract(const Duration(days: 2)),
          litrosLeche: 12.0, kgAlimento: 10.5, temperatura: 39.2,
          anomaliaDetectada: true,
        ),
        HistorialProductivoModel(
          id: 'h6', animalId: animalId,
          fecha: now.subtract(const Duration(days: 1)),
          litrosLeche: 8.0, kgAlimento: 9.0, temperatura: 39.5,
          anomaliaDetectada: true,
        ),
        HistorialProductivoModel(
          id: 'h7', animalId: animalId,
          fecha: now,
          litrosLeche: 5.0, kgAlimento: 8.5, temperatura: 39.8,
          anomaliaDetectada: true,
        ),
      ];
    }

    // Mock genérico: animal saludable
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

  @override
  Future<List<PrediccionModel>> getPrediccionesAnimal(String animalId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final now = DateTime.now();

    if (animalId == '1') {
      return [
        PrediccionModel(
          id: 'p1', animalId: animalId, animalNombre: 'Lupita',
          enfermedad: 'Mastitis', confianza: 0.87,
          fecha: now.subtract(const Duration(hours: 2)),
        ),
        PrediccionModel(
          id: 'p2', animalId: animalId, animalNombre: 'Lupita',
          enfermedad: 'Sin enfermedad', confianza: 0.91,
          fecha: now.subtract(const Duration(days: 5)),
        ),
        PrediccionModel(
          id: 'p3', animalId: animalId, animalNombre: 'Lupita',
          enfermedad: 'Sin enfermedad', confianza: 0.88,
          fecha: now.subtract(const Duration(days: 12)),
        ),
      ];
    }

    return [
      PrediccionModel(
        id: 'p_${animalId}_1', animalId: animalId, animalNombre: '',
        enfermedad: 'Sin enfermedad', confianza: 0.92,
        fecha: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  @override
  Future<AnimalModel> actualizarAnimal(Animal animal) async {
    await Future.delayed(const Duration(seconds: 1));
    // Cuando tengas API: PUT /animales/:id
    return AnimalModel(
      id: animal.id,
      ranchoId: animal.ranchoId,
      ganaderoId: animal.ganaderoId,
      nombre: animal.nombre,
      raza: animal.raza,
      sexo: animal.sexo,
      fechaNacimiento: animal.fechaNacimiento,
      pesoKg: animal.pesoKg,
      idExterno: animal.idExterno,
      creadoEn: animal.creadoEn,
    );
  }

  @override
  Future<void> eliminarAnimal(String animalId) async {
    // Cuando tengas API: DELETE /animales/:id
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<PrediccionModel> registrarSintomas(RegistroSintomas registro) async {
    // Cuando tengas API: POST /sintomas con NLP + Isolation Forest
    await Future.delayed(const Duration(seconds: 2));

    // Mock: derivar diagnóstico a partir de severidad calculada localmente
    final sinCount = registro.sintomas.length;
    final temp = registro.temperatura;
    final leche = registro.litrosLeche;
    final textoLen = registro.descripcion.length;

    int score = 0;
    score += sinCount >= 4 ? 3 : sinCount >= 2 ? 2 : sinCount >= 1 ? 1 : 0;
    score += temp > 40 ? 3 : temp > 39 ? 1 : 0;
    score += leche <= 5 ? 2 : leche <= 10 ? 1 : 0;
    score += textoLen > 20 ? 1 : 0;

    final String enfermedad;
    final double confianza;

    if (score >= 6) {
      enfermedad = 'Mastitis';
      confianza = 0.87;
    } else if (score >= 3) {
      enfermedad = 'Laminitis leve';
      confianza = 0.72;
    } else {
      enfermedad = 'Sin enfermedad detectada';
      confianza = 0.91;
    }

    return PrediccionModel(
      id: 'pred_${DateTime.now().millisecondsSinceEpoch}',
      animalId: registro.animalId,
      animalNombre: '',
      enfermedad: enfermedad,
      confianza: confianza,
      fecha: DateTime.now(),
    );
  }
}
