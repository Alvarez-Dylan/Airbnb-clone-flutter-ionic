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
            final colorScheme = Theme.of(context).colorScheme;
            return Marker(
              point: LatLng(lugar.latitud, lugar.longitud),
              width: 90,
              height: 32,
              child: GestureDetector(
                onTap: () => onTapLugar(lugar),
                child: Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    formatearPrecio(lugar.precioNoche),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // OpenStreetMap exige mostrar esta atribución sobre el mapa.
        SimpleAttributionWidget(source: const Text('OpenStreetMap contributors')),
      ],
    );
  }
}
