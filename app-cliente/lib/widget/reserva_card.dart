// Item de la lista de "mis reservas": foto, nombre del lugar, noches,
// fechas, anfitrion y precio total.
import 'package:flutter/material.dart';

import '../model/reserva_model.dart';
import '../utils/conversiones.dart';

class ReservaCard extends StatelessWidget {
  final ReservaModel reserva;

  const ReservaCard({super.key, required this.reserva});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: SizedBox(
          width: 56,
          height: 56,
          child: reserva.primeraFotoUrl == null
              ? const Icon(Icons.image)
              : Image.network(
                  urlFoto(reserva.primeraFotoUrl!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                ),
        ),
        title: Text(reserva.nombreLugar),
        subtitle: Text(
          '${reserva.noches} noches · ${formatearFecha(reserva.fechaInicio)} a '
          '${formatearFecha(reserva.fechaFin)}\nAnfitrion: ${reserva.nombreAnfitrion}',
        ),
        isThreeLine: true,
        trailing: Text(formatearPrecio(reserva.precioTotal)),
      ),
    );
  }
}
