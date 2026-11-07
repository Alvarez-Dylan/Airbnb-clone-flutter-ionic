// Conversiones y formato de datos que vienen de la API (puede mandar texto,
// numero o null; ver docs/API.md). La conversion va siempre en el modelo, nunca
// en la pantalla.
import 'package:intl/intl.dart';

import '../config/api_config.dart';

int aEntero(dynamic valor) {
  if (valor == null) return 0;
  if (valor is int) return valor;
  if (valor is double) return valor.toInt();
  return int.tryParse(valor.toString()) ?? 0;
}

double aDecimal(dynamic valor) {
  if (valor == null) return 0;
  if (valor is double) return valor;
  if (valor is int) return valor.toDouble();
  return double.tryParse(valor.toString()) ?? 0;
}

bool aBool(dynamic valor) {
  return aEntero(valor) == 1;
}

// La API devuelve fotos[].url apuntando a un dominio viejo y caido (ver CLAUDE.md).
// Se toma solo el nombre de archivo y se reconstruye contra la base actual.
String urlFoto(String url) {
  final nombreArchivo = url.substring(url.lastIndexOf('/') + 1);
  return '${ApiConfig.urlRaiz}/fotos/$nombreArchivo';
}

String formatearPrecio(double valor) {
  return '\$us ${valor.toStringAsFixed(2)}';
}

String formatearFecha(DateTime fecha) {
  return DateFormat('dd/MM/yyyy').format(fecha);
}
