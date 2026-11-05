// Usuario arrendatario logueado. Usado por AuthService y las paginas de sesion.
export interface Usuario {
  id: number;
  nombrecompleto: string;
  email: string;
  telefono: string;
}
