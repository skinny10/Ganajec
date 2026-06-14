import 'package:provider/provider.dart';
import 'package:ganajec/features/dueno/presentation/viewmodels/dashboard_viewmodel.dart';
import 'package:ganajec/features/dueno/domain/usecases/get_dashboard_dueno_usecase.dart';
import 'package:ganajec/features/dueno/data/repositories/dueno_repo_impl.dart';
import 'package:ganajec/features/dueno/data/datasources/dueno_remote_ds.dart';

List<ChangeNotifierProvider> duenoProviders = [
  ChangeNotifierProvider<DashboardViewModel>(
    create: (_) => DashboardViewModel(
      getDashboardUsecase: GetDashboardDuenoUsecase(
        DuenoRepoImpl(
          DuenoRemoteDataSource(),
        ),
      ),
    ),
  ),
];
