import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

abstract class SuscripcionRepository {
  Future<SuscripcionInfo> getSuscripcion();
  Future<List<Plan>> getPlanes();
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual});
}
