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
