// Estado de la confirmacion de reserva (ChangeNotifier, igual que los demas
// providers). Las reservas del cliente (listado) se agregan en la Fase C6.
import 'package:flutter/foundation.dart';

import '../model/reserva_model.dart';
import '../service/reserva_service.dart';

class ReservaProvider extends ChangeNotifier {
  final ReservaService _reservaService = ReservaService();

  bool _cargando = false;
  String? _error;

  bool get cargando => _cargando;
  String? get error => _error;

  List<ReservaModel> _reservas = [];
  bool _cargandoReservas = false;
  String? _errorReservas;

  List<ReservaModel> get reservas => _reservas;
  bool get cargandoReservas => _cargandoReservas;
  String? get errorReservas => _errorReservas;

  Future<void> cargarReservas(int clienteId) async {
    _cargandoReservas = true;
    _errorReservas = null;
    notifyListeners();
    try {
      _reservas = await _reservaService.obtenerReservasCliente(clienteId);
      _cargandoReservas = false;
      notifyListeners();
    } catch (error) {
      _errorReservas = error.toString().replaceFirst('Exception: ', '');
      _cargandoReservas = false;
      notifyListeners();
    }
  }

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
