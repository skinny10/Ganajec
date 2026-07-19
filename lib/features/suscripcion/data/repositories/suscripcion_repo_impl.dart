import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/suscripcion/domain/repositories/suscripcion_repository.dart';
import 'package:ganajec/features/suscripcion/data/datasource/suscripcion_remote_ds.dart';
import 'package:ganajec/features/suscripcion/data/datasource/payment_remote_ds.dart';

class SuscripcionRepositoryImpl implements SuscripcionRepository {
  final SuscripcionRemoteDataSource _suscripcionDs;
  final PaymentRemoteDataSource _paymentDs;
  SuscripcionRepositoryImpl(this._suscripcionDs, this._paymentDs);

  @override
  Future<SuscripcionInfo> getSuscripcion() => _suscripcionDs.getSuscripcion();

  @override
  Future<List<Plan>> getPlanes() => _suscripcionDs.getPlanes();

  @override
  Future<Map<String, dynamic>> confirmarPago({
    required String paymentIntentId,
    required String planId,
    required int monto,
    required String moneda,
  }) {
    final duenoId = TokenStorage.userId ?? '';
    return _paymentDs.confirmarSuscripcion(
      duenoId: duenoId,
      paymentIntentId: paymentIntentId,
      planId: planId,
      monto: monto,
      moneda: moneda,
    );
  }
}
