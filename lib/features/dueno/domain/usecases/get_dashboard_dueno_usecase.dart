import '../entities/dueno_dashboard.dart';
import '../repositories/dueno_repository.dart';

class GetDashboardDuenoUsecase {
  final DuenoRepository repository;

  GetDashboardDuenoUsecase(this.repository);

  Future<DuenoDashboard> call(String duenoId) {
    return repository.getDashboard(duenoId);
  }
}
