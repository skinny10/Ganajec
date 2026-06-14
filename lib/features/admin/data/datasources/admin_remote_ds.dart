import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import '../../domain/entities/usuario.dart';

class AdminRemoteDataSource {
  final Dio dio;

  AdminRemoteDataSource(this.dio);

  Future<List<UsuarioModel>> getUsuarios() async {
    final response = await dio.get('/admin/usuarios');
    return (response.data as List)
        .map((e) => UsuarioModel.fromJson(e))
        .toList();
  }

  Future<UsuarioStats> getStats() async {
    final response = await dio.get('/admin/stats');
    return UsuarioStats(
      totalUsuarios: response.data['total_usuarios'],
      totalGanaderos: response.data['total_ganaderos'],
      totalDuenos: response.data['total_duenos'],
      totalVeterinarios: response.data['total_veterinarios'],
    );
  }
}
