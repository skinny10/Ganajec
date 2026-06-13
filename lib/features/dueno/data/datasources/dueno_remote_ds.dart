import 'package:dio/dio.dart';
import '../models/dueno_dashboard_model.dart';

class DuenoRemoteDataSource {
  final Dio dio;

  DuenoRemoteDataSource(this.dio);

  Future<DuenoDashboardModel> getDashboard(String duenoId) async {
    final response = await dio.get('/dueno/$duenoId/dashboard');
    return DuenoDashboardModel.fromJson(response.data);
  }

  Future<List<GanaderoResumenModel>> getGanaderos(String duenoId) async {
    final response = await dio.get('/dueno/$duenoId/ganaderos');
    return (response.data as List)
        .map((e) => GanaderoResumenModel.fromJson(e))
        .toList();
  }
}
