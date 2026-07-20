import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/constants/api_constants.dart';
import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';
import 'package:ganajec/features/admin/domain/entities/admin_rancho.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';

class AdminRemoteDataSource {
  final _dio = ApiClient.instance;

  Future<List<AdminUsuario>> getUsuarios() async {
    final res = await _dio.get(ApiConstants.adminUsuarios);
    final data = res.data;
    final lista = data is Map
        ? (data['usuarios'] as List? ?? [])
        : (data as List? ?? []);
    return lista
        .map((e) => AdminUsuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> editarUsuario(String id, {String? nombre, String? email, String? rol, bool? isActive}) async {
    final body = <String, dynamic>{};
    if (nombre != null) body['nombre'] = nombre;
    if (email != null) body['email'] = email;
    if (rol != null) body['rol'] = rol;
    if (isActive != null) body['activo'] = isActive;
    await _dio.put(ApiConstants.adminUsuario(id), data: body);
  }

  Future<void> eliminarUsuario(String id) async {
    await _dio.delete(ApiConstants.adminUsuario(id));
  }

  Future<List<AdminRancho>> getRanchos() async {
    final res = await _dio.get(ApiConstants.adminRanchos);
    final data = res.data;
    final lista = data is Map
        ? (data['ranchos'] as List? ?? [])
        : (data as List? ?? []);
    return lista
        .map((e) => AdminRancho.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SistemaEstado> getEstadoSistema() async {
    final res = await _dio.get(ApiConstants.adminSistemaEstado);
    return SistemaEstado.fromJson(res.data as Map<String, dynamic>);
  }
}
