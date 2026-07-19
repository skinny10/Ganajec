import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_suscripcion_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_planes_usecase.dart';

enum MiPlanStatus { idle, loading, loaded, error }

class MiPlanViewModel extends ChangeNotifier {
  final GetSuscripcionUseCase _getSuscripcion;
  final GetPlanesUseCase _getPlanes;

  MiPlanViewModel({
    required GetSuscripcionUseCase getSuscripcion,
    required GetPlanesUseCase getPlanes,
  })  : _getSuscripcion = getSuscripcion,
        _getPlanes = getPlanes;

  MiPlanStatus _status = MiPlanStatus.idle;
  SuscripcionInfo? _suscripcion;
  List<Plan> _planesUpgrade = [];
  String? _error;

  MiPlanStatus get status => _status;
  bool get isLoading => _status == MiPlanStatus.loading;
  SuscripcionInfo? get suscripcion => _suscripcion;
  String? get error => _error;
  List<Plan> get planesUpgrade => _planesUpgrade;

  Future<void> cargar() async {
    _status = MiPlanStatus.loading;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _getSuscripcion(),
        _getPlanes(),
      ]);
      _suscripcion = results[0] as SuscripcionInfo;
      final todos = results[1] as List<Plan>;
      final tipoActual = _suscripcion?.planActual.tipo;
      _planesUpgrade = tipoActual != null
          ? todos
              .where((p) => p.tipo != PlanTipo.gratuito && p.tipo != tipoActual)
              .toList()
          : [];
      _status = MiPlanStatus.loaded;
    } catch (e) {
      _error = e.toString();
      _status = MiPlanStatus.error;
    }
    notifyListeners();
  }
}
