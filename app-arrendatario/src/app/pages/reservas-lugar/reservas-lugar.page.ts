// Lista de reservas de un lugar: primera foto, cliente, noches, fechas y total.
import type { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonList,
  IonItem,
  IonThumbnail,
  IonLabel,
  IonIcon,
  IonSpinner,
} from '@ionic/angular';
import { addIcons } from 'ionicons';
import { imageOutline } from 'ionicons/icons';

import type { LugarConReservas } from '../../models/reserva';
import { ReservasService } from '../../services/reservas.service';
import { calcularNoches, formatearFecha, formatearPrecio, urlFoto } from '../../utils/formato';
import { mensajeDeError } from '../../utils/manejar-error';

@Component({
  selector: 'app-reservas-lugar',
  templateUrl: 'reservas-lugar.page.html',
  styleUrls: ['reservas-lugar.page.scss'],
  imports: [
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonList,
    IonItem,
    IonThumbnail,
    IonLabel,
    IonIcon,
    IonSpinner,
  ],
})
export class ReservasLugarPage {
  private ruta = inject(ActivatedRoute);
  private reservasService = inject(ReservasService);

  idLugar = Number(this.ruta.snapshot.paramMap.get('id'));

  cargando = signal(true);
  error = signal('');
  lugar = signal<LugarConReservas | null>(null);

  // Expuestas al template.
  calcularNoches = calcularNoches;
  formatearFecha = formatearFecha;
  formatearPrecio = formatearPrecio;
  urlFoto = urlFoto;

  constructor() {
    addIcons({ 'image-outline': imageOutline });
    this.cargarReservas();
  }

  private cargarReservas(): void {
    this.reservasService.reservasDeLugar(this.idLugar).subscribe({
      next: (lugar) => {
        this.lugar.set(lugar);
        this.cargando.set(false);
      },
      error: (error: HttpErrorResponse) => {
        this.error.set(mensajeDeError(error));
        this.cargando.set(false);
      },
    });
  }

  ocultarImagenRota(evento: Event): void {
    (evento.target as HTMLImageElement).style.display = 'none';
  }
}
