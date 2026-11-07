// Peticiones HTTP de reservas. Sin estado: solo arma la URL y devuelve el Observable.
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import type { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import type { LugarConReservas } from '../models/reserva';

@Injectable({ providedIn: 'root' })
export class ReservasService {
  private http = inject(HttpClient);
  private urlBase = `${environment.apiUrl}/reservas`;

  reservasDeLugar(idLugar: number): Observable<LugarConReservas> {
    return this.http.get<LugarConReservas>(`${this.urlBase}/lugar/${idLugar}`);
  }
}
