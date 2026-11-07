// Lugar para alquilar, con sus fotos y el nombre del anfitrion. Ver docs/API.md.
import '../utils/conversiones.dart';

class FotoModel {
  final int id;
  final String url;

  FotoModel({required this.id, required this.url});

  factory FotoModel.fromJson(Map<String, dynamic> json) {
    return FotoModel(id: json['id'] as int, url: json['url'] as String);
  }
}

class LugarModel {
  final int id;
  final String nombre;
  final String descripcion;
  final int cantPersonas;
  final int cantCamas;
  final int cantBanios;
  final int cantHabitaciones;
  final bool tieneWifi;
  final int cantVehiculosParqueo;
  final double precioNoche;
  final double costoLimpieza;
  final String ciudad;
  final double latitud;
  final double longitud;
  final String nombreAnfitrion;
  final List<FotoModel> fotos;

  LugarModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.cantPersonas,
    required this.cantCamas,
    required this.cantBanios,
    required this.cantHabitaciones,
    required this.tieneWifi,
    required this.cantVehiculosParqueo,
    required this.precioNoche,
    required this.costoLimpieza,
    required this.ciudad,
    required this.latitud,
    required this.longitud,
    required this.nombreAnfitrion,
    required this.fotos,
  });

  factory LugarModel.fromJson(Map<String, dynamic> json) {
    final arrendatario = json['arrendatario'] as Map<String, dynamic>?;

    return LugarModel(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      cantPersonas: aEntero(json['cantPersonas']),
      cantCamas: aEntero(json['cantCamas']),
      cantBanios: aEntero(json['cantBanios']),
      cantHabitaciones: aEntero(json['cantHabitaciones']),
      tieneWifi: aBool(json['tieneWifi']),
      cantVehiculosParqueo: aEntero(json['cantVehiculosParqueo']),
      precioNoche: aDecimal(json['precioNoche']),
      costoLimpieza: aDecimal(json['costoLimpieza']),
      ciudad: json['ciudad'] as String,
      latitud: aDecimal(json['latitud']),
      longitud: aDecimal(json['longitud']),
      nombreAnfitrion: arrendatario?['nombrecompleto'] as String? ?? '',
      fotos: (json['fotos'] as List<dynamic>?)
              ?.map((foto) => FotoModel.fromJson(foto as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
