// Detalle de un lugar: pide GET lugares/{id} de nuevo (no reusa los datos
// parciales de la busqueda) para mostrar siempre la version mas reciente.
import 'package:flutter/material.dart';

import '../model/lugar_model.dart';
import '../service/lugar_service.dart';
import '../utils/conversiones.dart';
import '../widget/galeria_fotos.dart';
import '../widget/vista_estado.dart';
import 'confirmar_reserva_screen.dart';

class DetalleLugarScreen extends StatefulWidget {
  final int idLugar;

  const DetalleLugarScreen({super.key, required this.idLugar});

  @override
  State<DetalleLugarScreen> createState() => _DetalleLugarScreenState();
}

class _DetalleLugarScreenState extends State<DetalleLugarScreen> {
  final LugarService _lugarService = LugarService();

  bool _cargando = true;
  String? _error;
  LugarModel? _lugar;

  @override
  void initState() {
    super.initState();
    _cargarLugar();
  }

  Future<void> _cargarLugar() async {
    try {
      final lugar = await _lugarService.obtenerLugar(widget.idLugar);
      if (!mounted) return;
      setState(() {
        _lugar = lugar;
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_lugar?.nombre ?? 'Detalle')),
      body: VistaEstado(
        cargando: _cargando,
        error: _error,
        vacio: false,
        mensajeVacio: '',
        child: _lugar == null ? const SizedBox() : _buildContenido(context, _lugar!),
      ),
    );
  }

  Widget _buildContenido(BuildContext context, LugarModel lugar) {
    final parqueo = lugar.cantVehiculosParqueo > 0
        ? 'Parqueo para ${lugar.cantVehiculosParqueo} vehiculos'
        : 'No tiene parqueo';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GaleriaFotos(fotos: lugar.fotos),
        const SizedBox(height: 16),
        Text(lugar.nombre, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(lugar.descripcion),
        const SizedBox(height: 16),
        Text('${lugar.cantPersonas} personas'),
        Text('${lugar.cantCamas} camas'),
        Text('${lugar.cantBanios} banios'),
        Text('${lugar.cantHabitaciones} habitaciones'),
        Text('Anfitrion: ${lugar.nombreAnfitrion}'),
        Text('Wifi: ${lugar.tieneWifi ? 'Si' : 'No'}'),
        Text(parqueo),
        const SizedBox(height: 8),
        Text(
          '${formatearPrecio(lugar.precioNoche)} por noche',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ConfirmarReservaScreen(lugar: lugar)),
          ),
          child: const Text('Reservar'),
        ),
      ],
    );
  }
}
