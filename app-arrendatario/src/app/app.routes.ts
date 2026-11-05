import type { Routes } from '@angular/router';

import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  {
    path: 'login',
    loadComponent: () => import('./pages/login/login.page').then((m) => m.LoginPage),
  },
  {
    path: 'registro',
    loadComponent: () => import('./pages/registro/registro.page').then((m) => m.RegistroPage),
  },
  {
    path: 'mis-lugares',
    loadComponent: () =>
      import('./pages/mis-lugares/mis-lugares.page').then((m) => m.MisLugaresPage),
    canActivate: [authGuard],
  },
  {
    path: '',
    redirectTo: 'mis-lugares',
    pathMatch: 'full',
  },
];
