import 'package:ganajec/share/domain/entities/historial_item.dart';
import '../repositories/ganadero_repository.dart';

class GetHistorialGanaderoUseCase {
  final GanaderoRepository _repository;
  GetHistorialGanaderoUseCase(this._repository);

  Future<List<HistorialItem>> call() => _repository.getHistorialGanadero();
}
