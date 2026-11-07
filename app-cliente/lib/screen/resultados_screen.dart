// Resultados de la busqueda: lista o mapa, segun el bool _verMapa (estado local
// de esta pantalla, no del provider).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/lugar_model.dart';
import '../repository/busqueda_provider.dart';
import '../widget/lugar_card.dart';
import '../widget/mapa_lugares.dart';
import '../widget/vista_estado.dart';
import 'detalle_lugar_screen.dart';

class ResultadosScreen extends StatefulWidget {
  const ResultadosScreen({super.key});

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  bool _verMapa = false;

  void _irADetalle(LugarModel lugar) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleLugarScreen(idLugar: lugar.id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busquedaProvider = context.watch<BusquedaProvider>();
    final hayResultados = busquedaProvider.resultados.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: VistaEstado(
        cargando: busquedaProvider.cargando,
        error: busquedaProvider.error,
        vacio: busquedaProvider.resultados.isEmpty,
        mensajeVacio: 'No se encontraron lugares',
        child: _verMapa
            ? MapaLugares(lugares: busquedaProvider.resultados, onTapLugar: _irADetalle)
            : ListView.builder(
                itemCount: busquedaProvider.resultados.length,
                itemBuilder: (context, indice) {
                  final lugar = busquedaProvider.resultados[indice];
                  return LugarCard(lugar: lugar, onTap: () => _irADetalle(lugar));
                },
              ),
      ),
      bottomNavigationBar: hayResultados
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton(
                  onPressed: () => setState(() => _verMapa = !_verMapa),
                  child: Text(_verMapa ? 'Vista de lista' : 'Vista de mapa'),
                ),
              ),
            )
          : null,
    );
  }
}
