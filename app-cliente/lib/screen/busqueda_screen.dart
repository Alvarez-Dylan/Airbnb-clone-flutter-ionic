// Pantalla principal del cliente: buscador de lugares.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import '../repository/busqueda_provider.dart';
import '../widget/campo_fecha.dart';
import '../widget/contador_huespedes.dart';
import 'busqueda_avanzada_screen.dart';
import 'login_screen.dart';
import 'mis_reservas_screen.dart';
import 'resultados_screen.dart';

class BusquedaScreen extends StatefulWidget {
  const BusquedaScreen({super.key});

  @override
  State<BusquedaScreen> createState() => _BusquedaScreenState();
}

class _BusquedaScreenState extends State<BusquedaScreen> {
  final _ciudadController = TextEditingController();
  final _formatoFecha = DateFormat('dd/MM/yyyy');

  DateTime? _fechaLlegada;
  DateTime? _fechaSalida;
  int _huespedes = 1;

  @override
  void dispose() {
    _ciudadController.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha({required bool esLlegada}) async {
    final hoy = DateTime.now();
    // La llegada se limita a hoy + 364 dias para que su dia siguiente (el
    // primer dia posible de salida) nunca pase del lastDate de la salida.
    final primerDiaSalida = _fechaLlegada?.add(const Duration(days: 1)) ?? hoy;
    final fecha = await showDatePicker(
      context: context,
      initialDate: esLlegada ? hoy : primerDiaSalida,
      firstDate: esLlegada ? hoy : primerDiaSalida,
      lastDate: hoy.add(Duration(days: esLlegada ? 364 : 365)),
    );
    if (fecha == null) return;
    setState(() {
      if (esLlegada) {
        _fechaLlegada = fecha;
        // Si la salida ya elegida queda antes o igual que la nueva llegada,
        // se borra para que el usuario la vuelva a elegir.
        if (_fechaSalida != null && !_fechaSalida!.isAfter(fecha)) {
          _fechaSalida = null;
        }
      } else {
        _fechaSalida = fecha;
      }
    });
  }

  Future<void> _buscar() async {
    if (_ciudadController.text.trim().isEmpty) {
      _mostrarMensaje('Ingresa la ciudad');
      return;
    }
    if (_fechaLlegada == null || _fechaSalida == null) {
      _mostrarMensaje('Elige la fecha de llegada y de salida');
      return;
    }
    if (!_fechaSalida!.isAfter(_fechaLlegada!)) {
      _mostrarMensaje('La fecha de salida debe ser posterior a la de llegada');
      return;
    }

    final busquedaProvider = context.read<BusquedaProvider>();
    busquedaProvider.ciudad = _ciudadController.text.trim();
    busquedaProvider.fechaLlegada = _fechaLlegada;
    busquedaProvider.fechaSalida = _fechaSalida;
    busquedaProvider.huespedes = _huespedes;

    await busquedaProvider.buscar();

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultadosScreen()));
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  Future<void> _cerrarSesion() async {
    await context.read<AuthProvider>().cerrarSesion();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final nombreCompleto = context.watch<AuthProvider>().usuario?.nombrecompleto ?? '';
    final primerNombre = nombreCompleto.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar lugares'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Hola, $primerNombre',
              style: Theme.of(context).textTheme.headlineSmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _ciudadController,
                      decoration: const InputDecoration(labelText: 'Ciudad'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: CampoFecha(
                            etiqueta: 'Llegada',
                            fecha: _fechaLlegada,
                            formato: _formatoFecha,
                            onTap: () => _elegirFecha(esLlegada: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CampoFecha(
                            etiqueta: 'Salida',
                            fecha: _fechaSalida,
                            formato: _formatoFecha,
                            onTap: () => _elegirFecha(esLlegada: false),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Cantidad de huéspedes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        ContadorHuespedes(
                          cantidad: _huespedes,
                          onQuitar: _huespedes > 1 ? () => setState(() => _huespedes--) : null,
                          onAgregar: () => setState(() => _huespedes++),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _buscar,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusquedaAvanzadaScreen()),
              ),
              icon: const Icon(Icons.tune),
              label: const Text('Búsqueda avanzada'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MisReservasScreen()),
              ),
              icon: const Icon(Icons.event_note_outlined),
              label: const Text('Ver reservas'),
            ),
          ],
        ),
      ),
    );
  }
}
