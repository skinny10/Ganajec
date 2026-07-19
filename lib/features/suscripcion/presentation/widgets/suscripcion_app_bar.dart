import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuscripcionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String fallbackRoute;

  const SuscripcionAppBar({
    super.key,
    required this.title,
    required this.fallbackRoute,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return AppBar(
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => context.canPop()
            ? context.pop()
            : context.go(fallbackRoute),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Icon(Icons.chevron_left, color: cs.onSurface, size: 20),
        ),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: tt.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.3,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: cs.outlineVariant),
      ),
    );
  }
}
