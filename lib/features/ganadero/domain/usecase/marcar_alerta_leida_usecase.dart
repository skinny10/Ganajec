import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class MarcarAlertaLeidaUseCase {
  final GanaderoRepository _repository;
  MarcarAlertaLeidaUseCase(this._repository);

  Future<void> call(String alertaId) => _repository.marcarAlertaLeida(alertaId);
}
