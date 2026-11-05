// Punto de entrada de la app cliente. Pantalla temporal hasta la Fase C1.
import 'package:flutter/material.dart';

void main() {
  runApp(const BnbClienteApp());
}

class BnbClienteApp extends StatelessWidget {
  const BnbClienteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BNB Cliente',
      home: Scaffold(
        appBar: AppBar(title: const Text('BNB Cliente')),
        body: const Center(child: Text('Pantalla temporal - Fase 1')),
      ),
    );
  }
}
