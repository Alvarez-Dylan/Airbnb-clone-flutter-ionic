// Lista de reservas del cliente logueado.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import '../repository/reserva_provider.dart';
import '../widget/reserva_card.dart';
import '../widget/vista_estado.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen> {
  @override
  void initState() {
    super.initState();
    final clienteId = context.read<AuthProvider>().usuario!.id;
    context.read<ReservaProvider>().cargarReservas(clienteId);
  }

  @override
  Widget build(BuildContext context) {
    final reservaProvider = context.watch<ReservaProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis reservas')),
      body: VistaEstado(
        cargando: reservaProvider.cargandoReservas,
        error: reservaProvider.errorReservas,
        vacio: reservaProvider.reservas.isEmpty,
        mensajeVacio: 'No tienes reservas todavia',
        child: ListView.builder(
          itemCount: reservaProvider.reservas.length,
          itemBuilder: (context, indice) {
            return ReservaCard(reserva: reservaProvider.reservas[indice]);
          },
        ),
      ),
    );
  }
}
