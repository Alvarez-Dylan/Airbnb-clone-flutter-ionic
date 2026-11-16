// Item de la lista de "mis reservas": foto, nombre del lugar, fechas, noches,
// anfitrion y precio total (los datos que pide RC-16).
import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../model/reserva_model.dart';
import '../utils/conversiones.dart';
import 'foto_lugar.dart';

class ReservaCard extends StatelessWidget {
  final ReservaModel reserva;

  const ReservaCard({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: FotoLugar(url: reserva.primeraFotoUrl, radio: 12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reserva.nombreLugar,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: colorTextoSecundario,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${formatearFecha(reserva.fechaInicio)} a ${formatearFecha(reserva.fechaFin)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: colorTextoSecundario),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reserva.noches} noches · Anfitrión: ${reserva.nombreAnfitrion}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: colorTextoSecundario),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatearPrecio(reserva.precioTotal),
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
