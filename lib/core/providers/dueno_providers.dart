import 'package:provider/provider.dart';
import 'package:ganajec/features/dueno/presentation/viewmodels/dashboard_viewmodel.dart';

List<ChangeNotifierProvider> duenoProviders = [
  ChangeNotifierProvider<DashboardViewModel>(
    create: (_) => DashboardViewModel(),
  ),
];
