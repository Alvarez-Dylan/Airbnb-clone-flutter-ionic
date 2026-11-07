// Estados cargando / error / vacio, reutilizable en toda pantalla que pide datos.
import 'package:flutter/material.dart';

class VistaEstado extends StatelessWidget {
  final bool cargando;
  final String? error;
  final bool vacio;
  final String mensajeVacio;
  final Widget child;

  const VistaEstado({
    super.key,
    required this.cargando,
    required this.error,
    required this.vacio,
    required this.mensajeVacio,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text(error!));
    }
    if (vacio) {
      return Center(child: Text(mensajeVacio));
    }
    return child;
  }
}
