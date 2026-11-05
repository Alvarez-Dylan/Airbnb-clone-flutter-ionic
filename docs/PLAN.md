# Plan de trabajo

## Antes de empezar (una sola vez)

Instalado en la PC: Git, Node.js LTS, Ionic CLI (`npm i -g @ionic/cli`), Flutter SDK + Android Studio con un emulador (revisar con `flutter doctor`), VS Code con Claude Code.

1. Descomprimir el kit en una carpeta `bnb-proyecto-final/`.
2. Abrirla en VS Code y, en la terminal, ejecutar `git init` y hacer el primer commit con el kit.
3. Iniciar Claude Code **en la raíz** del repositorio, para que lea `CLAUDE.md`.

## Cómo ejecutar cada fase

1. Conversación nueva de Claude Code (`/clear`), para no arrastrar contexto de otra fase.
2. Pegar el prompt de la fase.
3. Revisar el plan que propone. Si algo no coincide con este documento, corregirlo antes de aprobar.
4. Al terminar, hacer la prueba de **Listo cuando**.
5. Leer la entrada nueva de `docs/ESTUDIO.md` y hacer su ejercicio a mano, sin IA.
6. Commit.

Si algo falla: pegar el error completo y pedir "explícame la causa antes de corregirlo".

## Orden y por qué

Fase 0 → Fase 1 → A1 … A6 (arrendatario) → C1 … C7 (cliente) → Fase final.

Se empieza por el arrendatario porque crea los lugares con fotos que después la app cliente busca y reserva: así hay datos propios para probar. Además, lo más difícil (subir fotos y elegir ubicación en un mapa) queda al inicio, cuando hay más tiempo.

---

## Fase 0 — Verificar la API (sin código de las apps)

**Prompt**
```text
Ejecuta la Fase 0 de docs/PLAN.md siguiendo CLAUDE.md. No escribas código de las apps. Ve petición por petición y muéstrame cada resultado antes de seguir.
```

**Leer**: `CLAUDE.md`, `docs/API.md`.

**Hacer**
- Ejecutar el procedimiento de `docs/API.md` en el orden indicado.
- Guardar cada respuesta en `docs/api-ejemplos/`.
- Completar la tabla de respuestas, responder las 12 preguntas y quitar cada `⚠ VERIFICAR` confirmado.
- Si alguna decisión de `CLAUDE.md` o de `docs/contexto-apps/` deja de ser válida (por ejemplo, la API exige token o no permite editar), proponerme el cambio y esperar mi OK.

**Listo cuando**: `docs/API.md` dice **VERIFICADO** y existen un arrendatario, un lugar con foto, un cliente y una reserva de prueba.

**Debo poder explicar**: qué endpoint usa cada pantalla, qué devuelve el login y cómo llegan las fotos.

---

## Fase 1 — Crear los dos proyectos

**Prompt**
```text
Ejecuta la Fase 1 de docs/PLAN.md siguiendo CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de ejecutar comandos o escribir código.
```

**Leer**: `CLAUDE.md`, `docs/contexto-apps/cliente.CLAUDE.md`, `docs/contexto-apps/arrendatario.CLAUDE.md`, `docs/API.md`.

**Hacer**
- **Cliente**:
  - `flutter create --project-name bnb_cliente --org bo.edu.nur app-cliente`.
  - Mover `docs/contexto-apps/cliente.CLAUDE.md` a `app-cliente/CLAUDE.md`.
  - `flutter pub add provider dio shared_preferences flutter_map latlong2 intl`.
  - Permiso de INTERNET en `AndroidManifest.xml`.
  - Crear `lib/config/api_config.dart` con la URL base y el `Dio` configurado.
  - Reemplazar el contador de ejemplo por un `main.dart` mínimo con `MaterialApp` y una pantalla temporal; borrar el test de ejemplo que deja de compilar.
- **Arrendatario**:
  - Yo ejecuto en mi terminal (es interactivo): `ionic start app-arrendatario blank --type=angular --capacitor --no-git`, elijo **Standalone** y respondo **No** a crear cuenta de Ionic. Esperar a que te avise.
  - Mover `docs/contexto-apps/arrendatario.CLAUDE.md` a `app-arrendatario/CLAUDE.md`.
  - `npm i leaflet@1.9` y `npm i -D @types/leaflet@1.9`; agregar el CSS de Leaflet a `angular.json`.
  - `apiUrl` en `environment.ts` y `environment.prod.ts` (crearlos si no existen).
  - `provideHttpClient()` en `src/main.ts`.
- Borrar la carpeta `docs/contexto-apps/` (ya vacía).
- Entrada en `docs/ESTUDIO.md`: estructura de cada proyecto y para qué sirve cada archivo importante generado (`pubspec.yaml`, `main.dart`, `AndroidManifest.xml`, `angular.json`, `main.ts`, `app.routes.ts`, `environments/`).

**Listo cuando**: `flutter analyze` sin errores y la app abre en el emulador; `npm run build` sin errores e `ionic serve` muestra la app.

**Debo poder explicar**: por qué cada app usa una tecnología distinta y dónde se cambia la URL de la API.

---

## Fase A1 — Arrendatario: sesión (login, registro, protección de rutas)

**Requisitos**: RA-01, RA-02, RG-02, RX-01, RX-02.

**Prompt**
```text
Ejecuta la Fase A1 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `models/usuario.ts` según `docs/API.md`.
- `AuthService`: `iniciarSesion`, `registrar`, `guardarSesion`, `usuarioActual`, `haySesion`, `cerrarSesion` (clave de `localStorage`: `sesionArrendatario`).
- `guards/auth.guard.ts` como función `CanActivateFn`.
- `LoginPage` (email, contraseña, "Iniciar sesión", "Registrarse") y `RegistroPage` (nombre completo, email, contraseña, teléfono, "Registrarse", "Iniciar sesión"). Registro exitoso → login automático → `mis-lugares`.
- `MisLugaresPage` temporal con título y botón de cerrar sesión en la barra superior.
- Reemplazar la página `home` del starter y eliminarla.

**Listo cuando**: un registro nuevo entra directo a la app; cerrar sesión vuelve al login; recargar el navegador con sesión no pide login; abrir `/mis-lugares` sin sesión redirige a `/login`; un login incorrecto muestra un mensaje claro.

**Debo poder explicar**: dónde y por qué se guarda la sesión, qué hace el guard y qué pasa paso a paso al registrarse.

---

## Fase A2 — Arrendatario: lista de mis lugares

**Requisitos**: RA-03, RA-04.

**Prompt**
```text
Ejecuta la Fase A2 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `models/lugar.ts` según `docs/API.md` y `utils/formato.ts` (`aNumero`, `urlFoto`, `formatearPrecio`).
- `LugaresService.misLugares(idArrendatario)`.
- `MisLugaresPage`: `ion-list` con primera foto (o placeholder), nombre, ciudad y precio por noche; estados cargando / error / vacío; `ion-fab` con "+" → `lugar/nuevo`; tocar un ítem → `lugar/:id`. Carga en `ionViewWillEnter`.
- Rutas `lugar/nuevo` y `lugar/:id` hacia una `LugarFormPage` temporal.

**Listo cuando**: aparece el lugar de prueba de la Fase 0 con su foto, y el "+" y los ítems navegan.

**Debo poder explicar**: `ionViewWillEnter` frente a `ngOnInit`, y los signals `cargando`, `error` y `lugares`.

---

## Fase A3 — Arrendatario: formulario para crear un lugar + mapa

**Requisitos**: RA-05, RA-06, RA-08 (sin fotos todavía).

**Prompt**
```text
Ejecuta la Fase A3 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `LugarFormPage` en modo crear con todos los campos de RA-05: wifi con `ion-toggle`; parqueo con `ion-toggle` y la cantidad de vehículos visible solo si está activo.
- `MapaSelectorComponent` según `app-arrendatario/CLAUDE.md`.
- Validación: todos los campos obligatorios, personas, camas, baños y habitaciones ≥ 1, precios ≥ 0 y ubicación elegida. Mostrar el primer error con un toast.
- Guardar: `LugaresService.guardarLugar(body)` → toast → volver a `mis-lugares`.
- Todavía sin fotos (Fase A4).

**Listo cuando**: un lugar creado aparece en la lista, y su latitud y longitud coinciden con el punto marcado (revisar con `GET lugares/{id}`).

**Debo poder explicar**: cómo funciona `[(ngModel)]`, cómo se arma el body (`Number()`, `1/0`, parqueo en `0`) y cómo el mapa devuelve la ubicación con `output()`.

---

## Fase A4 — Arrendatario: fotos del lugar

**Requisitos**: RA-07, RA-08.

**Prompt**
```text
Ejecuta la Fase A4 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- Selector múltiple de fotos con vista previa y opción de quitar una foto antes de guardar.
- `LugaresService.subirFoto(idLugar, archivo)` con `FormData`.
- Guardar con `async/await`: `guardarLugar` → id → `for...of` sobre las fotos → `subirFoto`. Indicador de carga durante todo el proceso; si una foto falla, avisar cuál.
- Al crear, exigir al menos una foto.

**Listo cuando**: un lugar nuevo con 2 o 3 fotos aparece en la lista con la primera foto.

**Debo poder explicar**: `multipart/form-data` frente a JSON, por qué no se pone `Content-Type` a mano y por qué aquí se usa `async/await`.

---

## Fase A5 — Arrendatario: editar un lugar

**Requisitos**: RA-09, RA-10.

**Prompt**
```text
Ejecuta la Fase A5 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- Con `id` en la ruta: `GET lugares/{id}`, precargar formulario, fotos existentes y mapa con la ubicación guardada. Título "Editar lugar".
- Guardar en modo editar con `PUT lugares/{id}` (confirmado en Fase 0: `POST` con `id` adentro NO actualiza, duplica el lugar). Subir solo las fotos nuevas.
- Botón "Ver reservas" solo en modo editar → `lugar/:id/reservas` (página temporal hasta A6).

**Listo cuando**: se edita un campo y la ubicación, se guarda, y al volver a abrir el lugar aparecen los cambios sin que se haya duplicado.

**Debo poder explicar**: cómo la misma página sabe si crea o edita (comparar con `notaSeleccionada` del práctico 2).

---

## Fase A6 — Arrendatario: reservas de un lugar

**Requisitos**: RA-11.

**Prompt**
```text
Ejecuta la Fase A6 de docs/PLAN.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `models/reserva.ts` y `ReservasService.reservasDeLugar(idLugar)`.
- `ReservasLugarPage`: por cada reserva, primera foto del lugar, cantidad de noches (calculada), fecha de llegada, fecha de salida (`dd/MM/yyyy`), nombre del cliente y precio total. Estados; vacío: "Este lugar aún no tiene reservas".
- La primera foto sale de `GET lugares/{id}` o de la respuesta de reservas, según `docs/API.md`.

**Listo cuando**: la reserva de prueba de la Fase 0 aparece con noches, fechas y total correctos.

**Debo poder explicar**: cómo se calculan las noches y por qué las fechas se formatean partiendo el texto.

---

## Fase C1 — Cliente: sesión (login y registro)

**Requisitos**: RC-01, RC-02, RG-02, RX-01, RX-02.

**Prompt**
```text
Ejecuta la Fase C1 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `usuario_model.dart`, `auth_service.dart`, `auth_provider.dart` (clave de `shared_preferences`: `sesionCliente`).
- `LoginScreen` y `RegistroScreen` como en el wireframe. Registro exitoso → login automático → `BusquedaScreen`.
- `main.dart` con `MultiProvider` y pantalla inicial según la sesión.
- `BusquedaScreen` temporal con botón de cerrar sesión en la `AppBar`.

**Listo cuando**: igual que A1, pero en la app Flutter (cerrar y volver a abrir la app mantiene la sesión).

**Debo poder explicar**: `ChangeNotifier` frente a `signal()`, qué guarda `shared_preferences` y por qué `cargarSesion()` va antes de `runApp`.

---

## Fase C2 — Cliente: búsqueda simple y resultados en lista

**Requisitos**: RC-03, RC-04, RC-07.

**Prompt**
```text
Ejecuta la Fase C2 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `lugar_model.dart`, `utils/conversiones.dart`, `lugar_service.buscar`, `busqueda_provider.dart`, `widget/vista_estado.dart`.
- `BusquedaScreen`: ciudad, fecha de llegada y de salida con `showDatePicker`, cantidad de huéspedes; botones "Buscar", "Búsqueda avanzada" y "Ver reservas" (estos dos abren pantallas temporales hasta C7 y C6).
- `ResultadosScreen` en modo lista con `LugarCard`: primera foto, nombre, descripción (máximo 2 líneas), personas y precio por noche.
- Filtro local por huéspedes, comentado.

**Listo cuando**: buscar "Santa Cruz" muestra el lugar de prueba; no deja buscar con salida anterior o igual a la llegada.

**Debo poder explicar**: dónde quedan guardadas las fechas y por qué (se usan al reservar).

---

## Fase C3 — Cliente: vista de mapa

**Requisitos**: RC-08, RC-09, RC-10.

**Prompt**
```text
Ejecuta la Fase C3 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Revisa la API de flutter_map de la versión instalada. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `widget/mapa_lugares.dart`: `FlutterMap` con `TileLayer` de OpenStreetMap y `MarkerLayer`, un marcador por lugar con su precio; centrado en el primer resultado o en Santa Cruz.
- Botón inferior "Vista de mapa" / "Vista de lista" que cambia `verMapa`.
- Tocar un ítem de la lista o un marcador → `DetalleLugarScreen` (temporal hasta C4).

**Listo cuando**: el lugar de prueba aparece en el punto correcto y se puede ir y volver entre lista y mapa.

**Debo poder explicar**: qué es un tile, cómo se arma un `Marker` y por qué el mapa necesita `Expanded`.

---

## Fase C4 — Cliente: detalle del lugar con galería

**Requisitos**: RC-10, RC-11, RC-12, RC-13.

**Prompt**
```text
Ejecuta la Fase C4 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `lugar_service.obtenerLugar`, `DetalleLugarScreen`, `widget/galeria_fotos.dart`.
- Todos los datos de RC-12. Wifi: "Sí" / "No". Parqueo: "Para N vehículos" o "No tiene".
- Botón "Reservar" → `ConfirmarReservaScreen(lugar)` (temporal hasta C5).

**Listo cuando**: tocar cada miniatura cambia la foto grande y todos los datos coinciden con `GET lugares/{id}`.

**Debo poder explicar**: el `StatefulWidget` de la galería y el índice de la foto seleccionada.

---

## Fase C5 — Cliente: confirmar reserva

**Requisitos**: RC-14, RC-15.

**Prompt**
```text
Ejecuta la Fase C5 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `utils/calculo_reserva.dart`: funciones puras y la constante `porcentajeServicio = 0.10`, según `CLAUDE.md`.
- `reserva_service.crearReserva`, `reserva_provider.confirmarReserva`.
- `ConfirmarReservaScreen`: "N noches × $us X" = subtotal, limpieza, servicio y total. Botón "Confirmar reserva" deshabilitado mientras envía.
- Éxito: SnackBar y volver a la pantalla principal.

**Listo cuando**: con 4 noches a $us 30 y limpieza $us 5 se muestra 120 + 5 + 12 = 137, y la reserva aparece en `GET reservas/cliente/{id}`.

**Debo poder explicar**: cada línea del cálculo con un ejemplo y qué datos se mandan a la API.

---

## Fase C6 — Cliente: mis reservas

**Requisitos**: RC-06, RC-16.

**Prompt**
```text
Ejecuta la Fase C6 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `reserva_model.dart`, `reserva_service.obtenerReservasCliente`, `MisReservasScreen`.
- Cada ítem: foto, nombre del lugar, noches, fecha de inicio, fecha de fin y precio total (y anfitrión si la API lo trae). Si la respuesta no trae datos del lugar, pedir `GET lugares/{id}` por reserva, según `docs/API.md`.

**Listo cuando**: aparece la reserva hecha en C5 con sus datos correctos.

**Debo poder explicar**: de dónde sale cada dato del ítem.

---

## Fase C7 — Cliente: búsqueda avanzada

**Requisitos**: RC-05.

**Prompt**
```text
Ejecuta la Fase C7 de docs/PLAN.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Primero muéstrame tu plan y espera mi OK antes de escribir código.
```

**Hacer**
- `BusquedaAvanzadaScreen`: campos de la búsqueda simple + descripción, camas, baños, habitaciones, wifi (switch), vehículos de parqueo y precio por noche. Confirmado en Fase 0: estos campos hacen coincidencia EXACTA (no mínimo/máximo) y `ciudad` es obligatorio; el body que arma la pantalla debe incluir solo las claves de los campos que el usuario llenó (omitir, no mandar en `0`, los que dejó vacíos).
- `lugar_service.busquedaAvanzada` y `BusquedaProvider.buscarAvanzado`; reutiliza `ResultadosScreen`.
- Si el enunciado exige un campo que la API no filtra, filtrarlo localmente después de recibir los resultados (como huéspedes en C2) y comentarlo.

**Listo cuando**: filtros que excluyen al lugar de prueba lo ocultan y filtros compatibles lo muestran.

**Debo poder explicar**: qué hace la API y qué filtra la app.

---

## Fase final — Revisión y preparación de la defensa

**Prompt**
```text
Ejecuta la Fase final de docs/PLAN.md siguiendo CLAUDE.md. Primero muéstrame la lista de lo que vas a revisar y espera mi OK.
```

**Hacer**
- Recorrer `docs/REQUISITOS.md` uno por uno contra el código; nada queda sin `✔`.
- `flutter analyze` sin advertencias; `npm run build` sin errores.
- Limpieza: imports sin uso, código comentado, archivos de plantilla, `print` / `console.log`.
- Darme los pasos de la prueba completa: arrendatario crea un lugar con fotos → cliente lo busca (lista y mapa) → ve el detalle → reserva → arrendatario ve la reserva.
- Completar en `docs/ESTUDIO.md` la sección "Preparación para la defensa".
- Opcional: selector de fechas en español con `flutter_localizations`; nombre e ícono de las apps.

**Listo cuando**: la prueba completa funciona sin errores y puedo explicar cada pantalla sin mirar la bitácora.
