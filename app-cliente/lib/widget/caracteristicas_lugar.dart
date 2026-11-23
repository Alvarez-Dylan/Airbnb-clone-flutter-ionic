// Fila de Chips con icono para las caracteristicas del lugar que pide RC-12:
// personas, camas, banios, habitaciones, wifi y parqueo.
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';
import '../utils/conversiones.dart';

class CaracteristicasLugar extends StatelessWidget {
  final LugarModel lugar;

  const CaracteristicasLugar({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    final parqueo = lugar.cantVehiculosParqueo > 0
        ? 'Parqueo para ${pluralizar(lugar.cantVehiculosParqueo, 'vehículo', 'vehículos')}'
        : 'No tiene parqueo';

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        Chip(
          avatar: const Icon(Icons.people_outline, size: 18),
          label: Text(pluralizar(lugar.cantPersonas, 'persona', 'personas')),
        ),
        Chip(
          avatar: const Icon(Icons.bed_outlined, size: 18),
          label: Text(pluralizar(lugar.cantCamas, 'cama', 'camas')),
        ),
        Chip(
          avatar: const Icon(Icons.bathtub_outlined, size: 18),
          label: Text(pluralizar(lugar.cantBanios, 'baño', 'baños')),
        ),
        Chip(
          avatar: const Icon(Icons.door_front_door_outlined, size: 18),
          label: Text(pluralizar(lugar.cantHabitaciones, 'habitación', 'habitaciones')),
        ),
        Chip(
          avatar: Icon(lugar.tieneWifi ? Icons.wifi : Icons.wifi_off, size: 18),
          label: Text(lugar.tieneWifi ? 'Wifi: Sí' : 'Wifi: No'),
        ),
        Chip(
          avatar: const Icon(Icons.local_parking_outlined, size: 18),
          label: Text(parqueo),
        ),
      ],
    );
  }
}
