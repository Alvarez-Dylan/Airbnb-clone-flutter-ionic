// Confirmar reserva: muestra el resumen y el desglose del precio, y lo envia a la API.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../config/tema.dart';
import '../model/lugar_model.dart';
import '../repository/auth_provider.dart';
import '../repository/busqueda_provider.dart';
import '../repository/reserva_provider.dart';
import '../utils/calculo_reserva.dart';
import '../utils/conversiones.dart';
import '../widget/foto_lugar.dart';

class ConfirmarReservaScreen extends StatefulWidget {
  final LugarModel lugar;

  const ConfirmarReservaScreen({super.key, required this.lugar});

  @override
  State<ConfirmarReservaScreen> createState() => _ConfirmarReservaScreenState();
}

class _ConfirmarReservaScreenState extends State<ConfirmarReservaScreen> {
  final _formatoApi = DateFormat('yyyy-MM-dd');
  final _formatoFecha = DateFormat('dd/MM/yyyy');

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva confirmada')));
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
        body: const Center(child: Text('Elige primero las fechas en la búsqueda')),
      );
    }

    final noches = calcularNoches(llegada, salida);
    final subtotal = calcularSubtotal(noches, widget.lugar.precioNoche);
    final limpieza = widget.lugar.costoLimpieza;
    final servicio = calcularServicio(subtotal);
    final total = calcularTotal(subtotal, limpieza, servicio);

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar reserva')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tarjetaResumen(context, busquedaProvider.huespedes, llegada, salida),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _filaPrecio(
                    '$noches noches x ${formatearPrecio(widget.lugar.precioNoche)}',
                    formatearPrecio(subtotal),
                  ),
                  _filaPrecio('Limpieza', formatearPrecio(limpieza)),
                  _filaPrecio('Servicio', formatearPrecio(servicio)),
                  const Divider(),
                  _filaPrecio('Total', formatearPrecio(total), destacado: true),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: reservaProvider.cargando ? null : _confirmar,
              child: Text(reservaProvider.cargando ? 'Enviando...' : 'Confirmar reserva'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tarjetaResumen(BuildContext context, int huespedes, DateTime llegada, DateTime salida) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 64,
              height: 64,
              child: FotoLugar(
                url: widget.lugar.fotos.isEmpty ? null : widget.lugar.fotos.first.url,
                radio: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lugar.nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatoFecha.format(llegada)} - ${_formatoFecha.format(salida)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: colorTextoSecundario),
                  ),
                  Text(
                    '$huespedes huéspedes',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: colorTextoSecundario),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filaPrecio(String etiqueta, String valor, {bool destacado = false}) {
    final estilo = destacado
        ? const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
        : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(etiqueta, style: estilo, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          Text(valor, style: estilo),
        ],
      ),
    );
  }
}
