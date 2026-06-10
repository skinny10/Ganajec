import 'package:ganajec/core/domain/entities/animal.dart';
import '../repositories/ganadero_repository.dart';

class GetAnimalesUseCase {
  final GanaderoRepository repository;
  const GetAnimalesUseCase(this.repository);

  Future<List<Animal>> call() => repository.getAnimales();
}