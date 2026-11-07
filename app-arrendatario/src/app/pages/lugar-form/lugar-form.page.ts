// Formulario de lugar: crea uno nuevo o edita uno existente segun si la ruta
// trae id (patron notaSeleccionada del practico 2).
import type { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonButtons,
  IonItem,
  IonLabel,
  IonInput,
  IonToggle,
  IonButton,
  IonIcon,
  IonSpinner,
  ToastController,
} from '@ionic/angular';
import { addIcons } from 'ionicons';
import { add, closeCircle } from 'ionicons/icons';
import { firstValueFrom } from 'rxjs';

import { MapaSelectorComponent } from '../../components/mapa-selector/mapa-selector.component';
import type { Foto } from '../../models/lugar';
import { AuthService } from '../../services/auth.service';
import { LugaresService } from '../../services/lugares.service';
import { aBooleano, aNumero, urlFoto } from '../../utils/formato';
import { mensajeDeError } from '../../utils/manejar-error';

interface FormularioLugar {
  nombre: string;
  descripcion: string;
  cantPersonas: string;
  cantCamas: string;
  cantBanios: string;
  cantHabitaciones: string;
  tieneWifi: boolean;
  tieneParqueo: boolean;
  cantVehiculosParqueo: string;
  precioNoche: string;
  costoLimpieza: string;
  ciudad: string;
}

interface FotoNueva {
  archivo: File;
  previewUrl: string;
}

function formularioVacio(): FormularioLugar {
  return {
    nombre: '',
    descripcion: '',
    cantPersonas: '',
    cantCamas: '',
    cantBanios: '',
    cantHabitaciones: '',
    tieneWifi: false,
    tieneParqueo: false,
    cantVehiculosParqueo: '',
    precioNoche: '',
    costoLimpieza: '',
    ciudad: '',
  };
}

@Component({
  selector: 'app-lugar-form',
  templateUrl: 'lugar-form.page.html',
  styleUrls: ['lugar-form.page.scss'],
  imports: [
    FormsModule,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonButtons,
    IonItem,
    IonLabel,
    IonInput,
    IonToggle,
    IonButton,
    IonIcon,
    IonSpinner,
    MapaSelectorComponent,
  ],
})
export class LugarFormPage {
  private ruta = inject(ActivatedRoute);
  private router = inject(Router);
  private authService = inject(AuthService);
  private lugaresService = inject(LugaresService);
  private toastController = inject(ToastController);

  // Si la ruta trae id, es modo editar (patron notaSeleccionada del practico 2).
  idLugar = this.ruta.snapshot.paramMap.get('id');
  modoEditar = this.idLugar !== null;

  cargando = signal(this.modoEditar);
  guardando = signal(false);

  formulario: FormularioLugar = formularioVacio();
  ubicacion: { latitud: number; longitud: number } | null = null;
  fotosExistentes: Foto[] = [];
  fotosNuevas: FotoNueva[] = [];

  // Expuesta al template.
  urlFoto = urlFoto;

  constructor() {
    addIcons({ add, 'close-circle': closeCircle });
    if (this.modoEditar) {
      this.cargarLugar();
    }
  }

  private cargarLugar(): void {
    this.lugaresService.obtenerLugar(Number(this.idLugar)).subscribe({
      next: (lugar) => {
        this.formulario = {
          nombre: lugar.nombre,
          descripcion: lugar.descripcion,
          cantPersonas: String(lugar.cantPersonas),
          cantCamas: String(lugar.cantCamas),
          cantBanios: String(lugar.cantBanios),
          cantHabitaciones: String(lugar.cantHabitaciones),
          tieneWifi: aBooleano(lugar.tieneWifi),
          tieneParqueo: aNumero(lugar.cantVehiculosParqueo) > 0,
          cantVehiculosParqueo: String(lugar.cantVehiculosParqueo),
          precioNoche: String(aNumero(lugar.precioNoche)),
          costoLimpieza: String(aNumero(lugar.costoLimpieza)),
          ciudad: lugar.ciudad,
        };
        this.ubicacion = {
          latitud: Number(lugar.latitud),
          longitud: Number(lugar.longitud),
        };
        this.fotosExistentes = lugar.fotos;
        this.cargando.set(false);
      },
      error: async (error: HttpErrorResponse) => {
        this.cargando.set(false);
        await this.mostrarToast(mensajeDeError(error));
      },
    });
  }

  alSeleccionarUbicacion(ubicacion: { latitud: number; longitud: number }): void {
    this.ubicacion = ubicacion;
  }

  alSeleccionarFotos(evento: Event): void {
    const input = evento.target as HTMLInputElement;
    if (!input.files) {
      return;
    }
    for (const archivo of Array.from(input.files)) {
      this.fotosNuevas.push({ archivo, previewUrl: URL.createObjectURL(archivo) });
    }
    input.value = '';
  }

  quitarFoto(indice: number): void {
    this.fotosNuevas.splice(indice, 1);
  }

  irAReservas(): void {
    this.router.navigate(['lugar', this.idLugar, 'reservas']);
  }

  async guardar(): Promise<void> {
    const error = this.validar();
    if (error) {
      await this.mostrarToast(error);
      return;
    }

    const usuario = this.authService.usuarioActual();
    if (!usuario) {
      return;
    }

    const f = this.formulario;
    const body = {
      nombre: f.nombre,
      descripcion: f.descripcion,
      cantPersonas: Number(f.cantPersonas),
      cantCamas: Number(f.cantCamas),
      cantBanios: Number(f.cantBanios),
      cantHabitaciones: Number(f.cantHabitaciones),
      tieneWifi: f.tieneWifi ? 1 : 0,
      cantVehiculosParqueo: f.tieneParqueo ? Number(f.cantVehiculosParqueo) : 0,
      precioNoche: Number(f.precioNoche),
      costoLimpieza: Number(f.costoLimpieza),
      ciudad: f.ciudad,
      latitud: String(this.ubicacion!.latitud),
      longitud: String(this.ubicacion!.longitud),
      arrendatario_id: usuario.id,
    };

    this.guardando.set(true);

    // Aca se usa async/await en vez de subscribe: guardar/editar el lugar y
    // subir las fotos son pasos en orden (recien se puede subir una foto
    // cuando se conoce el id del lugar), al revés que el resto de la app
    // donde cada pantalla hace una sola peticion independiente.
    try {
      const idLugar = this.modoEditar
        ? (await firstValueFrom(this.lugaresService.editarLugar(Number(this.idLugar), body))).id
        : (await firstValueFrom(this.lugaresService.guardarLugar(body))).id;

      for (const foto of this.fotosNuevas) {
        try {
          await firstValueFrom(this.lugaresService.subirFoto(idLugar, foto.archivo));
        } catch {
          this.guardando.set(false);
          await this.mostrarToast(`No se pudo subir la foto ${foto.archivo.name}`);
          return;
        }
      }

      this.guardando.set(false);
      await this.mostrarToast('Lugar guardado', 'success');
      this.router.navigate(['mis-lugares']);
    } catch (error) {
      this.guardando.set(false);
      await this.mostrarToast(mensajeDeError(error as HttpErrorResponse));
    }
  }

  private validar(): string | null {
    const f = this.formulario;
    if (!f.nombre.trim()) return 'Ingresa el nombre del lugar';
    if (!f.descripcion.trim()) return 'Ingresa una descripcion';
    if (!f.ciudad.trim()) return 'Ingresa la ciudad';
    // Al editar ya existe al menos una foto (la API no permite borrarlas).
    if (!this.modoEditar && this.fotosNuevas.length === 0) return 'Agrega al menos una foto';
    if (Number(f.cantPersonas) < 1) return 'La cantidad de personas debe ser al menos 1';
    if (Number(f.cantCamas) < 1) return 'La cantidad de camas debe ser al menos 1';
    if (Number(f.cantBanios) < 1) return 'La cantidad de banios debe ser al menos 1';
    if (Number(f.cantHabitaciones) < 1) return 'La cantidad de habitaciones debe ser al menos 1';
    if (f.tieneParqueo && Number(f.cantVehiculosParqueo) < 1) {
      return 'Ingresa la cantidad de vehiculos de parqueo';
    }
    if (Number(f.precioNoche) < 0) return 'El precio por noche no puede ser negativo';
    if (Number(f.costoLimpieza) < 0) return 'El costo de limpieza no puede ser negativo';
    if (!this.ubicacion) return 'Selecciona la ubicacion en el mapa';
    return null;
  }

  private async mostrarToast(mensaje: string, color: 'success' | 'danger' = 'danger'): Promise<void> {
    const toast = await this.toastController.create({ message: mensaje, duration: 3000, color });
    toast.present();
  }
}
