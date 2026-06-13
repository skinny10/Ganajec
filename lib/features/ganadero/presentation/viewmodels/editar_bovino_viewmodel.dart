import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import '../../domain/usecase/actualizar_animal_usecase.dart';
import '../../domain/usecase/eliminar_animal_usecase.dart';

enum EditarBovinoStatus { idle, saving, saved, deleting, deleted, error }

class EditarBovinoViewModel extends ChangeNotifier {
  final ActualizarAnimalUseCase _actualizarAnimal;
  final EliminarAnimalUseCase _eliminarAnimal;

  EditarBovinoViewModel({
    required ActualizarAnimalUseCase actualizarAnimal,
    required EliminarAnimalUseCase eliminarAnimal,
  })  : _actualizarAnimal = actualizarAnimal,
        _eliminarAnimal = eliminarAnimal;

  EditarBovinoStatus _status = EditarBovinoStatus.idle;
  Animal? _animalActualizado;
  String? _error;

  EditarBovinoStatus get status => _status;
  Animal? get animalActualizado => _animalActualizado;
  String? get error => _error;
  bool get isSaving => _status == EditarBovinoStatus.saving;
  bool get isDeleting => _status == EditarBovinoStatus.deleting;
  bool get isBusy => isSaving || isDeleting;

  Future<bool> guardar(Animal animal) async {
    _setStatus(EditarBovinoStatus.saving);
    try {
      _animalActualizado = await _actualizarAnimal(animal);
      _setStatus(EditarBovinoStatus.saved);
      return true;
    } catch (e) {
      _error = e.toString();
      _setStatus(EditarBovinoStatus.error);
      return false;
    }
  }

  Future<bool> eliminar(String animalId) async {
    _setStatus(EditarBovinoStatus.deleting);
    try {
      await _eliminarAnimal(animalId);
      _setStatus(EditarBovinoStatus.deleted);
      return true;
    } catch (e) {
      _error = e.toString();
      _setStatus(EditarBovinoStatus.error);
      return false;
    }
  }

  void resetStatus() {
    _error = null;
    _setStatus(EditarBovinoStatus.idle);
  }

  void _setStatus(EditarBovinoStatus s) {
    _status = s;
    notifyListeners();
  }
}
