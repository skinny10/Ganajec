import 'package:flutter/material.dart';
import 'package:ganajec/share/domain/entities/plan.dart';
import 'package:ganajec/share/domain/entities/suscripcion_info.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_suscripcion_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/get_planes_usecase.dart';
import 'package:ganajec/features/suscripcion/domain/usecase/suscribirse_usecase.dart';
import 'package:ganajec/features/suscripcion/data/datasource/payment_remote_ds.dart';
import 'package:ganajec/features/suscripcion/presentation/shared/utils/format_utils.dart';

enum ElegirPlanStatus { idle, loading, subscribing, subscribed, error }

class ElegirPlanViewModel extends ChangeNotifier {
  final GetSuscripcionUseCase _getSuscripcion;
  final GetPlanesUseCase _getPlanes;
  final SuscribirseUseCase _suscribirse;
  final PaymentRemoteDataSource _paymentDs;

  ElegirPlanViewModel({
    required GetSuscripcionUseCase getSuscripcion,
    required GetPlanesUseCase getPlanes,
    required SuscribirseUseCase suscribirse,
    required PaymentRemoteDataSource paymentDs,
    PlanTipo? planInicial,
  })  : _getSuscripcion = getSuscripcion,
        _getPlanes = getPlanes,
        _suscribirse = suscribirse,
        _paymentDs = paymentDs,
        _planSeleccionado = planInicial ?? PlanTipo.pro;

  ElegirPlanStatus _status = ElegirPlanStatus.idle;
  List<Plan> _planes = [];
  SuscripcionInfo? _suscripcion;
  PlanTipo _planSeleccionado;
  bool _esPagoAnual = false;
  String? _error;
  String? _clientSecret;
  String? _paymentIntentId;
  String? _planBackendId;
  int _montoCentavos = 0;
  Map<String, dynamic>? _respuestaConfirmacion;

  ElegirPlanStatus get status => _status;
  bool get isLoading => _status == ElegirPlanStatus.loading;
  bool get isSubscribing => _status == ElegirPlanStatus.subscribing;
  List<Plan> get planes => _planes;
  SuscripcionInfo? get suscripcion => _suscripcion;
  PlanTipo get planSeleccionado => _planSeleccionado;
  bool get esPagoAnual => _esPagoAnual;
  String? get error => _error;
  String? get clientSecret => _clientSecret;
  String? get paymentIntentId => _paymentIntentId;
  Map<String, dynamic>? get respuestaConfirmacion => _respuestaConfirmacion;

  PlanTipo? get planActualTipo => _suscripcion?.planActual.tipo;

  Plan? get planSeleccionadoObj => _planes.isEmpty
      ? null
      : _planes.cast<Plan?>().firstWhere(
          (p) => p!.tipo == _planSeleccionado,
          orElse: () => _planes.isNotEmpty ? _planes.first : null,
        );

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
    return 'Suscribirme · \$${formatNum(precio)} / $periodo';
  }

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

  Future<void> _cargarPlanBackendId() async {
    try {
      debugPrint('[VM] Cargando planes del backend...');
      final planes = await _paymentDs.fetchPlanes();
      debugPrint('[VM] Planes recibidos: ${planes.length}');
      for (final p in planes) {
        debugPrint('[VM] Plan: ${p.toString()}');
      }
      final busqueda = _planSeleccionado == PlanTipo.pro ? 'pro' : 'gratuito';
      for (final p in planes) {
        final nombre = (p['nombre'] ?? p['name'] ?? '').toString().toLowerCase();
        if (nombre.contains(busqueda)) {
          _planBackendId = p['id'] as String;
          debugPrint('[VM] Plan backend ID encontrado: $_planBackendId');
          return;
        }
      }
      if (planes.isNotEmpty) {
        _planBackendId = planes.last['id'] as String;
        debugPrint('[VM] Usando último plan: $_planBackendId');
      } else {
        debugPrint('[VM] WARNING: No se recibieron planes del backend');
      }
    } catch (e) {
      debugPrint('[VM] Error cargando plan backend: $e');
    }
  }

  Future<String?> obtenerClientSecret() async {
    final p = planSeleccionadoObj;
    if (p == null || p.esGratuito) return null;
    _montoCentavos = _esPagoAnual ? p.precioAnual * 100 : p.precioMensual * 100;
    _clientSecret = await _paymentDs.createPaymentIntent(_montoCentavos, 'mxn');
    final parts = _clientSecret?.split('_secret_');
    _paymentIntentId = parts != null && parts.length == 2 ? parts[0] : null;
    await _cargarPlanBackendId();
    return _clientSecret;
  }

  Future<bool> confirmarSuscripcion() async {
    final p = planSeleccionadoObj;
    if (p == null || p.esGratuito) return false;
    debugPrint('[VM] confirmarSuscripcion: paymentIntentId=$_paymentIntentId, planBackendId=$_planBackendId, monto=$_montoCentavos');
    if (_paymentIntentId == null || _planBackendId == null) {
      _error = 'Faltan datos para confirmar el pago: paymentIntentId=${_paymentIntentId != null ? "OK" : "NULL"}, planId=${_planBackendId != null ? "OK" : "NULL"}';
      _status = ElegirPlanStatus.error;
      notifyListeners();
      return false;
    }
    _status = ElegirPlanStatus.subscribing;
    _error = null;
    notifyListeners();
    try {
      _respuestaConfirmacion = await _suscribirse(
        paymentIntentId: _paymentIntentId!,
        planId: _planBackendId!,
        monto: _montoCentavos,
        moneda: 'mxn',
      );
      _status = ElegirPlanStatus.subscribed;
      notifyListeners();
      return true;
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
