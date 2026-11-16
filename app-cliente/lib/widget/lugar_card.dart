// Item de la lista de resultados: primera foto, nombre, descripcion, personas
// y precio por noche (los 5 datos que pide RC-07).
import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../model/lugar_model.dart';
import '../utils/conversiones.dart';
import 'foto_lugar.dart';

class LugarCard extends StatelessWidget {
  final LugarModel lugar;
  final VoidCallback onTap;

  const LugarCard({super.key, required this.lugar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              // Sin radio propio: el Card ya recorta sus esquinas
              // (clipBehavior de tema.dart), asi la foto nace pegada arriba.
              child: FotoLugar(
                url: lugar.fotos.isEmpty ? null : lugar.fotos.first.url,
                radio: 0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lugar.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lugar.descripcion,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: colorTextoSecundario),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline, size: 16, color: colorTextoSecundario),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${lugar.cantPersonas} huéspedes',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: colorTextoSecundario),
                        ),
                      ),
                      Text(
                        '${formatearPrecio(lugar.precioNoche)} noche',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
