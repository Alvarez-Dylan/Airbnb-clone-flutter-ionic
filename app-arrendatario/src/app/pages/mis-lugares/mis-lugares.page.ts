// Pantalla principal del arrendatario: lista de sus lugares + boton para agregar uno nuevo.
import type { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { Router } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButtons,
  IonButton,
  IonCard,
  IonCardContent,
  IonBadge,
  IonIcon,
  IonSpinner,
  IonFab,
  type ViewWillEnter,
} from '@ionic/angular';
import { addIcons } from 'ionicons';
import {
  add,
  imageOutline,
  logOutOutline,
  locationOutline,
  bedOutline,
  waterOutline,
  wifiOutline,
  calendarOutline,
  homeOutline,
} from 'ionicons/icons';

import type { Lugar } from '../../models/lugar';
import { AuthService } from '../../services/auth.service';
import { LugaresService } from '../../services/lugares.service';
import { formatearPrecio, urlFoto } from '../../utils/formato';
import { mensajeDeError } from '../../utils/manejar-error';

@Component({
  selector: 'app-mis-lugares',
  templateUrl: 'mis-lugares.page.html',
  styleUrls: ['mis-lugares.page.scss'],
  imports: [
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButtons,
    IonButton,
    IonCard,
    IonCardContent,
    IonBadge,
    IonIcon,
    IonSpinner,
    IonFab,
  ],
})
export class MisLugaresPage implements ViewWillEnter {
  private authService = inject(AuthService);
  private lugaresService = inject(LugaresService);
  private router = inject(Router);

  lugares = signal<Lugar[]>([]);
  cargando = signal(false);
  error = signal('');

  // Ids de lugares cuya foto de portada fallo al cargar (se muestra el placeholder).
  fotosRotas = new Set<number>();

  // Expuestas al template.
  formatearPrecio = formatearPrecio;
  urlFoto = urlFoto;

  constructor() {
    addIcons({
      add,
      'image-outline': imageOutline,
      'log-out-outline': logOutOutline,
      'location-outline': locationOutline,
      'bed-outline': bedOutline,
      'water-outline': waterOutline,
      'wifi-outline': wifiOutline,
      'calendar-outline': calendarOutline,
      'home-outline': homeOutline,
    });
  }

  // Se carga aca y no en ngOnInit: Ionic mantiene viva la pagina al navegar
  // al formulario y volver, asi que ngOnInit no se repetiria.
  ionViewWillEnter(): void {
    this.cargarLugares();
  }

  private cargarLugares(): void {
    const usuario = this.authService.usuarioActual();
    if (!usuario) {
      return;
    }

    this.cargando.set(true);
    this.error.set('');
    this.lugaresService.misLugares(usuario.id).subscribe({
      next: (lugares) => {
        this.lugares.set(lugares);
        this.cargando.set(false);
      },
      error: (error: HttpErrorResponse) => {
        this.error.set(mensajeDeError(error));
        this.cargando.set(false);
      },
    });
  }

  irANuevoLugar(): void {
    this.router.navigate(['lugar/nuevo']);
  }

  irAEditarLugar(id: number): void {
    this.router.navigate(['lugar', id]);
  }

  irAReservas(id: number): void {
    this.router.navigate(['lugar', id, 'reservas']);
  }

  resumenLugares(): string {
    const cantidad = this.lugares().length;
    return cantidad === 1 ? '1 lugar publicado' : `${cantidad} lugares publicados`;
  }

  marcarFotoRota(id: number): void {
    this.fotosRotas.add(id);
  }

  cerrarSesion(): void {
    this.authService.cerrarSesion();
    this.router.navigate(['login']);
  }
}
