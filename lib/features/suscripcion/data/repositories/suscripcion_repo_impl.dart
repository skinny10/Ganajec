import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import 'package:ganajec/features/suscripcion/domain/repositories/suscripcion_repository.dart';
import 'package:ganajec/features/suscripcion/data/datasource/suscripcion_remote_ds.dart';

class SuscripcionRepositoryImpl implements SuscripcionRepository {
  final SuscripcionRemoteDataSource _ds;
  SuscripcionRepositoryImpl(this._ds);

  @override
  Future<SuscripcionInfo> getSuscripcion() => _ds.getSuscripcion();

  @override
  Future<List<Plan>> getPlanes() => _ds.getPlanes();

  @override
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual}) =>
      _ds.suscribirse(tipo, esAnual: esAnual);
}
