// Estados cargando / error / vacio, reutilizable en toda pantalla que pide datos.
import 'package:flutter/material.dart';

import '../config/tema.dart';

class VistaEstado extends StatelessWidget {
  final bool cargando;
  final String? error;
  final bool vacio;
  final String mensajeVacio;
  // Icono del estado vacio (cada pantalla elige el que tenga sentido, ej.
  // Icons.search_off en resultados). El de error siempre es el mismo: casi
  // todos los errores de esta app son de conexion con la API.
  final IconData? icono;
  final Widget child;

  const VistaEstado({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.mensajeVacio,
    this.icono,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _mensajeConIcono(Icons.wifi_off, error!);
    }
    if (vacio) {
      return _mensajeConIcono(icono ?? Icons.inbox_outlined, mensajeVacio);
    }
    return child;
  }

  Widget _mensajeConIcono(IconData icono, String mensaje) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: colorTextoSecundario),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
