# Requisitos del enunciado

Definición de "terminado". Cada requisito sale del enunciado (PDF) o de sus wireframes. Al cerrar una fase, Claude Code completa la columna **Dónde se cumple** (archivo y función/pantalla) y marca **Hecho** con `✔`.

## Generales

| ID | Requisito | Fase | Dónde se cumple | Hecho |
|---|---|---|---|---|
| RG-01 | Las dos apps están hechas en tecnologías distintas vistas en clase (cliente: Flutter; arrendatario: Ionic + Angular) | 1 | `app-cliente/` (Flutter) y `app-arrendatario/` (Ionic + Angular), creados y compilando | ✔ |
| RG-02 | Ambas apps exigen iniciar sesión antes de entrar | A1, C1 | Arrendatario: `app-arrendatario/src/app/guards/auth.guard.ts` (falta C1 del lado cliente) | |
| RG-03 | Código propio y explicable: cada fase tiene su entrada en `docs/ESTUDIO.md` | Todas | | |

## App Cliente (Flutter)

| ID | Requisito | Fase | Dónde se cumple | Hecho |
|---|---|---|---|---|
| RC-01 | Login con email y contraseña | C1 | | |
| RC-02 | Registro con email, nombre completo, contraseña y teléfono | C1 | | |
| RC-03 | Pantalla principal con buscador: ciudad, fecha de llegada, fecha de salida y cantidad de huéspedes | C2 | | |
| RC-04 | La búsqueda simple es por ciudad | C2 | | |
| RC-05 | Botón "Búsqueda avanzada": mismos campos de la simple + todos los campos del lugar, menos foto y anfitrión | C7 | | |
| RC-06 | Botón "Ver reservas": lista de reservas hechas anteriormente por el cliente | C6 | | |
| RC-07 | Resultados en lista: primera foto, nombre, descripción, cantidad de personas y precio por noche | C2 | | |
| RC-08 | Debajo de la lista, botón "Vista de mapa": los mismos lugares como marcadores en un mapa | C3 | | |
| RC-09 | En el mapa, botón "Vista de lista" para volver a la lista | C3 | | |
| RC-10 | Al seleccionar un lugar (desde lista o mapa) se abre su página de detalle | C3, C4 | | |
| RC-11 | Detalle: primera foto en grande y las demás pequeñas debajo; tocar una pequeña la muestra en grande | C4 | | |
| RC-12 | Detalle: nombre, descripción, personas, camas, baños, nombre del anfitrión, precio por noche, habitaciones, si tiene wifi y parqueo para cuántos vehículos | C4 | | |
| RC-13 | Detalle: botón "Reservar" que lleva a confirmar reserva | C4 | | |
| RC-14 | Confirmar reserva: precio total por la cantidad de noches, gastos de limpieza, cobro por servicio y el total sumado | C5 | | |
| RC-15 | Botón "Confirmar reserva" que envía la reserva a la API | C5 | | |
| RC-16 | (Wireframe) Lista de reservas del cliente con foto, nombre del lugar, noches, fecha de inicio, fecha de fin y precio | C6 | | |

## App Arrendatario (Ionic + Angular)

| ID | Requisito | Fase | Dónde se cumple | Hecho |
|---|---|---|---|---|
| RA-01 | Login con email y contraseña | A1 | `src/app/pages/login/login.page.ts` + `src/app/services/auth.service.ts` | ✔ |
| RA-02 | Registro con email, nombre completo, contraseña y teléfono | A1 | `src/app/pages/registro/registro.page.ts` + `src/app/services/auth.service.ts` | ✔ |
| RA-03 | Pantalla principal: lista de los lugares del arrendatario con primera foto, nombre, ciudad y precio por noche | A2 | `src/app/pages/mis-lugares/mis-lugares.page.ts` + `.html` | ✔ |
| RA-04 | Botón para agregar un nuevo lugar | A2 | `mis-lugares.page.html` (`ion-fab` → `lugar/nuevo`) | ✔ |
| RA-05 | Formulario: nombre, descripción, personas, camas, baños, habitaciones, wifi sí/no, parqueo para cuántos vehículos, precio por noche, costo de limpieza y ciudad | A3 | `src/app/pages/lugar-form/lugar-form.page.html` | ✔ |
| RA-06 | Formulario: seleccionar en un mapa la ubicación exacta del lugar | A3 | `src/app/components/mapa-selector/mapa-selector.component.ts` | ✔ |
| RA-07 | Formulario: agregar una o más fotos | A4 | `lugar-form.page.ts` (`alSeleccionarFotos`, `quitarFoto`) + `lugar-form.page.html` | ✔ |
| RA-08 | Al guardar se envía a la API y se vuelve a la pantalla anterior | A3, A4 | `lugar-form.page.ts` → `guardar()` (crear y editar) | ✔ |
| RA-09 | Al seleccionar un lugar de la lista se abre el mismo formulario con los datos cargados y la ubicación guardada | A5 | `lugar-form.page.ts` → `cargarLugar()` | ✔ |
| RA-10 | En un lugar existente aparece el botón "Ver reservas" | A5 | `lugar-form.page.html` (`ion-buttons` en el header, solo si `modoEditar`) | ✔ |
| RA-11 | Lista de reservas del lugar: primera foto del lugar, cantidad de noches, fecha de llegada, fecha de salida, nombre del cliente y precio total | A6 | `src/app/pages/reservas-lugar/reservas-lugar.page.ts` + `.html` | ✔ |

## Criterios propios (no los pide el enunciado; los decidimos para que la app sea usable)

| ID | Criterio | Fase | Dónde se cumple | Hecho |
|---|---|---|---|---|
| RX-01 | Cerrar sesión en ambas apps | A1, C1 | Arrendatario: `mis-lugares.page.ts` → `cerrarSesion()` (falta C1 del lado cliente) | |
| RX-02 | La sesión se mantiene al cerrar y abrir la app | A1, C1 | Arrendatario: `AuthService.usuarioActual()` lee `localStorage` (falta C1 del lado cliente) | |
| RX-03 | Validaciones de formularios con mensajes claros (campos obligatorios, llegada antes que salida, ubicación elegida) | Todas | | |
| RX-04 | Estados cargando / error / vacío en toda pantalla que pide datos | Todas | | |
| RX-05 | Botones de envío deshabilitados mientras se espera la respuesta | Todas | | |
