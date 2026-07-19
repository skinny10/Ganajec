import 'package:ganajec/features/admin/domain/entities/admin_usuario.dart';
import 'package:ganajec/features/admin/domain/entities/admin_rancho.dart';
import 'package:ganajec/features/admin/domain/entities/admin_sistema_estado.dart';

abstract class AdminRepository {
  Future<List<AdminUsuario>> getUsuarios();
  Future<void> editarUsuario(String id, {String? nombre, String? email, String? rol, bool? isActive});
  Future<void> eliminarUsuario(String id);
  Future<List<AdminRancho>> getRanchos();
  Future<SistemaEstado> getEstadoSistema();
}
