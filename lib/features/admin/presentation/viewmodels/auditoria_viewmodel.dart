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
        accion: 'Inicio sesion',
        tipo: TipoAcceso.login,
      ),
      const RegistroAuditoria(
        id: '2',
        hora: '10:18',
        nombreUsuario: 'Maria Lopez',
        accion: 'Registro bovino',
        tipo: TipoAcceso.modificacion,
      ),
      const RegistroAuditoria(
        id: '3',
        hora: '10:10',
        nombreUsuario: 'Carlos Ramirez',
        accion: 'Informacion del rancho',
        tipo: TipoAcceso.consulta,
      ),
      const RegistroAuditoria(
        id: '4',
        hora: '09:58',
        nombreUsuario: 'Administrador',
        accion: 'Modifico permisos',
        tipo: TipoAcceso.modificacion,
      ),
      const RegistroAuditoria(
        id: '5',
        hora: '09:45',
        nombreUsuario: 'Sistema',
        accion: 'Genero reporte de alertas IA',
        tipo: TipoAcceso.sistema,
      ),
    ];

    _state = AuditoriaState.loaded;
    notifyListeners();
  }
}
