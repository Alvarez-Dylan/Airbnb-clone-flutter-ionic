// Peticiones HTTP de reservas. Solo llama a la API; el calculo de precios
// vive en utils/calculo_reserva.dart.
import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../utils/manejar_error.dart';

class ReservaService {
  final Dio _dio = ApiConfig.dio;

  Future<void> crearReserva({
    required int lugarId,
    required int clienteId,
    required String fechaInicio,
    required String fechaFin,
    required double precioNoches,
    required double precioLimpieza,
    required double precioServicio,
    required double precioTotal,
  }) async {
    try {
      await _dio.post('/reservas', data: {
        'lugar_id': lugarId,
        'cliente_id': clienteId,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'precioNoches': precioNoches.toStringAsFixed(2),
        'precioLimpieza': precioLimpieza.toStringAsFixed(2),
        'precioServicio': precioServicio.toStringAsFixed(2),
        'precioTotal': precioTotal.toStringAsFixed(2),
      });
    } on DioException catch (error) {
      throw Exception(mensajeDeError(error));
    }
  }
}
