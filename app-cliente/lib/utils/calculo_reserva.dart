// Calculo del precio de una reserva. Funciones puras (sin estado, sin HTTP)
// para poder explicarlas y probarlas una por una. Ver CLAUDE.md: el cobro por
// servicio es una decision propia del proyecto, no la define la API.
const double porcentajeServicio = 0.10;

int calcularNoches(DateTime llegada, DateTime salida) {
  return salida.difference(llegada).inDays;
}

double calcularSubtotal(int noches, double precioNoche) {
  return _redondear(noches * precioNoche);
}

double calcularServicio(double subtotal) {
  return _redondear(subtotal * porcentajeServicio);
}

double calcularTotal(double subtotal, double limpieza, double servicio) {
  return _redondear(subtotal + limpieza + servicio);
}

double _redondear(double valor) {
  return double.parse(valor.toStringAsFixed(2));
}
