import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/features/ganadero/domain/repositories/ganadero_repository.dart';

class GetAnimalesUseCase {
  final GanaderoRepository repository;
  const GetAnimalesUseCase(this.repository);

  Future<List<Animal>> call() => repository.getAnimales();
}
