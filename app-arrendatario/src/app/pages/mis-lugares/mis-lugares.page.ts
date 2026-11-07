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
  IonList,
  IonItem,
  IonThumbnail,
  IonLabel,
  IonIcon,
  IonSpinner,
  IonFab,
  IonFabButton,
  type ViewWillEnter,
} from '@ionic/angular';
import { addIcons } from 'ionicons';
import { add, imageOutline } from 'ionicons/icons';

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
    IonList,
    IonItem,
    IonThumbnail,
    IonLabel,
    IonIcon,
    IonSpinner,
    IonFab,
    IonFabButton,
  ],
})
export class MisLugaresPage implements ViewWillEnter {
  private authService = inject(AuthService);
  private lugaresService = inject(LugaresService);
  private router = inject(Router);

  lugares = signal<Lugar[]>([]);
  cargando = signal(false);
  error = signal('');

  // Expuestas al template.
  formatearPrecio = formatearPrecio;
  urlFoto = urlFoto;

  constructor() {
    addIcons({ add, 'image-outline': imageOutline });
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

  ocultarImagenRota(evento: Event): void {
    (evento.target as HTMLImageElement).style.display = 'none';
  }

  cerrarSesion(): void {
    this.authService.cerrarSesion();
    this.router.navigate(['login']);
  }
}
