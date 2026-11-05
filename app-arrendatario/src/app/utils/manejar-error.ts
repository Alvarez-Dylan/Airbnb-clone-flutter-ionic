// La API (ver docs/API.md) no usa 422: todos los errores responden distinto codigo
// pero dos formas de cuerpo distintas. Esta funcion decide que mensaje mostrar.
import type { HttpErrorResponse } from '@angular/common/http';

export function mensajeDeError(error: HttpErrorResponse): string {
  const cuerpo = error.error;

  // Error de negocio: { "message": "texto" }
  if (cuerpo?.message) {
    return cuerpo.message;
  }

  // Error de validacion: { "campo": ["mensaje", ...], ... }
  if (cuerpo && typeof cuerpo === 'object') {
    const primerCampo = Object.values(cuerpo)[0];
    if (Array.isArray(primerCampo) && typeof primerCampo[0] === 'string') {
      return primerCampo[0];
    }
  }

  return 'No se pudo conectar con el servidor. Intenta de nuevo.';
}
