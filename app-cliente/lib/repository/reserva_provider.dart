// Estado de la confirmacion de reserva (ChangeNotifier, igual que los demas
// providers). Las reservas del cliente (listado) se agregan en la Fase C6.
import 'package:flutter/foundation.dart';

import '../service/reserva_service.dart';

class ReservaProvider extends ChangeNotifier {
  final ReservaService _reservaService = ReservaService();

  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  Future<bool> confirmarReserva({
    required int lugarId,
    required int clienteId,
    required String fechaInicio,
    required String fechaFin,
    required double precioNoches,
    required double precioLimpieza,
    required double precioServicio,
    required double precioTotal,
  }) async {
    _cargando = true;
    _error = null;
    notifyListeners();
    try {
      await _reservaService.crearReserva(
        lugarId: lugarId,
        clienteId: clienteId,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        precioNoches: precioNoches,
        precioLimpieza: precioLimpieza,
        precioServicio: precioServicio,
        precioTotal: precioTotal,
      );
      _cargando = false;
      notifyListeners();
      return true;
    } catch (error) {
      _error = error.toString().replaceFirst('Exception: ', '');
      _cargando = false;
      notifyListeners();
      return false;
    }
  }
}
