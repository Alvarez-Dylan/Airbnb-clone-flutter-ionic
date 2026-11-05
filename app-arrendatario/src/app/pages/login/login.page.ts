// Pantalla de login del arrendatario. Si el login funciona, guarda la sesion y entra a mis-lugares.
import type { HttpErrorResponse } from '@angular/common/http';
import { Component, inject, signal } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import {
  IonHeader,
  IonToolbar,
  IonTitle,
  IonContent,
  IonItem,
  IonLabel,
  IonInput,
  IonButton,
  ToastController,
} from '@ionic/angular';

import { AuthService } from '../../services/auth.service';
import { mensajeDeError } from '../../utils/manejar-error';

@Component({
  selector: 'app-login',
  templateUrl: 'login.page.html',
  styleUrls: ['login.page.scss'],
  imports: [
    FormsModule,
    RouterLink,
    IonHeader,
    IonToolbar,
    IonTitle,
    IonContent,
    IonItem,
    IonLabel,
    IonInput,
    IonButton,
  ],
})
export class LoginPage {
  private authService = inject(AuthService);
  private router = inject(Router);
  private toastController = inject(ToastController);

  email = '';
  password = '';
  enviando = signal(false);

  iniciarSesion(): void {
    this.enviando.set(true);
    this.authService.iniciarSesion(this.email, this.password).subscribe({
      next: (usuario) => {
        this.authService.guardarSesion(usuario);
        this.enviando.set(false);
        this.router.navigate(['mis-lugares']);
      },
      error: async (error: HttpErrorResponse) => {
        this.enviando.set(false);
        const toast = await this.toastController.create({
          message: mensajeDeError(error),
          duration: 3000,
          color: 'danger',
        });
        toast.present();
      },
    });
  }
}
