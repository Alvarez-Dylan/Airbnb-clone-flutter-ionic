// Imagen de la foto de un lugar, con manejo de error (foto rota) y
// placeholder cuando no hay foto. Reutilizado por LugarCard, GaleriaFotos,
// ConfirmarReservaScreen y ReservaCard en vez de repetir el mismo Image.network.
import 'package:flutter/material.dart';

import '../utils/conversiones.dart';

class FotoLugar extends StatelessWidget {
  final String? url;
  final double radio;
  final BoxFit fit;

  const FotoLugar({super.key, required this.url, this.radio = 16, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radio),
      child: url == null
          ? const _PlaceholderFoto()
          : Image.network(
              urlFoto(url!),
              fit: fit,
              errorBuilder: (context, error, stackTrace) => const _PlaceholderFoto(),
            ),
    );
  }
}

class _PlaceholderFoto extends StatelessWidget {
  const _PlaceholderFoto();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.image, color: colorScheme.onSurfaceVariant),
    );
  }
}
