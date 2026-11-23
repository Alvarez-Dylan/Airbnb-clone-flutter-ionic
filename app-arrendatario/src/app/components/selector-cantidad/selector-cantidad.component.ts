// Selector de cantidad reutilizable (-/+): usado en personas, camas, banios y habitaciones del formulario.
import { Component, input, output } from '@angular/core';
import { IonButton, IonIcon } from '@ionic/angular';
import { addIcons } from 'ionicons';
import { removeOutline, addOutline } from 'ionicons/icons';

@Component({
  selector: 'app-selector-cantidad',
  templateUrl: 'selector-cantidad.component.html',
  styleUrls: ['selector-cantidad.component.scss'],
  imports: [IonButton, IonIcon],
})
export class SelectorCantidadComponent {
  etiqueta = input('');
  icono = input('');
  valor = input(1);
  minimo = input(1);
  cambio = output<number>();

  constructor() {
    addIcons({ 'remove-outline': removeOutline, 'add-outline': addOutline });
  }

  sumar(): void {
    this.cambio.emit(this.valor() + 1);
  }

  restar(): void {
    if (this.valor() > this.minimo()) {
      this.cambio.emit(this.valor() - 1);
    }
  }
}
