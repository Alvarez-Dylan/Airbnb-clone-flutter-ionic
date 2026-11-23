// FlutterMap con un marcador por lugar: pastilla con el precio y, debajo,
// un circulo con icono de casa que marca la coordenada exacta.
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../model/lugar_model.dart';
import '../utils/conversiones.dart';

// Centro por defecto: Santa Cruz de la Sierra (ver CLAUDE.md).
const _centroDefecto = LatLng(-17.7833, -63.1821);

const _altoPastilla = 28.0;
const _separacionMarcador = 4.0;
const _diametroCirculo = 28.0;
const _anchoMarcador = 90.0;
const _altoMarcador = _altoPastilla + _separacionMarcador + _diametroCirculo;

// El Marker se alinea por defecto desde el centro de toda la columna. Esto
// mueve el punto de anclaje al centro del circulo (no de la pastilla), para
// que el circulo quede justo sobre la coordenada real del lugar.
const _centroCirculoY = _altoPastilla + _separacionMarcador + _diametroCirculo / 2;
const _alineacionMarcador = Alignment(0, (_centroCirculoY / _altoMarcador) * 2 - 1);

class MapaLugares extends StatelessWidget {
  final List<LugarModel> lugares;
  final void Function(LugarModel lugar) onTapLugar;

  const MapaLugares({super.key, required this.lugares, required this.onTapLugar});

  @override
  Widget build(BuildContext context) {
    final centro = lugares.isEmpty
        ? _centroDefecto
        : LatLng(lugares.first.latitud, lugares.first.longitud);
    final colorScheme = Theme.of(context).colorScheme;

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
              width: _anchoMarcador,
              height: _altoMarcador,
              alignment: _alineacionMarcador,
              child: GestureDetector(
                // Toca cualquiera de las dos partes (pastilla o circulo): abre el detalle.
                onTap: () => onTapLugar(lugar),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: _altoPastilla,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        // El acento (dorado) es fondo solo para destacar precios.
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.18),
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
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: _separacionMarcador),
                    Container(
                      width: _diametroCirculo,
                      height: _diametroCirculo,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.18),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(Icons.home, color: colorScheme.onPrimary, size: 16),
                    ),
                  ],
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
