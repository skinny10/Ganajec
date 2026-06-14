import 'package:ganajec/core/network/api_client.dart';
import '../models/dueno_dashboard_model.dart';

class DuenoRemoteDataSource {
  Future<DuenoDashboardModel> getDashboard(String duenoId) async {
    final dio = ApiClient.instance;

    final usuarioRes = await dio.get('/dueno/$duenoId');
    final nombreDueno = usuarioRes.data['nombre'] as String;
    final ranchos = usuarioRes.data['ranchos'] as List;
    final ranchoId = ranchos[0]['id'] as String;
    final nombreRancho = ranchos[0]['nombre'] as String;

    final ranchoRes = await dio.get('/dueno/ranchos/$ranchoId');
    final resumen = ranchoRes.data['resumen'] as Map;

    final ganaderosRes = await dio.get('/dueno/ranchos/$ranchoId/ganaderos');
    final ganaderosList = ganaderosRes.data['ganaderos'] as List;

    return DuenoDashboardModel(
      totalAnimales: resumen['total_bovinos'] ?? 0,
      animalesConAlerta: 0,
      animalesSanos: 0,
      ganadoresEnCampo: 0,
      produccionLecheHoy: 0,
      produccionLecheAyer: 0,
      casosCriticos: [],
      ganaderos: ganaderosList
          .map((e) => GanaderoResumenModel.fromJson(e))
          .toList(),
      nombreDueno: nombreDueno,
      nombreRancho: nombreRancho,
    );
  }

  Future<List<GanaderoResumenModel>> getGanaderos(String duenoId) async {
    final dio = ApiClient.instance;
    final res = await dio.get('/dueno/$duenoId/ganaderos');
    return (res.data as List)
        .map((e) => GanaderoResumenModel.fromJson(e))
        .toList();
  }
}
