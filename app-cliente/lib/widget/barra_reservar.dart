// Barra inferior fija del detalle de un lugar: precio por noche a la
// izquierda y el boton "Reservar" a la derecha (RC-13).
import 'package:flutter/material.dart';

import '../utils/conversiones.dart';

class BarraReservar extends StatelessWidget {
  final double precioNoche;
  final VoidCallback onReservar;

  const BarraReservar({super.key, required this.precioNoche, required this.onReservar});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${formatearPrecio(precioNoche)} noche',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton(onPressed: onReservar, child: const Text('Reservar')),
            ],
          ),
        ),
      ),
    );
  }
}
