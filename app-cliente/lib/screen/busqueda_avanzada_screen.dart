// Busqueda avanzada: mismos campos de la busqueda simple + campos del lugar
// (sin foto ni anfitrion). Los campos del lugar hacen coincidencia EXACTA en
// la API; los que el usuario deja vacios se omiten del body (ver CLAUDE.md).
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../repository/busqueda_provider.dart';
import 'resultados_screen.dart';

class BusquedaAvanzadaScreen extends StatefulWidget {
  const BusquedaAvanzadaScreen({super.key});

  @override
  State<BusquedaAvanzadaScreen> createState() => _BusquedaAvanzadaScreenState();
}

class _BusquedaAvanzadaScreenState extends State<BusquedaAvanzadaScreen> {
  final _ciudadController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _camasController = TextEditingController();
  final _baniosController = TextEditingController();
  final _habitacionesController = TextEditingController();
  final _vehiculosController = TextEditingController();
  final _precioController = TextEditingController();
  final _formatoFecha = DateFormat('dd/MM/yyyy');

  DateTime? _fechaLlegada;
  DateTime? _fechaSalida;
  int _huespedes = 1;
  bool? _tieneWifi;

  @override
  void dispose() {
    _ciudadController.dispose();
    _descripcionController.dispose();
    _camasController.dispose();
    _baniosController.dispose();
    _habitacionesController.dispose();
    _vehiculosController.dispose();
    _precioController.dispose();
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

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
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

    final filtros = <String, dynamic>{};
    if (_descripcionController.text.trim().isNotEmpty) {
      filtros['descripcion'] = _descripcionController.text.trim();
    }
    if (_camasController.text.trim().isNotEmpty) {
      filtros['cantCamas'] = int.tryParse(_camasController.text.trim());
    }
    if (_baniosController.text.trim().isNotEmpty) {
      filtros['cantBanios'] = int.tryParse(_baniosController.text.trim());
    }
    if (_habitacionesController.text.trim().isNotEmpty) {
      filtros['cantHabitaciones'] = int.tryParse(_habitacionesController.text.trim());
    }
    if (_vehiculosController.text.trim().isNotEmpty) {
      filtros['cantVehiculosParqueo'] = int.tryParse(_vehiculosController.text.trim());
    }
    if (_precioController.text.trim().isNotEmpty) {
      filtros['precioNoche'] = double.tryParse(_precioController.text.trim());
    }
    if (_tieneWifi != null) {
      filtros['tieneWifi'] = _tieneWifi! ? 1 : 0;
    }

    final busquedaProvider = context.read<BusquedaProvider>();
    busquedaProvider.ciudad = _ciudadController.text.trim();
    busquedaProvider.fechaLlegada = _fechaLlegada;
    busquedaProvider.fechaSalida = _fechaSalida;
    busquedaProvider.huespedes = _huespedes;

    await busquedaProvider.buscarAvanzado(filtros);

    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultadosScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Busqueda avanzada')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _ciudadController,
            decoration: const InputDecoration(labelText: 'Ciudad'),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              _fechaLlegada == null ? 'Fecha de llegada' : _formatoFecha.format(_fechaLlegada!),
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
          const Divider(height: 32),
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(labelText: 'Descripcion (opcional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _camasController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad de camas (opcional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _baniosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad de banios (opcional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _habitacionesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Cantidad de habitaciones (opcional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _vehiculosController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Vehiculos de parqueo (opcional)'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _precioController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Precio por noche (opcional)'),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<bool?>(
            initialValue: _tieneWifi,
            decoration: const InputDecoration(labelText: 'Wifi'),
            items: const [
              DropdownMenuItem(value: null, child: Text('Cualquiera')),
              DropdownMenuItem(value: true, child: Text('Si')),
              DropdownMenuItem(value: false, child: Text('No')),
            ],
            onChanged: (valor) => setState(() => _tieneWifi = valor),
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _buscar, child: const Text('Buscar')),
        ],
      ),
    );
  }
}
