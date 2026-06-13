import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class MarcarTodasAlertasLeidasUseCase {
  final GanaderoRepository _repository;
  MarcarTodasAlertasLeidasUseCase(this._repository);

  Future<void> call() => _repository.marcarTodasAlertasLeidas();
}
