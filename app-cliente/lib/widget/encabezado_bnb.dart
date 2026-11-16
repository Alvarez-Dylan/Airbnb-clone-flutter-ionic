// Encabezado con el icono de la marca y el nombre "bnb", reutilizado en login
// y registro con un subtitulo distinto segun la pantalla.
import 'package:flutter/material.dart';

import '../config/tema.dart';

class EncabezadoBnb extends StatelessWidget {
  final String subtitulo;

  const EncabezadoBnb({super.key, required this.subtitulo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.home_work_rounded,
            color: Theme.of(context).colorScheme.onPrimary,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'bnb',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(subtitulo, style: const TextStyle(color: colorTextoSecundario)),
      ],
    );
  }
}
