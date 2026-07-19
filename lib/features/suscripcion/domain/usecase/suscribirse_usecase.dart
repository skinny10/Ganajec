import '../repositories/suscripcion_repository.dart';

class SuscribirseUseCase {
  final SuscripcionRepository _repo;
  SuscribirseUseCase(this._repo);

  Future<Map<String, dynamic>> call({
    required String paymentIntentId,
    required String planId,
    required int monto,
    required String moneda,
  }) =>
      _repo.confirmarPago(
        paymentIntentId: paymentIntentId,
        planId: planId,
        monto: monto,
        moneda: moneda,
      );
}
