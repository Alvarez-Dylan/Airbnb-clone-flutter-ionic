// Detalle de un lugar: pide GET lugares/{id} de nuevo (no reusa los datos
// parciales de la busqueda) para mostrar siempre la version mas reciente.
import 'package:flutter/material.dart';

import '../config/tema.dart';
import '../model/lugar_model.dart';
import '../service/lugar_service.dart';
import '../widget/barra_reservar.dart';
import '../widget/caracteristicas_lugar.dart';
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

  void _irAConfirmar(LugarModel lugar) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ConfirmarReservaScreen(lugar: lugar)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lugar = _lugar;

    return Scaffold(
      appBar: AppBar(title: Text(lugar?.nombre ?? 'Detalle')),
      body: VistaEstado(
        cargando: _cargando,
        error: _error,
        vacio: false,
        mensajeVacio: '',
        child: lugar == null ? const SizedBox() : _buildContenido(context, lugar),
      ),
      // Solo aparece cuando el lugar ya cargo: mientras carga o si hubo un
      // error no tiene sentido ofrecer "Reservar".
      bottomNavigationBar: lugar == null
          ? null
          : BarraReservar(precioNoche: lugar.precioNoche, onReservar: () => _irAConfirmar(lugar)),
    );
  }

  Widget _buildContenido(BuildContext context, LugarModel lugar) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        GaleriaFotos(fotos: lugar.fotos),
        const SizedBox(height: 16),
        Text(
          lugar.nombre,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          lugar.ciudad,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: colorTextoSecundario),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              child: Text(
                lugar.nombreAnfitrion.isEmpty ? '?' : lugar.nombreAnfitrion[0].toUpperCase(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Anfitrión: ${lugar.nombreAnfitrion}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CaracteristicasLugar(lugar: lugar),
        const SizedBox(height: 24),
        Text('Acerca de este lugar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(lugar.descripcion),
      ],
    );
  }
}
