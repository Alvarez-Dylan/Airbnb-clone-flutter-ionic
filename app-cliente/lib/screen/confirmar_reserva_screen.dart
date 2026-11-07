// Confirmar reserva. Temporal hasta la Fase C5.
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';

class ConfirmarReservaScreen extends StatelessWidget {
  final LugarModel lugar;

  const ConfirmarReservaScreen({super.key, required this.lugar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: const Center(child: Text('Pantalla temporal - Fase C4')),
    );
  }
}
