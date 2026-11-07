// Confirmar reserva: muestra el desglose del precio y lo envia a la API.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../model/lugar_model.dart';
import '../repository/auth_provider.dart';
import '../repository/busqueda_provider.dart';
import '../repository/reserva_provider.dart';
import '../utils/calculo_reserva.dart';
import '../utils/conversiones.dart';

class ConfirmarReservaScreen extends StatefulWidget {
  final LugarModel lugar;

  const ConfirmarReservaScreen({super.key, required this.lugar});

  @override
  State<ConfirmarReservaScreen> createState() => _ConfirmarReservaScreenState();
}

class _ConfirmarReservaScreenState extends State<ConfirmarReservaScreen> {
  final _formatoApi = DateFormat('yyyy-MM-dd');

  Future<void> _confirmar() async {
    final busquedaProvider = context.read<BusquedaProvider>();
    final authProvider = context.read<AuthProvider>();
    final llegada = busquedaProvider.fechaLlegada!;
    final salida = busquedaProvider.fechaSalida!;

    final noches = calcularNoches(llegada, salida);
    final subtotal = calcularSubtotal(noches, widget.lugar.precioNoche);
    final servicio = calcularServicio(subtotal);
    final total = calcularTotal(subtotal, widget.lugar.costoLimpieza, servicio);

    final exito = await context.read<ReservaProvider>().confirmarReserva(
          lugarId: widget.lugar.id,
          clienteId: authProvider.usuario!.id,
          fechaInicio: _formatoApi.format(llegada),
          fechaFin: _formatoApi.format(salida),
          precioNoches: subtotal,
          precioLimpieza: widget.lugar.costoLimpieza,
          precioServicio: servicio,
          precioTotal: total,
        );

    if (!mounted) return;

    if (exito) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reserva confirmada')));
      Navigator.popUntil(context, (ruta) => ruta.isFirst);
    } else {
      final error = context.read<ReservaProvider>().error ?? 'No se pudo confirmar la reserva';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final busquedaProvider = context.watch<BusquedaProvider>();
    final reservaProvider = context.watch<ReservaProvider>();
    final llegada = busquedaProvider.fechaLlegada;
    final salida = busquedaProvider.fechaSalida;

    if (llegada == null || salida == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirmar reserva')),
        body: const Center(child: Text('Elige primero las fechas en la busqueda')),
      );
    }

    final noches = calcularNoches(llegada, salida);
    final subtotal = calcularSubtotal(noches, widget.lugar.precioNoche);
    final limpieza = widget.lugar.costoLimpieza;
    final servicio = calcularServicio(subtotal);
    final total = calcularTotal(subtotal, limpieza, servicio);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.lugar.nombre, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _filaPrecio(
              '$noches noches x ${formatearPrecio(widget.lugar.precioNoche)}',
              formatearPrecio(subtotal),
            ),
            _filaPrecio('Limpieza', formatearPrecio(limpieza)),
            _filaPrecio('Servicio', formatearPrecio(servicio)),
            const Divider(),
            _filaPrecio('Total', formatearPrecio(total), destacado: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: reservaProvider.cargando ? null : _confirmar,
              child: Text(reservaProvider.cargando ? 'Enviando...' : 'Confirmar reserva'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaPrecio(String etiqueta, String valor, {bool destacado = false}) {
    final estilo = destacado
        ? const TextStyle(fontWeight: FontWeight.bold)
        : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(etiqueta, style: estilo),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}
