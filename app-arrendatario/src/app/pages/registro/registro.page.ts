// Registro del arrendatario. Si funciona, inicia sesion automaticamente y entra a mis-lugares.
import type { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonCard,
  IonCardContent,
  IonInput,
  IonInputPasswordToggle,
  IonButton,
  IonIcon,
  ToastController,
} from '@ionic/angular';
import { addIcons } from 'ionicons';
import { homeOutline, mailOutline, callOutline, arrowForward } from 'ionicons/icons';

import { AuthService } from '../../services/auth.service';
import { mensajeDeError } from '../../utils/manejar-error';

@Component({
  selector: 'app-registro',
  templateUrl: 'registro.page.html',
  styleUrls: ['registro.page.scss'],
  imports: [
    FormsModule,
    RouterLink,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonCard,
    IonCardContent,
    IonInput,
    IonInputPasswordToggle,
    IonButton,
    IonIcon,
  ],
})
export class RegistroPage {
  private authService = inject(AuthService);
  private router = inject(Router);
  private toastController = inject(ToastController);

  nombrecompleto = '';
  email = '';
  password = '';
  telefono = '';
  enviando = signal(false);

  constructor() {
    addIcons({
      'home-outline': homeOutline,
      'mail-outline': mailOutline,
      'call-outline': callOutline,
      'arrow-forward': arrowForward,
    });
  }

  registrar(): void {
    this.enviando.set(true);
    this.authService
      .registrar({
        nombrecompleto: this.nombrecompleto,
        email: this.email,
        password: this.password,
        telefono: this.telefono,
      })
      .subscribe({
        next: () => {
          // Registro exitoso: inicia sesion automatico con el mismo email y contrasena (CLAUDE.md).
          this.authService.iniciarSesion(this.email, this.password).subscribe({
            next: (usuario) => {
              this.authService.guardarSesion(usuario);
              this.enviando.set(false);
              this.router.navigate(['mis-lugares']);
            },
            error: async (error: HttpErrorResponse) => {
              this.enviando.set(false);
              await this.mostrarError(error);
            },
          });
        },
        error: async (error: HttpErrorResponse) => {
          this.enviando.set(false);
          await this.mostrarError(error);
        },
      });
  }

  private async mostrarError(error: HttpErrorResponse): Promise<void> {
    const toast = await this.toastController.create({
      message: mensajeDeError(error),
      duration: 3000,
      color: 'danger',
    });
    toast.present();
  }
}
