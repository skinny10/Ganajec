import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

abstract class SuscripcionRemoteDataSource {
  Future<SuscripcionInfo> getSuscripcion();
  Future<List<Plan>> getPlanes();
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual});
}

class SuscripcionRemoteDataSourceImpl implements SuscripcionRemoteDataSource {
  @override
  Future<SuscripcionInfo> getSuscripcion() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return SuscripcionInfo(
      planActual: kPlanes[0], // PlanTipo.gratuito
      bovinosUsados: 3,
      analisisUsados: 12,
    );
  }

  @override
  Future<List<Plan>> getPlanes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return kPlanes;
  }

  @override
  Future<bool> suscribirse(PlanTipo tipo, {required bool esAnual}) async {
    // Cuando tengas Google Play Billing: procesarCompra()
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
