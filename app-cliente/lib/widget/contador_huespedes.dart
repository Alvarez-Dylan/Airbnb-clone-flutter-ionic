// Botones -/+ dentro de un contenedor con borde, para elegir una cantidad
// (huespedes) sin escribir un numero a mano.
import 'package:flutter/material.dart';

class ContadorHuespedes extends StatelessWidget {
  final int cantidad;
  final VoidCallback? onQuitar;
  final VoidCallback onAgregar;

  const ContadorHuespedes({
    super.key,
    required this.cantidad,
    required this.onQuitar,
    required this.onAgregar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove), onPressed: onQuitar),
          Text('$cantidad'),
          IconButton(icon: const Icon(Icons.add), onPressed: onAgregar),
        ],
      ),
    );
  }
}
