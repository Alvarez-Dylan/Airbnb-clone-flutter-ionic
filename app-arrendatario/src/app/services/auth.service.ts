// Login, registro y manejo de la sesion del arrendatario (guardada en localStorage).
import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import type { Observable } from 'rxjs';

import { environment } from '../../environments/environment';
import type { Usuario } from '../models/usuario';

const CLAVE_SESION = 'sesionArrendatario';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private urlBase = `${environment.apiUrl}/arrendatario`;

  iniciarSesion(email: string, password: string): Observable<Usuario> {
    return this.http.post<Usuario>(`${this.urlBase}/login`, { email, password });
  }

  registrar(datos: {
    nombrecompleto: string;
    email: string;
    password: string;
    telefono: string;
  }): Observable<Usuario> {
    return this.http.post<Usuario>(`${this.urlBase}/registro`, datos);
  }

  guardarSesion(usuario: Usuario): void {
    localStorage.setItem(CLAVE_SESION, JSON.stringify(usuario));
  }

  usuarioActual(): Usuario | null {
    const guardado = localStorage.getItem(CLAVE_SESION);
    return guardado ? JSON.parse(guardado) : null;
  }

  haySesion(): boolean {
    return this.usuarioActual() !== null;
  }

  cerrarSesion(): void {
    localStorage.removeItem(CLAVE_SESION);
  }
}
