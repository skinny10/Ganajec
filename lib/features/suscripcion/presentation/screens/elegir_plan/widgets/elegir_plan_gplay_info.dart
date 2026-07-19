import 'package:flutter/material.dart';

class ElegirPlanGPlayInfo extends StatelessWidget {
  const ElegirPlanGPlayInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('▶️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: tt.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
                children: [
                  const TextSpan(text: 'El pago se procesa de forma segura a través de '),
                  TextSpan(
                    text: 'Stripe',
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: cs.onSurface),
                  ),
                  const TextSpan(
                    text:
                        '. Tu suscripción se renueva automáticamente. Cancela cuando quieras.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
