import 'package:ganajec/share/domain/entities/prediccion.dart';
import 'package:ganajec/share/domain/entities/registro_sintomas.dart';
import '../repositories/ganadero_repository.dart';

class RegistrarSintomasUseCase {
  final GanaderoRepository _repository;

  const RegistrarSintomasUseCase(this._repository);

  Future<Prediccion> call(RegistroSintomas registro) =>
      _repository.registrarSintomas(registro);
}
