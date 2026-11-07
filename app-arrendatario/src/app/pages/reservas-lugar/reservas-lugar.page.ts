// Lista de reservas de un lugar. Temporal hasta la Fase A6.
import { Component, inject } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { IonHeader, IonToolbar, IonTitle, IonContent } from '@ionic/angular';

@Component({
  selector: 'app-reservas-lugar',
  templateUrl: 'reservas-lugar.page.html',
  styleUrls: ['reservas-lugar.page.scss'],
  imports: [IonHeader, IonToolbar, IonTitle, IonContent],
})
export class ReservasLugarPage {
  private ruta = inject(ActivatedRoute);

  idLugar = this.ruta.snapshot.paramMap.get('id');
}
