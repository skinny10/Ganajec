import 'package:dio/dio.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import '../models/suscripcion_model.dart';

abstract class SuscripcionRemoteDataSource {
  Future<SuscripcionInfo> getSuscripcion();
  Future<List<Plan>> getPlanes();
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual});
}

class SuscripcionRemoteDataSourceImpl implements SuscripcionRemoteDataSource {
  final Dio _dio = ApiClient.instance;

  String get _uid => TokenStorage.userId ?? '';

  // ── GET /dueno/{id}/suscripcion ───────────────────────────────────────────
  @override
  Future<SuscripcionInfo> getSuscripcion() async {
    try {
      final res = await _dio.get(ApiConstants.suscripcionDueno(_uid));
      return SuscripcionModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // Si el servidor no tiene suscripción aún (404/500), devolvemos gratuito
      if (e.response?.statusCode == 404 ||
          e.response?.statusCode == 500) {
        return SuscripcionInfo(
          planActual: kPlanes.first,
          bovinosUsados: 0,
          analisisUsados: 0,
        );
      }
      rethrow;
    }
  }

  // ── Planes locales (no hay endpoint de catálogo en la API) ─────────────────
  @override
  Future<List<Plan>> getPlanes() async => kPlanes;

  // ── POST /dueno/suscripcion ───────────────────────────────────────────────
  @override
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual}) async {
    await _dio.post(
      ApiConstants.suscribirse,
      data: {
        'plan': tipo.name,
        'es_anual': esAnual,
      },
    );
    return true;
  }
}
