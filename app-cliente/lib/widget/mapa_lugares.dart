// FlutterMap con un marcador por lugar, mostrando su precio por noche.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/lugar_model.dart';
import '../utils/conversiones.dart';

// Centro por defecto: Santa Cruz de la Sierra (ver CLAUDE.md).
const _centroDefecto = LatLng(-17.7833, -63.1821);

class MapaLugares extends StatelessWidget {
  final List<LugarModel> lugares;
  final void Function(LugarModel lugar) onTapLugar;

  const MapaLugares({super.key, required this.lugares, required this.onTapLugar});

  @override
  Widget build(BuildContext context) {
    final centro = lugares.isEmpty
        ? _centroDefecto
        : LatLng(lugares.first.latitud, lugares.first.longitud);

    return FlutterMap(
      options: MapOptions(initialCenter: centro, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          // La API de tiles exige identificar la app que hace los pedidos.
          userAgentPackageName: 'bo.edu.nur.bnb_cliente',
        ),
        MarkerLayer(
          markers: lugares.map((lugar) {
            return Marker(
              point: LatLng(lugar.latitud, lugar.longitud),
              width: 90,
              height: 50,
              child: GestureDetector(
                onTap: () => onTapLugar(lugar),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        formatearPrecio(lugar.precioNoche),
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    Icon(Icons.location_pin, color: Theme.of(context).colorScheme.primary),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
