import '../entities/dueno_dashboard.dart';

abstract class DuenoRepository {
  Future<DuenoDashboard> getDashboard(String duenoId);
  Future<List<GanaderoResumen>> getGanaderos(String duenoId);
}
