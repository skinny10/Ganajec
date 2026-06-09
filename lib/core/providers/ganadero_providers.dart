import 'package:provider/provider.dart';
import 'package:ganajec/features/ganadero/data/datasource/ganadero_remote_ds.dart';
import 'package:ganajec/features/ganadero/data/repositories/ganadero_repo_impl.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_alertas_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_animales_usecase.dart';
import 'package:ganajec/features/ganadero/domain/usecase/get_predicciones_usecase.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';

List<ChangeNotifierProvider> ganaderoProviders = [
  ChangeNotifierProvider<HomeViewModel>(
    create: (_) => HomeViewModel(
      getAnimales: GetAnimalesUseCase(
        GanaderoRepositoryImpl(GanaderoRemoteDataSourceImpl()),
      ),
      getAlertas: GetAlertasUseCase(
        GanaderoRepositoryImpl(GanaderoRemoteDataSourceImpl()),
      ),
      getPredicciones: GetPredicionesUseCase(
        GanaderoRepositoryImpl(GanaderoRemoteDataSourceImpl()),
      ),
    ),
  ),
];