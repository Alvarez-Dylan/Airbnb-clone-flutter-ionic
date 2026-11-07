// Item de la lista de resultados: primera foto, nombre, descripcion, personas y precio.
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';
import '../utils/conversiones.dart';

class LugarCard extends StatelessWidget {
  final LugarModel lugar;
  final VoidCallback onTap;

  const LugarCard({super.key, required this.lugar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: SizedBox(
          width: 56,
          height: 56,
          // Un lugar puede no tener fotos: nunca se usa fotos[0] sin revisar antes.
          child: lugar.fotos.isEmpty
              ? const Icon(Icons.image)
              : Image.network(
                  urlFoto(lugar.fotos[0].url),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                ),
        ),
        title: Text(lugar.nombre),
        subtitle: Text(
          lugar.descripcion,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${lugar.cantPersonas} personas'),
            Text(formatearPrecio(lugar.precioNoche)),
          ],
        ),
      ),
    );
  }
}
