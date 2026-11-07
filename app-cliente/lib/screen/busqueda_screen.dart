// Pantalla principal del cliente: buscador de lugares.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../repository/auth_provider.dart';
import '../repository/busqueda_provider.dart';
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
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha == null) return;
    setState(() {
      if (esLlegada) {
        _fechaLlegada = fecha;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar lugares'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _ciudadController,
              decoration: const InputDecoration(labelText: 'Ciudad'),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _fechaLlegada == null
                    ? 'Fecha de llegada'
                    : _formatoFecha.format(_fechaLlegada!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _elegirFecha(esLlegada: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _fechaSalida == null ? 'Fecha de salida' : _formatoFecha.format(_fechaSalida!),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _elegirFecha(esLlegada: false),
            ),
            Row(
              children: [
                const Text('Cantidad de huespedes'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _huespedes > 1 ? () => setState(() => _huespedes--) : null,
                ),
                Text('$_huespedes'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() => _huespedes++),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _buscar, child: const Text('Buscar')),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BusquedaAvanzadaScreen()),
              ),
              child: const Text('Busqueda avanzada'),
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MisReservasScreen()),
              ),
              child: const Text('Ver reservas'),
            ),
          ],
        ),
      ),
    );
  }
}
