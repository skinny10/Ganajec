import 'package:flutter/material.dart';
import '../../domain/entities/auditoria.dart';

enum AuditoriaState { initial, loading, loaded, error }

class AuditoriaViewModel extends ChangeNotifier {
  AuditoriaState _state = AuditoriaState.initial;
  List<RegistroAuditoria> _registros = [];
  AuditoriaStats? _stats;

  AuditoriaState get state => _state;
  List<RegistroAuditoria> get registros => _registros;
  AuditoriaStats? get stats => _stats;

  Future<void> cargarAuditoria() async {
    _state = AuditoriaState.loading;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));

    _stats = const AuditoriaStats(
      totalAccesos: 245,
      periodo: 'Hoy',
      usuariosActivos: 8,
    );

    _registros = [
      const RegistroAuditoria(
        id: '1',
        hora: '10:24',
        nombreUsuario: 'Juan Perez',
        accion: 'Inicio de sesion',
        detalle: 'Acceso desde dispositivo iOS',
        tipo: TipoAcceso.login,
      ),
      const RegistroAuditoria(
        id: '2',
        hora: '10:18',
        nombreUsuario: 'Maria Lopez',
        accion: 'Registro de bovino',
        detalle: 'Arete: MX-2024-0042',
        tipo: TipoAcceso.modificacion,
      ),
      const RegistroAuditoria(
        id: '3',
        hora: '10:10',
        nombreUsuario: 'Carlos Ramirez',
        accion: 'Consulta de rancho',
        detalle: 'Rancho: El Porvenir',
        tipo: TipoAcceso.consulta,
      ),
      const RegistroAuditoria(
        id: '4',
        hora: '09:58',
        nombreUsuario: 'Administrador',
        accion: 'Modificacion de permisos',
        detalle: 'Rol: ganadero -> veterinario',
        tipo: TipoAcceso.modificacion,
      ),
      const RegistroAuditoria(
        id: '5',
        hora: '09:45',
        nombreUsuario: 'Sistema',
        accion: 'Reporte de alertas',
        detalle: '3 alertas generadas por IA',
        tipo: TipoAcceso.sistema,
      ),
    ];

    _state = AuditoriaState.loaded;
    notifyListeners();
  }
}
