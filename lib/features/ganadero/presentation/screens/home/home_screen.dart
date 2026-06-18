import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/network/api_client.dart';
import 'package:ganajec/core/network/token_storage.dart';
import 'package:ganajec/features/ganadero/presentation/viewmodels/home_viewmodel.dart';
import 'home_components.dart';
import 'package:ganajec/core/router/app_router.dart';

enum HomeTab { inicio, buscar, registrar, reportes, perfil }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasShownUnirseDialog = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<HomeViewModel>().cargarDatos(),
    );
  }

  void _onTabSelected(int index) {
    final tab = HomeTab.values[index];
    switch (tab) {
      case HomeTab.inicio:
        break;
      case HomeTab.buscar:
        context.push(AppRoutes.alertas);
        break;
      case HomeTab.registrar:
        context.push(AppRoutes.registroBovino);
      case HomeTab.reportes:
        context.push(AppRoutes.historial);
        break;
      case HomeTab.perfil:
        context.push(AppRoutes.perfil);
        break;
    }
  }

  Future<void> _verificarUnirseRancho() async {
    if (_hasShownUnirseDialog) return;
    _hasShownUnirseDialog = true;

    try {
      final userId = TokenStorage.userId;
      if (userId == null || userId.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarDialogoUnirse());
        return;
      }
      final dio = ApiClient.instance;
      final res = await dio.get('/ganadero/$userId');
      final ranchoId = res.data['rancho_id'] as String?;
      if (ranchoId != null && ranchoId.isNotEmpty) {
        await TokenStorage.saveRanchoId(ranchoId);
        return;
      }
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) => _mostrarDialogoUnirse());
  }

  Future<void> _resolverConflictoRancho(BuildContext dialogCtx) async {
    final userId = TokenStorage.userId;
    if (userId == null || userId.isEmpty) return;

    try {
      final dio = ApiClient.instance;
      final res = await dio.get('/ganadero/$userId/bovinos');
      final bovinos = res.data as List?;
      if (bovinos != null && bovinos.isNotEmpty) {
        final ranchoId = bovinos[0]['rancho_id'] as String?;
        if (ranchoId != null && ranchoId.isNotEmpty) {
          await TokenStorage.saveRanchoId(ranchoId);
          if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
          context.read<HomeViewModel>().cargarDatos();
          return;
        }
      }
      await TokenStorage.saveRanchoId('dummy');
      if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
      context.read<HomeViewModel>().cargarDatos();
    } catch (_) {
      if (dialogCtx.mounted) {
        ScaffoldMessenger.of(dialogCtx).showSnackBar(
          const SnackBar(content: Text('Error al verificar tu rancho')),
        );
      }
    }
  }

  Future<void> _mostrarDialogoUnirse() {
    final controller = TextEditingController();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Únete a tu rancho'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingresa el código que te dio el dueño de tu rancho'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                hintText: 'Código de invitación',
                border: OutlineInputBorder(),
                counterText: '',
              ),
              maxLength: 8,
              onChanged: (v) {
                final upper = v.toUpperCase();
                if (upper != v) {
                  controller.value = TextEditingValue(
                    text: upper,
                    selection: TextSelection.collapsed(offset: upper.length),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final codigo = controller.text.trim().toUpperCase();
              if (codigo.length != 8) return;

              try {
                final dio = ApiClient.instance;
                final res = await dio.post('/ganadero/unirse-rancho', data: {
                  'codigo_invitacion': codigo,
                });
                final ranchoId = res.data['rancho']['id'] as String;
                await TokenStorage.saveRanchoId(ranchoId);
                if (ctx.mounted) Navigator.of(ctx).pop();
                context.read<HomeViewModel>().cargarDatos();
              } on DioException catch (e) {
                if (e.response?.statusCode == 409) {
                  await _resolverConflictoRancho(ctx);
                  return;
                }
                final msg = e.response?.data?['message'] as String? ?? 'Código inválido';
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Unirse'),
          ),
        ],
      ),
    );
  }

  String get _nombreUsuario => TokenStorage.nombre ?? 'Usuario';

  String _calcularIniciales(String nombre) {
    final partes = nombre.trim().split(RegExp(r'\s+'));
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    if (partes.length == 1 && partes[0].isNotEmpty) {
      return partes[0].substring(0, 1).toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final colors = Theme.of(context).colorScheme;
    final nombre = _nombreUsuario;
    final iniciales = _calcularIniciales(nombre);

    if (!vm.isLoading) _verificarUnirseRancho();

    return Scaffold(
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => context.read<HomeViewModel>().cargarDatos(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Buenos días,',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: colors.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    nombre,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => context.push(AppRoutes.alertas),
                              icon: const Icon(Icons.notifications_outlined),
                            ),
                            const SizedBox(width: 8),
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: colors.primaryContainer,
                              child: Text(
                                iniciales,
                                style: TextStyle(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.all(24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          HomeResumen(resumen: vm.resumen),
                          const SizedBox(height: 16),
                          HomeAlertas(alertas: vm.alertas),
                          const SizedBox(height: 8),
                          HomeMiHato(
                            animales: vm.animales,
                            alertas: vm.alertas,
                            onVerTodos: () {},
                            onAnimalTap: (animal) => context.push(
                              AppRoutes.detalleBovino,
                              extra: animal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                              onPressed: () => context.push(AppRoutes.registroBovino),
                            icon: const Icon(Icons.add),
                            label: const Text('Registrar bovino'),
                          ),
                          const SizedBox(height: 16),
                          HomePredicciones(
                            predicciones: vm.predicciones,
                            onVerHistorial: () =>
                                context.push(AppRoutes.historial),
                          ),
                          const SizedBox(height: 24),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'Registrar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}