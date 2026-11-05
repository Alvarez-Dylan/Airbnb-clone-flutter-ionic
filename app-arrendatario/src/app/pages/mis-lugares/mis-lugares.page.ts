// Pantalla principal del arrendatario. Temporal hasta la Fase A2 (lista de lugares).
import { Component, inject } from '@angular/core';
import { Router } from '@angular/router';
import { IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton } from '@ionic/angular';

import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-mis-lugares',
  templateUrl: 'mis-lugares.page.html',
  styleUrls: ['mis-lugares.page.scss'],
  imports: [IonHeader, IonToolbar, IonTitle, IonContent, IonButtons, IonButton],
})
export class MisLugaresPage {
  private authService = inject(AuthService);
  private router = inject(Router);

  cerrarSesion(): void {
    this.authService.cerrarSesion();
    this.router.navigate(['login']);
  }
}
