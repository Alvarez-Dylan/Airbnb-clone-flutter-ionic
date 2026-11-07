// Conversiones y formato de datos que vienen de la API (ver docs/API.md).
import { environment } from '../../environments/environment';

export function aNumero(valor: number | string): number {
  if (typeof valor === 'number') {
    return valor;
  }
  return Number(valor) || 0;
}

export function aBooleano(valor: number | string): boolean {
  return aNumero(valor) === 1;
}

export function formatearPrecio(valor: number | string): string {
  return `$us ${aNumero(valor).toFixed(2)}`;
}

// La API devuelve fotos[].url apuntando a un dominio viejo y caido (ver CLAUDE.md).
// Se toma solo el nombre de archivo y se reconstruye contra la base actual.
export function urlFoto(url: string): string {
  const nombreArchivo = url.substring(url.lastIndexOf('/') + 1);
  const urlRaiz = environment.apiUrl.replace(/\/api\/?$/, '');
  return `${urlRaiz}/fotos/${nombreArchivo}`;
}

// new Date('2024-11-04') se interpreta en UTC: en Bolivia (UTC-4) mostraria el
// dia anterior. Por eso se parte el texto en vez de usar el constructor de Date.
// Si la fecha viene con hora, se toman solo los primeros 10 caracteres (YYYY-MM-DD).
export function formatearFecha(fecha: string): string {
  const [anio, mes, dia] = fecha.substring(0, 10).split('-');
  return `${dia}/${mes}/${anio}`;
}

export function calcularNoches(fechaInicio: string, fechaFin: string): number {
  const [anioI, mesI, diaI] = fechaInicio.substring(0, 10).split('-').map(Number);
  const [anioF, mesF, diaF] = fechaFin.substring(0, 10).split('-').map(Number);
  const inicio = Date.UTC(anioI, mesI - 1, diaI);
  const fin = Date.UTC(anioF, mesF - 1, diaF);
  return Math.round((fin - inicio) / 86400000);
}
