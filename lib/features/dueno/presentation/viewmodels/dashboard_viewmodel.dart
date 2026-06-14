import 'package:flutter/material.dart';
import '../../domain/entities/dueno_dashboard.dart';
// import '../../domain/usecases/get_dashboard_dueno_usecase.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  // final GetDashboardDuenoUsecase getDashboardUsecase;

  // DashboardViewModel(this.getDashboardUsecase);

  DashboardViewModel();

  DashboardState _state = DashboardState.initial;
  DuenoDashboard? _dashboard;
  String? _errorMessage;

  DashboardState get state => _state;
  DuenoDashboard? get dashboard => _dashboard;
  String? get errorMessage => _errorMessage;

  Future<void> cargarDashboard(String duenoId) async {
    _state = DashboardState.loading;
    notifyListeners();

    try {
      // _dashboard = await getDashboardUsecase(duenoId);
      _dashboard = _mockDashboard();
      _state = DashboardState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = DashboardState.error;
    }

    notifyListeners();
  }

  DuenoDashboard _mockDashboard() {
    return DuenoDashboard(
      totalAnimales: 24,
      animalesConAlerta: 4,
      animalesSanos: 20,
      ganadoresEnCampo: 3,
      produccionLecheHoy: 142,
      produccionLecheAyer: 127,
      casosCriticos: [
        CasoCritico(
          id: '1',
          nombreAnimal: 'Lupita',
          raza: 'Holstein',
          animalId: 'BOV-001',
          porcentajeRiesgo: 87,
          severidad: 'alta',
          ganaderoNombre: 'Juan Perez',
          fechaDeteccion: DateTime.now().subtract(const Duration(hours: 6)),
        ),
        CasoCritico(
          id: '2',
          nombreAnimal: 'Canela',
          raza: 'Suizo',
          animalId: 'BOV-002',
          porcentajeRiesgo: 72,
          severidad: 'alta',
          ganaderoNombre: 'Maria Lopez',
          fechaDeteccion: DateTime.now().subtract(const Duration(hours: 12)),
        ),
        CasoCritico(
          id: '3',
          nombreAnimal: 'Torito',
          raza: 'Brahman',
          animalId: 'BOV-003',
          porcentajeRiesgo: 65,
          severidad: 'moderada',
          ganaderoNombre: 'Pedro Ruiz',
          fechaDeteccion: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      ganaderos: [
        GanaderoResumen(
          id: 'g1',
          nombre: 'Juan Perez',
          iniciales: 'JP',
          totalBovinos: 10,
          alertasAltas: 1,
          animalesSanos: 8,
          activoHoy: true,
          ultimaActividad: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        GanaderoResumen(
          id: 'g2',
          nombre: 'Maria Lopez',
          iniciales: 'ML',
          totalBovinos: 8,
          alertasAltas: 2,
          animalesSanos: 6,
          activoHoy: true,
          ultimaActividad: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        GanaderoResumen(
          id: 'g3',
          nombre: 'Pedro Ruiz',
          iniciales: 'PR',
          totalBovinos: 6,
          alertasAltas: 1,
          animalesSanos: 5,
          activoHoy: false,
          ultimaActividad: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    );
  }
}
