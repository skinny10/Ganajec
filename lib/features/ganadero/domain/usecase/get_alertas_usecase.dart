import 'package:ganajec/share/domain/entities/alerta.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class GetAlertasUseCase {
  final GanaderoRepository _repository;
  GetAlertasUseCase(this._repository);

  Future<List<Alerta>> call() => _repository.getAlertas();
}
