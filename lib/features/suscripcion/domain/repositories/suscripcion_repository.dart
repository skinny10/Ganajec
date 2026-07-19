import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';

abstract class SuscripcionRepository {
  Future<SuscripcionInfo> getSuscripcion();
  Future<List<Plan>> getPlanes();
  Future<Map<String, dynamic>> confirmarPago({
    required String paymentIntentId,
    required String planId,
    required int monto,
    required String moneda,
  });
}
