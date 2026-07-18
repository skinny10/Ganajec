import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/mis_ganaderos_viewmodel.dart';
import '../../widgets/rancho_modal.dart';

class MisGanaderosScreen extends StatefulWidget {
  const MisGanaderosScreen({super.key});

  @override
  State<MisGanaderosScreen> createState() => _MisGanaderosScreenState();
}

class _MisGanaderosScreenState extends State<MisGanaderosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MisGanaderosViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MisGanaderosViewModel>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Icon(Icons.chevron_left_rounded,
                color: cs.onSurface, size: 20),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Mis ganaderos',
          style: tt.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              final creado = await mostrarRanchoModal(
                context,
                initialTab: 1,
              );
              if (creado && context.mounted) {
                context.read<MisGanaderosViewModel>().cargar();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 4, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: cs.tertiary.withOpacity(0.35)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: cs.tertiary, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Crear rancho',
                    style: tt.labelSmall?.copyWith(
                      color: cs.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () => context.read<MisGanaderosViewModel>().cargar(),
            icon: Icon(Icons.refresh_outlined,
                color: cs.onSurfaceVariant, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: cs.outlineVariant),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final agregado = await context.push<bool>(AppRoutes.registrarGanadero);
          if (agregado == true && context.mounted) {
            context.read<MisGanaderosViewModel>().cargar();
          }
        },
        backgroundColor: cs.tertiary,
        foregroundColor: cs.onTertiary,
        icon: const Icon(Icons.person_add_outlined, size: 18),
        label: Text('Registrar ganadero',
            style: tt.labelMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<MisGanaderosViewModel>().cargar(),
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 40),
                children: [
                  if (vm.error != null)
                    _ErrorBanner(
                      message: vm.error!,
                      onDismiss: () =>
                          context.read<MisGanaderosViewModel>().clearError(),
                    ),

                  if (vm.todosRanchos.length > 1)
                    _RanchoSelector(
                      ranchos: vm.todosRanchos,
                      seleccionado: vm.ranchoActivo,
                      onSeleccionar: (r) =>
                          context.read<MisGanaderosViewModel>().seleccionarRancho(r),
                    ),

                  if (vm.ranchoActivo != null)
                    _RanchoHeaderCard(rancho: vm.ranchoActivo!),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Ganaderos (${vm.ganaderos.length})',
                      style: tt.labelSmall?.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (vm.cargandoGanaderos)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (vm.ganaderos.isEmpty)
                    _EmptyGanaderos()
                  else
                    ...vm.ganaderos.map(
                      (g) => _GanaderoTile(
                        ganadero: g,
                        onEliminar: () => _confirmarEliminar(context, g),
                        onMover: () => _mostrarMoverModal(context, g),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Future<void> _confirmarEliminar(BuildContext context, GanaderoItem g) async {
    final cs = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar ganadero'),
        content: Text(
            '¿Deseas eliminar a ${g.nombre} del rancho? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: cs.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final exito =
          await context.read<MisGanaderosViewModel>().eliminarGanadero(g.id);
      if (context.mounted) {
        final cs2 = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                exito ? '${g.nombre} eliminado del rancho' : 'Error al eliminar'),
            backgroundColor: exito ? cs2.tertiary : cs2.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _mostrarMoverModal(BuildContext context, GanaderoItem g) async {
    final vm = context.read<MisGanaderosViewModel>();
    final otros = vm.otrosRanchos;

    final nuevoRanchoId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MoverModal(ganadero: g, otrosRanchos: otros),
    );

    if (nuevoRanchoId != null && nuevoRanchoId.isNotEmpty && context.mounted) {
      final exito = await context
          .read<MisGanaderosViewModel>()
          .moverGanadero(g.id, nuevoRanchoId);
      if (context.mounted) {
        final cs2 = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito
                ? '${g.nombre} movido al nuevo rancho'
                : 'Error al mover'),
            backgroundColor: exito ? cs2.tertiary : cs2.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ── Widgets ──────────────────────────────────────────────────────────────────

class _RanchoHeaderCard extends StatelessWidget {
  final RanchoInfo rancho;
  const _RanchoHeaderCard({required this.rancho});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.tertiaryContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.tertiary.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🏡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rancho.nombre,
                        style: tt.bodyMedium?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      Text(
                        '${rancho.municipio}, ${rancho.estado}',
                        style: tt.bodySmall?.copyWith(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => context.push(
                AppRoutes.ranchoDashboard,
                extra: rancho,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: cs.tertiary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_outlined,
                        color: cs.onTertiary, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Ver detalle del rancho',
                      style: tt.labelSmall?.copyWith(
                        color: cs.onTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Código de invitación',
              style: tt.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () {
                Clipboard.setData(
                    ClipboardData(text: rancho.codigoInvitacion));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Código copiado al portapapeles'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.tertiary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rancho.codigoInvitacion,
                      style: tt.bodyMedium?.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: cs.tertiary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.copy_outlined, color: cs.tertiary, size: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GanaderoTile extends StatelessWidget {
  final GanaderoItem ganadero;
  final VoidCallback onEliminar;
  final VoidCallback onMover;

  const _GanaderoTile({
    required this.ganadero,
    required this.onEliminar,
    required this.onMover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final initials = () {
      final parts = ganadero.nombre.trim().split(RegExp(r'\s+'));
      if (parts.length >= 2)
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return ganadero.nombre
          .substring(0, ganadero.nombre.length >= 2 ? 2 : 1)
          .toUpperCase();
    }();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: cs.tertiaryContainer,
            child: Text(
              initials,
              style: tt.labelMedium?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          title: Text(
            ganadero.nombre,
            style: tt.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ganadero.email,
                  style: tt.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  )),
              const SizedBox(height: 2),
              Text(
                '${ganadero.totalBovinos} bovino${ganadero.totalBovinos != 1 ? 's' : ''}',
                style: tt.labelSmall?.copyWith(
                  fontSize: 11,
                  color: cs.tertiary,
                ),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_outlined,
                color: cs.onSurfaceVariant, size: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            onSelected: (v) {
              if (v == 'mover') onMover();
              if (v == 'eliminar') onEliminar();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'mover',
                child: Row(children: [
                  Icon(Icons.swap_horiz_outlined,
                      size: 16, color: cs.onSurface),
                  const SizedBox(width: 8),
                  Text('Mover a otro rancho',
                      style: tt.bodySmall?.copyWith(fontSize: 13)),
                ]),
              ),
              PopupMenuItem(
                value: 'eliminar',
                child: Row(children: [
                  Icon(Icons.person_remove_outlined,
                      size: 16, color: cs.error),
                  const SizedBox(width: 8),
                  Text('Eliminar del rancho',
                      style: tt.bodySmall?.copyWith(
                          fontSize: 13, color: cs.error)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGanaderos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('👨‍🌾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text(
            'Aún no hay ganaderos en este rancho',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Comparte el código de invitación para que tus ganaderos se unan.',
            textAlign: TextAlign.center,
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(message,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onErrorContainer,
                    fontSize: 13,
                  )),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: cs.onErrorContainer, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selector horizontal de ranchos ──────────────────────────────────────────

class _RanchoSelector extends StatelessWidget {
  final List<RanchoInfo> ranchos;
  final RanchoInfo? seleccionado;
  final void Function(RanchoInfo) onSeleccionar;

  const _RanchoSelector({
    required this.ranchos,
    required this.seleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MIS RANCHOS',
            style: tt.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ranchos.map((r) {
                final activo = r.id == seleccionado?.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSeleccionar(r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: activo
                            ? cs.tertiary
                            : cs.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: activo ? cs.tertiary : cs.outlineVariant,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '🏡',
                            style: TextStyle(fontSize: activo ? 14 : 13),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            r.nombre,
                            style: tt.labelMedium?.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: activo
                                  ? cs.onTertiary
                                  : cs.onSurface,
                            ),
                          ),
                          if (activo) ...[
                            const SizedBox(width: 4),
                            Icon(Icons.check_circle,
                                color: cs.onTertiary, size: 13),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Modal mover ganadero ─────────────────────────────────────────────────────

class _MoverModal extends StatefulWidget {
  final GanaderoItem ganadero;
  final List<RanchoInfo> otrosRanchos;
  const _MoverModal({required this.ganadero, required this.otrosRanchos});

  @override
  State<_MoverModal> createState() => _MoverModalState();
}

class _MoverModalState extends State<_MoverModal> {
  RanchoInfo? _seleccionado;
  final _idCtrl = TextEditingController();

  @override
  void dispose() {
    _idCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final tieneOpciones = widget.otrosRanchos.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Mover a otro rancho',
            style: tt.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona el rancho destino para ${widget.ganadero.nombre}',
            style: tt.bodySmall?.copyWith(
              fontSize: 13,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),

          if (tieneOpciones)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RanchoInfo>(
                  isExpanded: true,
                  hint: Text(
                    'Selecciona un rancho',
                    style: tt.bodySmall?.copyWith(
                      fontSize: 14,
                      color: cs.outline,
                    ),
                  ),
                  value: _seleccionado,
                  items: widget.otrosRanchos
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              '${r.nombre} — ${r.municipio}',
                              style: tt.bodyMedium?.copyWith(fontSize: 14),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _seleccionado = v),
                ),
              ),
            )
          else ...[
            Text(
              'No tienes otros ranchos. Ingresa el ID manualmente:',
              style: tt.bodySmall?.copyWith(
                fontSize: 12,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: TextField(
                controller: _idCtrl,
                style: tt.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'ID del rancho destino',
                  prefixIcon: Icon(Icons.home_outlined,
                      color: cs.onSurfaceVariant, size: 18),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: cs.outlineVariant),
                  ),
                  child: Text('Cancelar',
                      style: tt.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final id = tieneOpciones
                        ? (_seleccionado?.id ?? '')
                        : _idCtrl.text.trim();
                    if (id.isNotEmpty) Navigator.pop(context, id);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.tertiary,
                    foregroundColor: cs.onTertiary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Mover',
                      style: tt.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
