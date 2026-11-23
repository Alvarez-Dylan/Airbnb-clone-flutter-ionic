// Tarjeta flotante sobre el mapa con el resumen de la busqueda actual.
// Lee BusquedaProvider de solo lectura; tocarla vuelve a la pantalla de busqueda.
import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../repository/busqueda_provider.dart';
import '../utils/conversiones.dart';

class BarraResumenMapa extends StatelessWidget {
  final BusquedaProvider busquedaProvider;

  const BarraResumenMapa({super.key, required this.busquedaProvider});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textoHuespedes = pluralizar(busquedaProvider.huespedes, 'huésped', 'huéspedes');
    final llegada = busquedaProvider.fechaLlegada;
    final salida = busquedaProvider.fechaSalida;
    final resumen = (llegada != null && salida != null)
        ? '$textoHuespedes · ${formatearFechaCorta(llegada)} – ${formatearFechaCorta(salida)}'
        : textoHuespedes;

    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pop(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
                foregroundColor: colorScheme.primary,
                child: const Icon(Icons.search),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      busquedaProvider.ciudad,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      resumen,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: colorTextoSecundario, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
