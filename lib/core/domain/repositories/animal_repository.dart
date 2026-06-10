import 'package:ganajec/core/domain/entities/animal.dart';

abstract class AnimalRepository {
  Future<List<Animal>> getAnimales();
  Future<Animal> getAnimalById(String id);
  Future<Animal> crearAnimal(Animal animal);
  Future<Animal> actualizarAnimal(Animal animal);
  Future<void> eliminarAnimal(String id);
}