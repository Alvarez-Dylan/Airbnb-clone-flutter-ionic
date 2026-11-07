// Estado de la busqueda: criterios que eligio el usuario + resultados.
import 'package:flutter/foundation.dart';

import '../model/lugar_model.dart';
import '../service/lugar_service.dart';

class BusquedaProvider extends ChangeNotifier {
  final LugarService _lugarService = LugarService();

  // Criterios: se guardan aca (no en la pantalla) porque se vuelven a usar
  // al confirmar la reserva (Fase C5).
  String ciudad = '';
  DateTime? fechaLlegada;
  DateTime? fechaSalida;
  int huespedes = 1;

  List<LugarModel> _resultados = [];
  bool _cargando = false;
  String? _error;

  List<LugarModel> get resultados => _resultados;
  bool get cargando => _cargando;
  String? get error => _error;

  Future<void> buscar() async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      final lugares = await _lugarService.buscar(ciudad);
      // La busqueda simple de la API no recibe la cantidad de huespedes;
      // se filtra aca, localmente, por la capacidad del lugar.
      _resultados = lugares.where((lugar) => lugar.cantPersonas >= huespedes).toList();
      _cargando = false;
      notifyListeners();
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
    }
  }
}
