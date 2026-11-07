// Mapa Leaflet: muestra una ubicacion y permite elegir una nueva con un clic.
import type {
  AfterViewInit,
  ElementRef,
  OnDestroy} from '@angular/core';
import {
  Component,
  ViewChild,
  input,
  output,
} from '@angular/core';
import * as L from 'leaflet';

// Centro por defecto: Santa Cruz de la Sierra (ver CLAUDE.md).
const CENTRO_DEFECTO: L.LatLngTuple = [-17.7833, -63.1821];
const ZOOM_DEFECTO = 13;

@Component({
  selector: 'app-mapa-selector',
  templateUrl: 'mapa-selector.component.html',
  styleUrls: ['mapa-selector.component.scss'],
})
export class MapaSelectorComponent implements AfterViewInit, OnDestroy {
  @ViewChild('mapaDiv') mapaDiv!: ElementRef<HTMLDivElement>;

  latitud = input<number | null>(null);
  longitud = input<number | null>(null);
  ubicacionSeleccionada = output<{ latitud: number; longitud: number }>();

  private mapa!: L.Map;
  private marcador: L.CircleMarker | null = null;

  ngAfterViewInit(): void {
    const tieneUbicacion = this.latitud() !== null && this.longitud() !== null;
    const centroInicial: L.LatLngTuple = tieneUbicacion
      ? [this.latitud()!, this.longitud()!]
      : CENTRO_DEFECTO;

    this.mapa = L.map(this.mapaDiv.nativeElement).setView(centroInicial, ZOOM_DEFECTO);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; OpenStreetMap',
    }).addTo(this.mapa);

    if (tieneUbicacion) {
      this.colocarMarcador(this.latitud()!, this.longitud()!);
    }

    this.mapa.on('click', (evento: L.LeafletMouseEvent) => {
      this.colocarMarcador(evento.latlng.lat, evento.latlng.lng);
      this.ubicacionSeleccionada.emit({ latitud: evento.latlng.lat, longitud: evento.latlng.lng });
    });

    // Dentro de ion-content el tamano final del div se conoce despues de este punto;
    // sin esto el mapa se ve gris o cortado.
    setTimeout(() => this.mapa.invalidateSize(), 300);
  }

  private colocarMarcador(lat: number, lng: number): void {
    if (this.marcador) {
      this.marcador.setLatLng([lat, lng]);
      return;
    }
    // circleMarker en vez de marker: el icono por defecto de Leaflet sale roto
    // con el empaquetador de Angular, asi se evita configurar assets.
    this.marcador = L.circleMarker([lat, lng], { radius: 8 }).addTo(this.mapa);
  }

  ngOnDestroy(): void {
    this.mapa.remove();
  }
}
