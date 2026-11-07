// Peticiones HTTP de lugares. Sin estado: solo arma la URL y devuelve el Observable.
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import type { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import type { Lugar, LugarBody } from '../models/lugar';

@Injectable({ providedIn: 'root' })
export class LugaresService {
  private http = inject(HttpClient);
  private urlBase = `${environment.apiUrl}/lugares`;

  misLugares(idArrendatario: number): Observable<Lugar[]> {
    return this.http.get<Lugar[]>(`${this.urlBase}/arrendatario/${idArrendatario}`);
  }

  obtenerLugar(id: number): Observable<Lugar> {
    return this.http.get<Lugar>(`${this.urlBase}/${id}`);
  }

  guardarLugar(body: LugarBody): Observable<Lugar> {
    return this.http.post<Lugar>(this.urlBase, body);
  }

  // PUT y no POST con id: confirmado en la Fase 0, POST con id duplica el lugar en vez de actualizarlo.
  editarLugar(id: number, body: LugarBody): Observable<Lugar> {
    return this.http.put<Lugar>(`${this.urlBase}/${id}`, body);
  }

  subirFoto(idLugar: number, archivo: File): Observable<Lugar> {
    // No se pone Content-Type a mano: el navegador arma el multipart/form-data con el boundary.
    const datos = new FormData();
    datos.append('foto', archivo);
    return this.http.post<Lugar>(`${this.urlBase}/${idLugar}/foto`, datos);
  }
}
