import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ganajec/core/router/app_router.dart';
import '../../viewmodels/mis_ganaderos_viewmodel.dart';

class MisGanaderosScreen extends StatefulWidget {
  const MisGanaderosScreen({super.key});

  @override
  State<MisGanaderosScreen> createState() => _MisGanaderosScreenState();
}

class _MisGanaderosScreenState extends State<MisGanaderosScreen> {
  static const _kBg = Color(0xFFFAFAF7);
  static const _kBorder = Color(0xFFE8E5DC);
  static const _kTextPrimary = Color(0xFF1A1A1A);
  static const _kTextSecondary = Color(0xFF888880);
  static const _kSurface = Color(0xFFFFFFFF);
  static const _kGreen = Color(0xFF2E7D32);
  static const _kGreenLight = Color(0xFFE8F5EF);
  static const _kRed = Color(0xFFC0392B);
  static const _kRedLight = Color(0xFFFDEDEC);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MisGanaderosViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MisGanaderosViewModel>();

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _kBorder),
            ),
            child: const Icon(Icons.chevron_left_rounded,
                color: _kTextPrimary, size: 20),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Mis ganaderos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<MisGanaderosViewModel>().cargar(),
            icon: const Icon(Icons.refresh_outlined,
                color: _kTextSecondary, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _kBorder),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final agregado = await context.push<bool>(
              AppRoutes.registrarGanadero);
          if (agregado == true && context.mounted) {
            context.read<MisGanaderosViewModel>().cargar();
          }
        },
        backgroundColor: _kGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_outlined, size: 18),
        label: const Text('Registrar ganadero',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<MisGanaderosViewModel>().cargar(),
              child: ListView(
                padding: const EdgeInsets.only(top: 16, bottom: 40),
                children: [
                  // Error banner
                  if (vm.error != null)
                    _ErrorBanner(
                      message: vm.error!,
                      onDismiss: () =>
                          context.read<MisGanaderosViewModel>().clearError(),
                    ),

                  // Card del rancho con código
                  if (vm.rancho != null) _RanchoHeaderCard(rancho: vm.rancho!),

                  const SizedBox(height: 12),

                  // Título lista
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Text(
                          'Ganaderos (${vm.ganaderos.length})',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _kTextSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Lista de ganaderos
                  if (vm.ganaderos.isEmpty)
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

  Future<void> _confirmarEliminar(
      BuildContext context, GanaderoItem g) async {
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
            style: TextButton.styleFrom(foregroundColor: _kRed),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      final exito =
          await context.read<MisGanaderosViewModel>().eliminarGanadero(g.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                exito ? '${g.nombre} eliminado del rancho' : 'Error al eliminar'),
            backgroundColor: exito ? _kGreen : _kRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _mostrarMoverModal(
      BuildContext context, GanaderoItem g) async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exito
                ? '${g.nombre} movido al nuevo rancho'
                : 'Error al mover'),
            backgroundColor: exito ? _kGreen : _kRed,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5EF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF2E7D32).withOpacity(0.25)),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        '${rancho.municipio}, ${rancho.estado}',
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF888880)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Botón Ver detalle rancho
            GestureDetector(
              onTap: () => context.push(
                AppRoutes.ranchoDashboard,
                extra: rancho.id,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.dashboard_outlined,
                        color: Colors.white, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Ver detalle del rancho',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Código de invitación',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF888880),
                  letterSpacing: 0.5),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: const Color(0xFF2E7D32).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rancho.codigoInvitacion,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 3,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.copy_outlined,
                        color: Color(0xFF2E7D32), size: 16),
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
    final initials = () {
      final parts =
          ganadero.nombre.trim().split(RegExp(r'\s+'));
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
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE8E5DC)),
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFE8F5EF),
            child: Text(
              initials,
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          title: Text(
            ganadero.nombre,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ganadero.email,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF888880))),
              const SizedBox(height: 2),
              Text(
                '${ganadero.totalBovinos} bovino${ganadero.totalBovinos != 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_outlined,
                color: Color(0xFF888880), size: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            onSelected: (v) {
              if (v == 'mover') onMover();
              if (v == 'eliminar') onEliminar();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'mover',
                child: Row(children: [
                  Icon(Icons.swap_horiz_outlined,
                      size: 16, color: Color(0xFF1A1A1A)),
                  SizedBox(width: 8),
                  Text('Mover a otro rancho',
                      style: TextStyle(fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'eliminar',
                child: Row(children: [
                  Icon(Icons.person_remove_outlined,
                      size: 16, color: Color(0xFFC0392B)),
                  SizedBox(width: 8),
                  Text('Eliminar del rancho',
                      style: TextStyle(
                          fontSize: 13, color: Color(0xFFC0392B))),
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
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const Text('👨‍🌾', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'Aún no hay ganaderos en este rancho',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 6),
          const Text(
            'Comparte el código de invitación para que tus ganaderos se unan.',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 13, color: Color(0xFF888880)),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFDEDEC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: Color(0xFFC0392B), fontSize: 13)),
            ),
            GestureDetector(
              onTap: onDismiss,
              child: const Icon(Icons.close,
                  color: Color(0xFFC0392B), size: 16),
            ),
          ],
        ),
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
    final tieneOpciones = widget.otrosRanchos.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFAFAF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                color: const Color(0xFFE8E5DC),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Mover a otro rancho',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Selecciona el rancho destino para ${widget.ganadero.nombre}',
            style:
                const TextStyle(fontSize: 13, color: Color(0xFF888880)),
          ),
          const SizedBox(height: 16),

          // Dropdown si hay ranchos disponibles, campo de texto si no
          if (tieneOpciones)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E5DC)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<RanchoInfo>(
                  isExpanded: true,
                  hint: const Text(
                    'Selecciona un rancho',
                    style: TextStyle(
                        fontSize: 14, color: Color(0xFFAEADA6)),
                  ),
                  value: _seleccionado,
                  items: widget.otrosRanchos
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              '${r.nombre} — ${r.municipio}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _seleccionado = v),
                ),
              ),
            )
          else ...[
            const Text(
              'No tienes otros ranchos. Ingresa el ID manualmente:',
              style: TextStyle(fontSize: 12, color: Color(0xFF888880)),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8E5DC)),
              ),
              child: TextField(
                controller: _idCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'ID del rancho destino',
                  prefixIcon: Icon(Icons.home_outlined,
                      color: Color(0xFF888880), size: 18),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    side: const BorderSide(color: Color(0xFFE8E5DC)),
                  ),
                  child: const Text('Cancelar',
                      style: TextStyle(color: Color(0xFF888880))),
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
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Mover',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
