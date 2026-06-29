import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_suscripcion_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_planes_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/suscribirse_usecase.dart';
import 'package:ganajec/features/suscripcion/data/datasource/payment_remote_ds.dart';

enum ElegirPlanStatus { idle, loading, subscribing, subscribed, error }

class ElegirPlanViewModel extends ChangeNotifier {
  final GetSuscripcionUseCase _getSuscripcion;
  final GetPlanesUseCase _getPlanes;
  final SuscribirseUseCase _suscribirse;
  final PaymentRemoteDataSource _paymentDs = PaymentRemoteDataSourceImpl();

  ElegirPlanViewModel({
    required GetSuscripcionUseCase getSuscripcion,
    required GetPlanesUseCase getPlanes,
    required SuscribirseUseCase suscribirse,
    PlanTipo? planInicial,
  })  : _getSuscripcion = getSuscripcion,
        _getPlanes = getPlanes,
        _suscribirse = suscribirse,
        _planSeleccionado = planInicial ?? PlanTipo.basico;

  ElegirPlanStatus _status = ElegirPlanStatus.idle;
  List<Plan> _planes = [];
  SuscripcionInfo? _suscripcion;
  PlanTipo _planSeleccionado;
  bool _esPagoAnual = false;
  String? _error;

  ElegirPlanStatus get status => _status;
  bool get isLoading => _status == ElegirPlanStatus.loading;
  bool get isSubscribing => _status == ElegirPlanStatus.subscribing;
  List<Plan> get planes => _planes;
  SuscripcionInfo? get suscripcion => _suscripcion;
  PlanTipo get planSeleccionado => _planSeleccionado;
  bool get esPagoAnual => _esPagoAnual;
  String? get error => _error;

  PlanTipo? get planActualTipo => _suscripcion?.planActual.tipo;

  Plan? get planSeleccionadoObj =>
      _planes.isEmpty ? null : _planes.firstWhere((p) => p.tipo == _planSeleccionado);

  int get precioActual {
    final p = planSeleccionadoObj;
    if (p == null) return 0;
    return _esPagoAnual ? p.precioAnual : p.precioMensual;
  }

  String get textoPrecioBoton {
    final p = planSeleccionadoObj;
    if (p == null) return '';
    if (p.esGratuito) return 'Continuar gratis';
    final precio = _esPagoAnual ? p.precioAnual : p.precioMensual;
    final periodo = _esPagoAnual ? 'año' : 'mes';
    return 'Suscribirme · \$${_formatNum(precio)} / $periodo';
  }

  String _formatNum(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');

  Future<void> cargar() async {
    _status = ElegirPlanStatus.loading;
    notifyListeners();
    try {
      final results = await Future.wait([_getSuscripcion(), _getPlanes()]);
      _suscripcion = results[0] as SuscripcionInfo;
      _planes = results[1] as List<Plan>;
      _status = ElegirPlanStatus.idle;
    } catch (e) {
      _error = e.toString();
      _status = ElegirPlanStatus.error;
    }
    notifyListeners();
  }

  void seleccionarPlan(PlanTipo tipo) {
    if (_planSeleccionado == tipo) return;
    _planSeleccionado = tipo;
    notifyListeners();
  }

  void togglePagoAnual() {
    _esPagoAnual = !_esPagoAnual;
    notifyListeners();
  }

  Future<String?> obtenerClientSecret() async {
    final p = planSeleccionadoObj;
    if (p == null || p.esGratuito) return null;
    final amount = _esPagoAnual ? p.precioAnual * 100 : p.precioMensual * 100;
    return await _paymentDs.createPaymentIntent(amount, 'mxn');
  }

  Future<bool> confirmarSuscripcion() async {
    final p = planSeleccionadoObj;
    if (p == null || p.esGratuito) return false;
    _status = ElegirPlanStatus.subscribing;
    _error = null;
    notifyListeners();
    try {
      final ok = await _suscribirse(p.tipo, esAnual: _esPagoAnual);
      _status = ok ? ElegirPlanStatus.subscribed : ElegirPlanStatus.error;
      notifyListeners();
      return ok;
    } catch (e) {
      _error = e.toString();
      _status = ElegirPlanStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetStatus() {
    if (_status == ElegirPlanStatus.error || _status == ElegirPlanStatus.subscribed) {
      _status = ElegirPlanStatus.idle;
      notifyListeners();
    }
  }
}