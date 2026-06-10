import 'package:ganajec/core/domain/entities/alerta.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class GetAlertasUseCase {
  final GanaderoRepository repository;
  const GetAlertasUseCase(this.repository);

  Future<List<Alerta>> call() => repository.getAlertas();
}