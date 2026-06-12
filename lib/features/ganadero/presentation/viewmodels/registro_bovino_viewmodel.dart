import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/animal.dart';
import 'package:ganajec/features/ganadero/domain/usecase/crear_animal_usecase.dart';

enum RegistroStatus { idle, loading, success, error }

class RegistroBovinoViewModel extends ChangeNotifier {
  final CrearAnimalUseCase _crearAnimal;

  RegistroBovinoViewModel({required CrearAnimalUseCase crearAnimal})
      : _crearAnimal = crearAnimal;

  RegistroStatus _status = RegistroStatus.idle;
  String? _errorMessage;

  RegistroStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RegistroStatus.loading;

  Future<void> registrar({
    required String nombre,
    required String idExterno,
    required String categoria,
    required String proposito,
    required String raza,
    required int edad,
    required double pesoKg,
  }) async {
    _setStatus(RegistroStatus.loading);
    try {
      final animal = Animal(
        id: '',
        ranchoId: 'r1',
        ganaderoId: 'g1',
        nombre: nombre,
        raza: raza,
        sexo: _sexoPorCategoria(categoria),
        fechaNacimiento: DateTime(DateTime.now().year - edad),
        pesoKg: pesoKg,
        idExterno: idExterno,
        creadoEn: DateTime.now(),
      );
      await _crearAnimal(animal);
      _setStatus(RegistroStatus.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setStatus(RegistroStatus.error);
    }
  }

  String _sexoPorCategoria(String categoria) {
    switch (categoria) {
      case 'toro':
      case 'becerro':
      case 'novillo':
        return 'macho';
      default:
        return 'hembra';
    }
  }

  void resetStatus() {
    _errorMessage = null;
    _setStatus(RegistroStatus.idle);
  }

  void _setStatus(RegistroStatus status) {
    _status = status;
    notifyListeners();
  }
}
