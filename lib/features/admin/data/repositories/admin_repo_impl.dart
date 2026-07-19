import 'package:ganajec/features/admin/domain/repositories/admin_repository.dart';
import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';
import 'package:ganajec/features/admin/domain/entities/admin_rancho.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';
import 'package:ganajec/features/admin/data/datasource/admin_remote_ds.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource _ds;

  AdminRepositoryImpl(this._ds);

  @override
  Future<List<AdminUsuario>> getUsuarios() => _ds.getUsuarios();

  @override
  Future<void> editarUsuario(String id, {String? nombre, String? email, String? rol, bool? isActive}) =>
      _ds.editarUsuario(id, nombre: nombre, email: email, rol: rol, isActive: isActive);

  @override
  Future<void> eliminarUsuario(String id) => _ds.eliminarUsuario(id);

  @override
  Future<List<AdminRancho>> getRanchos() => _ds.getRanchos();

  @override
  Future<SistemaEstado> getEstadoSistema() => _ds.getEstadoSistema();
}
