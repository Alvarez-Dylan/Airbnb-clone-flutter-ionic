// Lugar publicado por un arrendatario, con sus fotos. Ver docs/API.md.
export interface Foto {
  id: number;
  url: string;
  lugar_id: number;
}

export interface Lugar {
  id: number;
  nombre: string;
  descripcion: string;
  cantPersonas: number;
  cantCamas: number;
  cantBanios: number;
  cantHabitaciones: number;
  tieneWifi: number;
  cantVehiculosParqueo: number;
  precioNoche: number | string;
  costoLimpieza: number | string;
  ciudad: string;
  latitud: string;
  longitud: string;
  arrendatario_id: number;
  fotos: Foto[];
}

// Body para crear o editar un lugar (sin id, sin fotos: eso va aparte).
export interface LugarBody {
  nombre: string;
  descripcion: string;
  cantPersonas: number;
  cantCamas: number;
  cantBanios: number;
  cantHabitaciones: number;
  tieneWifi: number;
  cantVehiculosParqueo: number;
  precioNoche: number;
  costoLimpieza: number;
  ciudad: string;
  latitud: string;
  longitud: string;
  arrendatario_id: number;
}
