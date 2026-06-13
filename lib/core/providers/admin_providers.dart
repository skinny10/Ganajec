import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/features/admin/data/datasources/admin_remote_ds.dart';
import 'package:ganajec/features/admin/data/repositories/admin_repo_impl.dart';
import 'package:ganajec/features/admin/domain/usecases/get_usuarios_usecase.dart';
import 'package:ganajec/features/admin/presentation/viewmodels/panel_usuarios_viewmodel.dart';

List<ChangeNotifierProvider> adminProviders = [
  ChangeNotifierProvider<PanelUsuariosViewModel>(
    create: (_) => PanelUsuariosViewModel(
      getUsuariosUsecase: GetUsuariosUsecase(
        AdminRepoImpl(
          AdminRemoteDataSource(Dio()),
        ),
      ),
      getStatsUsecase: GetStatsUsecase(
        AdminRepoImpl(
          AdminRemoteDataSource(Dio()),
        ),
      ),
    ),
  ),
];
