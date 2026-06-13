import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import '../repositories/suscripcion_repository.dart';

class GetSuscripcionUseCase {
  final SuscripcionRepository _repo;
  GetSuscripcionUseCase(this._repo);
  Future<SuscripcionInfo> call() => _repo.getSuscripcion();
}
