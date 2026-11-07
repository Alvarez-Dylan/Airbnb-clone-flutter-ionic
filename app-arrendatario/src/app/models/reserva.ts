// Reserva de un lugar, con el cliente que la hizo. Ver docs/API.md.
import type { Lugar } from './lugar';

export interface Cliente {
  id: number;
  nombrecompleto: string;
}

export interface Reserva {
  id: number;
  fechaInicio: string;
  fechaFin: string;
  precioNoches: number | string;
  precioLimpieza: number | string;
  precioServicio: number | string;
  precioTotal: number | string;
  cliente: Cliente;
}

// GET reservas/lugar/{id} devuelve el lugar completo con sus reservas adentro,
// no un arreglo plano de reservas (confirmado en la Fase 0).
export interface LugarConReservas extends Lugar {
  reservas: Reserva[];
}
