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
  Animal? _createdAnimal;

  RegistroStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == RegistroStatus.loading;
  Animal? get createdAnimal => _createdAnimal;

  Future<void> registrar({
    required String nombre,
    required String idExterno,
    required String categoria,
    required String proposito,
    required String raza,
    required int edad,
    required double pesoKg,
    bool edadEnMeses = false,
  }) async {
    _setStatus(RegistroStatus.loading);
    try {
      final now = DateTime.now();
      final fechaNacimiento = edadEnMeses
          ? DateTime(now.year, now.month - edad, now.day)
          : DateTime(now.year - edad, now.month, now.day);
      final animal = Animal(
        id: '',
        ranchoId: '',  // se resuelve en el datasource desde TokenStorage
        ganaderoId: '',
        nombre: nombre,
        raza: raza,
        sexo: _sexoPorCategoria(categoria),
        categoria: categoria,
        proposito: proposito,
        fechaNacimiento: fechaNacimiento,
        pesoKg: pesoKg,
        idExterno: idExterno,
        creadoEn: now,
      );
      _createdAnimal = await _crearAnimal(animal);
      _setStatus(RegistroStatus.success);
    } catch (e) {
      // Mostrar solo el mensaje, no el stack trace completo
      final raw = e.toString();
      _errorMessage = raw.startsWith('Exception: ') ? raw.substring(11) : raw;
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
    _createdAnimal = null;
    _setStatus(RegistroStatus.idle);
  }

  void _setStatus(RegistroStatus status) {
    _status = status;
    notifyListeners();
  }
}
