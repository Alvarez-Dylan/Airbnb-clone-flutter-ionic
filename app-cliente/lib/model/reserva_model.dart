// Reserva de un cliente. GET reservas/cliente/{id} trae el lugar anidado como
// un arreglo de 1 elemento (no un objeto), ver docs/API.md.
import '../utils/calculo_reserva.dart';
import '../utils/conversiones.dart';

class ReservaModel {
  final int id;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double precioNoches;
  final double precioLimpieza;
  final double precioServicio;
  final double precioTotal;
  final String nombreLugar;
  final String? primeraFotoUrl;
  final String nombreAnfitrion;

  ReservaModel({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.precioNoches,
    required this.precioLimpieza,
    required this.precioServicio,
    required this.precioTotal,
    required this.nombreLugar,
    required this.primeraFotoUrl,
    required this.nombreAnfitrion,
  });

  int get noches => calcularNoches(fechaInicio, fechaFin);

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    final lugares = json['lugar'] as List<dynamic>?;
    final lugar = (lugares != null && lugares.isNotEmpty)
        ? lugares[0] as Map<String, dynamic>
        : null;
    final fotos = lugar?['fotos'] as List<dynamic>?;
    final arrendatario = lugar?['arrendatario'] as Map<String, dynamic>?;

    return ReservaModel(
      id: json['id'] as int,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      precioNoches: aDecimal(json['precioNoches']),
      precioLimpieza: aDecimal(json['precioLimpieza']),
      precioServicio: aDecimal(json['precioServicio']),
      precioTotal: aDecimal(json['precioTotal']),
      nombreLugar: lugar?['nombre'] as String? ?? '',
      primeraFotoUrl: (fotos != null && fotos.isNotEmpty)
          ? (fotos[0] as Map<String, dynamic>)['url'] as String?
          : null,
      nombreAnfitrion: arrendatario?['nombrecompleto'] as String? ?? '',
    );
  }
}
