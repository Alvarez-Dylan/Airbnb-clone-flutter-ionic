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
    final cantidad = busquedaProvider.resultados.length;
    final palabraResultados = cantidad == 1 ? 'resultado' : 'resultados';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${busquedaProvider.ciudad} · $cantidad $palabraResultados',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: VistaEstado(
        cargando: busquedaProvider.cargando,
        error: busquedaProvider.error,
        vacio: busquedaProvider.resultados.isEmpty,
        mensajeVacio: 'No se encontraron lugares',
        icono: Icons.search_off,
        child: _verMapa
            ? MapaLugares(lugares: busquedaProvider.resultados, onTapLugar: _irADetalle)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                itemCount: busquedaProvider.resultados.length,
                itemBuilder: (context, indice) {
                  final lugar = busquedaProvider.resultados[indice];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: LugarCard(lugar: lugar, onTap: () => _irADetalle(lugar)),
                  );
                },
              ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: hayResultados
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _verMapa = !_verMapa),
              icon: Icon(_verMapa ? Icons.list : Icons.map_outlined),
              label: Text(_verMapa ? 'Vista de lista' : 'Vista de mapa'),
            )
          : null,
    );
  }
}
