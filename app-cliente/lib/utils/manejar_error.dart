// La API (ver docs/API.md) no usa 422: todos los errores distinguen por la
// FORMA del cuerpo, no por el codigo HTTP.
// {"message": "texto"} -> error de negocio. {"campo": ["mensaje", ...]} -> validacion.
import 'package:dio/dio.dart';

String mensajeDeError(DioException error) {
  final datos = error.response?.data;
  if (datos is Map && datos['message'] != null) {
    return datos['message'].toString();
  }
  if (datos is Map && datos.isNotEmpty) {
    final primerCampo = datos.values.first;
    if (primerCampo is List && primerCampo.isNotEmpty) {
      return primerCampo.first.toString();
    }
  }
  return 'No se pudo conectar con el servidor. Intenta de nuevo.';
}
