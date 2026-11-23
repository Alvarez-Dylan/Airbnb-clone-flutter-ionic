# Bitácora de estudio

Objetivo: poder explicar cada parte del proyecto sin ayuda. Claude Code agrega una entrada al cerrar cada fase (la más reciente al final). Las explicaciones usan palabras simples y el código real del proyecto, citando archivo y función.

## Formato de cada entrada (obligatorio)

```
### Fase X — Título
- Qué se hizo: 2 a 4 líneas.
- Archivos: cada archivo creado o modificado, con una línea sobre su función.
- Flujo de datos: pasos numerados desde que el usuario toca algo hasta que ve el resultado
  (pantalla → provider/servicio → API → respuesta → pantalla).
- Conceptos clave: cada concepto nuevo en 1 o 2 líneas, indicando archivo y función donde aparece.
- Decisiones y por qué: qué se eligió y qué alternativa se descartó.
- Preguntas probables del docente: 3 preguntas con respuesta corta.
- Ejercicio para hacer a mano: un cambio pequeño que debo poder hacer sin IA
  (por ejemplo: "muestra también la ciudad en la tarjeta del resultado").
```

## Equivalencias entre las dos apps

| Concepto | App cliente (Flutter) | App arrendatario (Ionic + Angular) |
|---|---|---|
| Lenguaje | Dart | TypeScript |
| Pantalla | `StatelessWidget` / `StatefulWidget` en `screen/` | Componente standalone en `pages/` |
| Estado reactivo | `ChangeNotifier` + `notifyListeners()` | `signal()` + `.set()` |
| Leer el estado en la UI | `context.watch<T>()` / `Consumer<T>` | `lugares()` en la plantilla |
| Llamar a la API | `dio` | `HttpClient` |
| Respuesta asíncrona | `Future` + `async/await` | `Observable` + `subscribe` (y `firstValueFrom` al guardar con fotos) |
| Compartir servicios | `Provider` en `main.dart` | `inject()` |
| Modelo de datos | clase con `fromJson` | `interface` |
| Navegar | `Navigator.push(MaterialPageRoute(...))` | `router.navigate([...])` o `routerLink` |
| Pasar datos a otra pantalla | constructor de la pantalla | parámetro de ruta `:id` |
| Sesión persistente | `shared_preferences` | `localStorage` |
| Formularios | `Form` + `TextFormField` + `validator` | `FormsModule` + `[(ngModel)]` |
| Mapa | `flutter_map` (mostrar lugares) | `leaflet` (elegir ubicación) |
| Recargar al volver a una pantalla | no hace falta: el provider conserva los datos | `ionViewWillEnter()` |
| Pantallas solo con sesión | pantalla inicial según `AuthProvider` | `authGuard` en las rutas |

## Preparación para la defensa

### Recorrido de 5 minutos — App arrendatario (Ionic + Angular)

1. **Login/registro** (`pages/login`, `pages/registro`): `AuthService` llama a la API y guarda el usuario en `localStorage`. `authGuard` (`guards/auth.guard.ts`) revisa esa sesión antes de dejar entrar a cualquier ruta protegida.
2. **Mis lugares** (`pages/mis-lugares`): pantalla principal. `ionViewWillEnter()` pide `GET lugares/arrendatario/{id}` cada vez que se vuelve a esta pantalla (no en `ngOnInit`, porque Ionic no destruye la página al navegar). Botón `+` → `lugar/nuevo`.
3. **Formulario de lugar** (`pages/lugar-form`): una sola página para crear y editar (patrón "nota seleccionada" del práctico 2). Si la ruta trae `:id`, pide el lugar, precarga el formulario, la ubicación y las fotos existentes, y muestra el botón "Ver reservas". Guardar llama `POST` o `PUT` según el modo, y recién después sube las fotos nuevas una por una con `await`+`firstValueFrom()` (única excepción al patrón `subscribe`, porque son pasos que dependen uno del otro: primero necesito el `id` del lugar guardado).
4. **Mapa selector** (`components/mapa-selector`): un Leaflet embebido que muestra el punto actual (si hay) y permite tocar para moverlo; emite `ubicacionSeleccionada` hacia el formulario.
5. **Reservas del lugar** (`pages/reservas-lugar`): solo visible desde un lugar existente; pide `GET reservas/lugar/{id}` (que en realidad devuelve el lugar completo con las reservas adentro, no un arreglo plano — hay que explicar esa particularidad de la API).

### Recorrido de 5 minutos — App cliente (Flutter)

1. **main.dart**: antes de `runApp`, `AuthProvider.cargarSesion()` lee `shared_preferences`. Con sesión → `BusquedaScreen`; sin sesión → `LoginScreen`. Los tres providers (`AuthProvider`, `BusquedaProvider`, `ReservaProvider`) se registran una sola vez en el `MultiProvider` de la raíz.
2. **Login/registro**: `AuthService` + `AuthProvider`; al registrarse se inicia sesión automáticamente con el mismo email/password (así lo piden los wireframes).
3. **Buscar lugares** (pantalla principal): guarda ciudad/fechas/huéspedes en `BusquedaProvider` (se van a necesitar después, al confirmar la reserva) y llama `buscar()` (solo manda la ciudad). El botón "Búsqueda avanzada" lleva a un formulario con los mismos campos más los del lugar; el botón "Ver reservas" lleva a `MisReservasScreen`.
4. **Resultados**: `LugarCard` en lista; el botón inferior cambia a `MapaLugares` (un marcador por lugar) y viceversa — mismo `BusquedaProvider.resultados` para ambas vistas.
5. **Detalle**: pide `GET lugares/{id}` de nuevo (no reutiliza los datos parciales de la búsqueda) para mostrar siempre la versión más actual; `GaleriaFotos` maneja su propio índice de foto grande.
6. **Confirmar reserva**: toma el `LugarModel` del detalle y las fechas de `BusquedaProvider`; calcula con `calculo_reserva.dart` y envía `POST reservas` con el `cliente_id` de la sesión. Al terminar, vuelve directo a la pantalla principal (`popUntil((ruta) => ruta.isFirst)`).
7. **Mis reservas**: pide `GET reservas/cliente/{id}`, que trae el lugar de cada reserva anidado como un arreglo de 1 elemento (otra particularidad de la API a explicar).

### Las 10 preguntas más probables del docente

1. **¿Por qué cada app usa una tecnología distinta?** Porque el enunciado lo exige (ver tabla de requisitos RG-01); además así se practican dos formas distintas de manejar estado (`ChangeNotifier`/`provider` vs `signal()`) con el mismo problema de fondo.
2. **¿Cómo se mantiene la sesión si cierro la app?** Se guarda el usuario (sin token) en almacenamiento local al iniciar sesión: `shared_preferences` en Flutter, `localStorage` en Angular. Al abrir la app de nuevo, se lee antes de decidir la pantalla inicial.
3. **¿Qué pasa si la API responde un error?** Ambas apps miran la FORMA del cuerpo, no el código HTTP: `{"message": "texto"}` es un error de negocio (se muestra tal cual); `{"campo": ["mensaje"]}` es de validación (se muestra el primer mensaje). La API usa HTTP 404 para casi todos los errores, no 422 — fue un hallazgo de la Fase 0, no una suposición.
4. **¿Por qué `provider`/`signal` y no Bloc, Riverpod o NgRx?** Porque el enunciado pide reutilizar los patrones vistos en los prácticos de clase, y esos otros no se vieron (y están explícitamente prohibidos en `CLAUDE.md` del proyecto).
5. **¿Cómo decide el formulario del arrendatario si crear o editar?** Por si la ruta trae un `:id` (patrón "nota seleccionada" del práctico 2): con `id` pide el lugar y precarga todo; sin `id` arranca vacío.
6. **¿Por qué el cobro por servicio es 10% fijo?** No lo define la API ni el enunciado; es una decisión propia del proyecto, documentada en una sola constante (`porcentajeServicio` en `calculo_reserva.dart`) para poder cambiarla en un solo lugar si hiciera falta.
7. **¿Cómo se suben varias fotos de un lugar?** Una petición `multipart/form-data` por foto (campo `foto`), después de guardar el lugar y tener su `id`; la API no acepta varias fotos en una sola petición.
8. **¿Cómo se elige la ubicación en el mapa?** Un componente Leaflet (`mapa-selector`) escucha el clic, mueve un `circleMarker` (no el ícono por defecto, que sale roto con el empaquetador de Angular) y emite la latitud/longitud al formulario, que las guarda como texto (la API rechaza números).
9. **¿Por qué la búsqueda avanzada arma el body dinámicamente en vez de mandar todos los campos?** Porque la API trata "campo ausente" y "campo en `0`" como cosas distintas: mandar `0` filtra literalmente por ese valor. Se arma un mapa vacío y se le agregan solo las claves que el usuario llenó.
10. **¿Qué pasa si un lugar no tiene fotos, o no tiene wifi/parqueo?** Nunca se accede a `fotos[0]` sin revisar que la lista no esté vacía (se muestra un ícono de imagen); wifi y parqueo son datos que siempre vienen (`0`/`1` o cantidad), así que siempre tienen algo que mostrar ("Wifi: No", "No tiene parqueo").

### Las 3 partes más difíciles, paso a paso

**1. Subir fotos (arrendatario, Fase A4)**
1. El usuario elige uno o más archivos con `<input type="file" multiple>`.
2. Por cada archivo se arma una vista previa local con `URL.createObjectURL(archivo)` (no hace falta subir nada todavía para mostrarla).
3. Al guardar el lugar: primero `POST`/`PUT /lugares` (sin fotos) y se espera la respuesta para tener el `id` del lugar.
4. Recién ahí, una petición `POST /lugares/{id}/foto` por cada foto nueva, cada una con su propio `FormData`.
5. Como estos pasos dependen uno del otro en orden estricto, se usa `async/await` + `firstValueFrom()` en vez del `subscribe` habitual de los demás services — la única excepción documentada a esa regla.

**2. Elegir ubicación en un mapa (ambas apps)**
1. Arrendatario (Leaflet): el mapa se crea en `ngAfterViewInit` sobre un `div` con altura fija; como dentro de `ion-content` el tamaño final se conoce recién después del primer render, se llama `mapa.invalidateSize()` con un `setTimeout` corto. Un clic mueve el `circleMarker` y emite la nueva ubicación hacia el formulario.
2. Cliente (`flutter_map`, solo para mostrar, no para elegir): un `Marker` por lugar de los resultados, con `TileLayer` apuntando a OpenStreetMap y un `userAgentPackageName` obligatorio (si falta, OpenStreetMap puede bloquear las peticiones).
3. En ambos casos la `latitud`/`longitud` viajan como **texto** hacia la API (nunca como número), porque la API devuelve error de validación con números.

**3. Calcular el precio de una reserva (cliente, Fase C5)**
1. `calcularNoches(llegada, salida)` = diferencia en días completos entre las dos fechas (sin horas).
2. `calcularSubtotal(noches, precioNoche)` = noches × precio por noche.
3. `calcularServicio(subtotal)` = subtotal × 10% (constante `porcentajeServicio`).
4. `calcularTotal(subtotal, limpieza, servicio)` = suma de los tres.
5. Cada función redondea a 2 decimales antes de devolver, para que la suma final no arrastre errores de coma flotante (ej. que 120 + 5 + 12 dé 136.999999 en vez de 137).
6. Al confirmar, esos mismos números se mandan a la API como texto con 2 decimales (`precioNoches`, `precioLimpieza`, `precioServicio`, `precioTotal`), igual que en el ejemplo confirmado en `docs/API.md`.

### Cierre de la Fase final

- `docs/REQUISITOS.md` recorrido completo: los 36 requisitos (generales, cliente, arrendatario y criterios propios) quedaron en `✔`.
- `flutter analyze` sin advertencias y `npm run build` sin errores en ambas apps; no se encontró código comentado, `print`/`console.log` de depuración, `TODO` sueltos ni archivos de plantilla sin usar.
- Extras opcionales que sí se hicieron (el usuario los pidió explícitamente al cerrar esta fase):
  - **Selector de fechas en español**: se agregó `flutter_localizations` (viene con el SDK de Flutter, no es un paquete externo nuevo) y se configuró `locale: Locale('es')` en `main.dart`. Afecta el `DatePicker` y cualquier otro texto de Material.
  - **Nombre e ícono propios**: `AndroidManifest.xml` del cliente → `android:label="BNB Cliente"`; `index.html` del arrendatario → `<title>BNB Arrendatario</title>`. Los íconos los proveyó el usuario (imágenes cuadradas de 512×512) y se redimensionaron sin agregar ninguna dependencia nueva: `ic_launcher.png` en los 5 tamaños de `mipmap-*` (Android) para el cliente, y `favicon.png` (64×64) para el arrendatario.
- **URL definitiva de la API**: el docente avisó el 2026-11-09 la URL final (`https://api.airbnbmob2.online/api/`, dominio propio, ya no un túnel temporal que cambia de nombre). Se actualizó en los 3 archivos de configuración y en `CLAUDE.md`; al momento de cambiarla respondía error de Cloudflare 1033 (túnel del servidor del profesor desconectado, no un problema de esta app), así que las pruebas de esta fase se hicieron igual contra el mock.

---

## Entradas

<!-- Claude Code agrega aquí una entrada por fase, con el formato de arriba. -->

### Fase 1 — Crear los dos proyectos

- **Qué se hizo**: se generaron los dos proyectos base con las herramientas oficiales de cada tecnología (`flutter create` y `ionic start`), se agregaron las dependencias que va a necesitar todo el proyecto (no solo esta fase) y se dejó cada uno con una pantalla temporal que compila, para que las fases siguientes construyan sobre una base sana.
- **Archivos**:
  - `app-cliente/pubspec.yaml` — manifiesto del paquete Flutter: nombre (`bnb_cliente`), SDK y la lista de dependencias (`provider`, `dio`, `shared_preferences`, `flutter_map`, `latlong2`, `intl`) que `flutter pub add` agregó.
  - `app-cliente/lib/main.dart` — punto de entrada de la app: la función `main()` llama a `runApp()` con un `MaterialApp` mínimo (reemplaza el contador de ejemplo).
  - `app-cliente/lib/config/api_config.dart` — único archivo con la URL base de la API y el cliente `Dio` ya configurado (timeouts, header `Accept`); todos los `service` de fases siguientes lo importan en vez de repetir la URL.
  - `app-cliente/android/app/src/main/AndroidManifest.xml` — se agregó `<uses-permission android:name="android.permission.INTERNET"/>`: sin este permiso, una build de release no puede llamar a la API (en debug funciona igual sin él, por eso no se nota hasta más tarde).
  - `app-arrendatario/angular.json` — configuración del proyecto Angular/Ionic: build, rutas de assets y estilos globales. Se agregó `node_modules/leaflet/dist/leaflet.css` al arreglo `styles` para que el CSS del mapa esté disponible en toda la app sin importarlo pantalla por pantalla.
  - `app-arrendatario/src/main.ts` — arranca la app con `bootstrapApplication()`; se agregó `provideHttpClient()` a la lista de `providers` para poder inyectar `HttpClient` en los servicios (sin esto, `inject(HttpClient)` falla en tiempo de ejecución).
  - `app-arrendatario/src/app/app.routes.ts` — arreglo de rutas de Angular; todavía tiene la página `home` de ejemplo del starter de Ionic, se reemplaza recién en la Fase A1.
  - `app-arrendatario/src/environments/environment.ts` y `environment.prod.ts` — cada uno define `apiUrl` con la misma URL base; `environment.ts` se usa en desarrollo (`ionic serve`) y `environment.prod.ts` lo reemplaza automáticamente en una build de producción (configurado en `angular.json`, sección `fileReplacements`).
- **Flujo de datos**: todavía no hay pantallas reales ni llamadas a la API (eso empieza en las Fases A1/C1). El único "flujo" de esta fase es el arranque: en Flutter, `main()` → `runApp(MaterialApp)` → se dibuja la pantalla temporal; en Angular, `main.ts` → `bootstrapApplication(AppComponent)` → el router (`app.routes.ts`) resuelve `''` → redirige a `home` → se dibuja la página de ejemplo del starter.
- **Conceptos clave**:
  - `flutter pub add` (vs. editar `pubspec.yaml` a mano): agrega la dependencia y la resuelve en un solo paso, usado para instalar las 6 librerías de la app cliente.
  - `ApiConfig` como único punto de verdad de la URL: evita que cada `service` tenga su propia URL hardcodeada y que haya que cambiarla en 10 lugares distintos si el túnel cambia.
  - `environment.ts` / `environment.prod.ts` (Angular) cumplen el mismo rol que `api_config.dart` (Flutter): un solo lugar con la configuración que cambia según dónde corre la app.
  - `provideHttpClient()` / `provideRouter()` en `main.ts`: Angular standalone no tiene `AppModule`; los servicios que antes se registraban en un módulo ahora se registran como `providers` al arrancar la aplicación.
- **Decisiones y por qué**:
  - Se instalaron en esta fase TODAS las dependencias de ambas apps (incluyendo `flutter_map`/`leaflet`, que recién se usan en la Fase A3/C3), para no interrumpir fases posteriores con instalaciones a mitad de camino y para que `flutter analyze`/`npm run build` reflejen desde ya el estado final de dependencias.
  - `urlRaiz` (sin `/api`) se agregó en `api_config.dart` además de `urlBase`, anticipando el hallazgo de la Fase 0: las fotos hay que reconstruirlas contra la raíz del dominio, no contra `/api`.
  - No se tocó `app.routes.ts` del arrendatario todavía: cambiar la página `home` de ejemplo es trabajo de la Fase A1, no de la Fase 1 (que es solo scaffolding).
- **Preguntas probables del docente**:
  - *¿Por qué la app cliente es Flutter y la arrendatario es Ionic/Angular?* Por el requisito del enunciado de usar dos tecnologías distintas vistas en clase; la elección específica fue para reutilizar los patrones de los prácticos 3-4 (Flutter+Provider+Dio) en una y de los prácticos 1-2 (Angular+signals+HttpClient) en la otra.
  - *¿Dónde se cambia la URL de la API si el túnel vence?* En dos lugares, uno por app: `app-cliente/lib/config/api_config.dart` y los dos `environment*.ts` de `app-arrendatario`.
  - *¿Qué pasa si falta el permiso de INTERNET en Android?* Las llamadas HTTP fallan en una build de release (en modo debug Android lo permite igual, por eso el error no aparece hasta compilar en modo release).
- **Ejercicio para hacer a mano**: cambiar el texto de la pantalla temporal de `app-cliente/lib/main.dart` (por ejemplo, agregar el nombre propio debajo de "Pantalla temporal - Fase 1") y volver a correr `flutter analyze` para confirmar que sigue sin errores.

### Fase A1 — Arrendatario: sesion (login, registro, proteccion de rutas)

- **Qué se hizo**: login, registro y guard de sesión para la app arrendatario. El registro exitoso inicia sesión automáticamente (dos llamadas encadenadas: registrar → iniciar sesión) y entra a una pantalla `mis-lugares` temporal con botón de cerrar sesión.
- **Archivos**:
  - `src/app/models/usuario.ts` — interface `Usuario` con los campos que la app realmente usa (`id`, `nombrecompleto`, `email`, `telefono`); la API devuelve más campos (`password` hasheada, etc.) que simplemente se ignoran.
  - `src/app/services/auth.service.ts` — único lugar que habla con `arrendatario/login` y `arrendatario/registro`; `guardarSesion`/`usuarioActual`/`haySesion`/`cerrarSesion` leen y escriben `localStorage` bajo la clave `sesionArrendatario`.
  - `src/app/guards/auth.guard.ts` — `CanActivateFn`: si `authService.haySesion()` es falso, navega a `/login` y bloquea la ruta.
  - `src/app/utils/manejar-error.ts` — `mensajeDeError()`: dado el hallazgo de la Fase 0 (la API no usa 422, todo es 404 salvo login incorrecto que es 401), decide si el cuerpo es `{"message": "..."}` (error de negocio) o `{"campo": [...]}` (error de validación) y devuelve el texto a mostrar.
  - `src/app/pages/login/login.page.ts` (+ `.html`) — formulario con `[(ngModel)]`; al fallar, muestra `mensajeDeError()` en un `ToastController`.
  - `src/app/pages/registro/registro.page.ts` (+ `.html`) — mismo patrón; al registrar OK, llama a `iniciarSesion()` con el mismo email/contraseña antes de navegar.
  - `src/app/pages/mis-lugares/mis-lugares.page.ts` (+ `.html`) — temporal: solo título y botón "Cerrar sesión" que llama `cerrarSesion()` y vuelve a `/login`.
  - `src/app/app.routes.ts` — `login` y `registro` sin guard; `mis-lugares` con `canActivate: [authGuard]`; `''` redirige a `mis-lugares` (el guard la manda a `login` si no hay sesión).
  - Se borró `src/app/home/` (página de ejemplo del starter de Ionic).
- **Flujo de datos**:
  1. Usuario completa el formulario de login → `LoginPage.iniciarSesion()` → `AuthService.iniciarSesion()` → `POST arrendatario/login`.
  2. Si la API responde 200: `AuthService.guardarSesion(usuario)` escribe `localStorage['sesionArrendatario']` → `router.navigate(['mis-lugares'])`.
  3. Al navegar a `mis-lugares`, el `authGuard` corre antes de activar la ruta: lee `localStorage` vía `haySesion()` → como ya hay sesión, deja pasar.
  4. Si la API responde error (401/404): el `error` callback de `.subscribe()` llama a `mensajeDeError()` y lo muestra en un toast; nunca se guarda sesión ni se navega.
  5. Registro: mismo flujo pero con un paso extra — `POST arrendatario/registro` y, solo si eso responde 200, se dispara el login automático (paso 1).
- **Conceptos clave**:
  - `inject()` en vez de inyección por constructor: el linter del proyecto (`@angular-eslint/prefer-inject`) lo exige; se usa en todas las páginas y en `auth.guard.ts` (`AuthService` y `Router` como campos de clase, no parámetros de `constructor`).
  - `CanActivateFn` como función (no clase `Guard`): es el estilo moderno de Angular standalone, igual que las rutas usan `loadComponent` en vez de módulos.
  - `localStorage` como "base de datos" de sesión: no hay token, así que sesión = tener el usuario guardado; cerrar sesión = borrarlo.
  - `@ionic/angular` (no `@ionic/angular/standalone`): la versión instalada es Ionic 9, que exporta los componentes standalone directo desde el paquete principal; ese subpath ya no existe (actualiza lo que decía `app-arrendatario/CLAUDE.md`, escrito pensando en Ionic 7).
- **Decisiones y por qué**:
  - `mensajeDeError()` se extrajo a `utils/` en vez de repetirse en cada página, porque se va a volver a necesitar en todas las fases siguientes que mandan datos a la API (lugares, fotos, reservas).
  - El login y el registro arman el `Toast` directo en la página (no en un servicio) porque `CLAUDE.md` pide que los `services` no tengan lógica de UI.
  - No se usó ningún operador RxJS encadenado (`switchMap`, etc.) para el registro-seguido-de-login: se anidó un `.subscribe()` dentro de otro a propósito, siguiendo la prohibición explícita de `CLAUDE.md` sobre RxJS avanzado — es un poco más verboso pero más fácil de explicar paso a paso.
- **Preguntas probables del docente**:
  - *¿Dónde queda guardada la sesión y qué pasa si borro esa clave de `localStorage` a mano?* En `localStorage['sesionArrendatario']`; si se borra, `haySesion()` devuelve `false` y el guard manda a `/login` en el próximo intento de entrar a `mis-lugares`.
  - *¿Por qué el guard es una función y no una clase?* Es el estilo `CanActivateFn` de Angular standalone (desde Angular 14+), más corto que la interfaz `CanActivate` de una clase con `@Injectable`.
  - *¿Qué pasa si la contraseña es incorrecta?* La API responde HTTP 401 con `{"message": "Contraseña incorrecta"}`; `mensajeDeError()` lo detecta por tener la clave `message` y lo muestra tal cual en el toast.
- **Ejercicio para hacer a mano**: agregar una validación en `LoginPage` que deshabilite el botón "Iniciar sesión" si `email` o `password` están vacíos (sin tocar `AuthService`).

### Fase A2 — Arrendatario: lista de mis lugares

- **Qué se hizo**: pantalla principal real (reemplaza el placeholder de la Fase A1): lista los lugares del arrendatario logueado con foto, nombre, ciudad y precio; botón "+" para ir a crear un lugar nuevo; tocar un ítem lleva a editarlo. Las dos rutas de destino (`lugar/nuevo`, `lugar/:id`) apuntan por ahora a una página temporal que se completa en la Fase A3.
- **Archivos**:
  - `src/app/models/lugar.ts` — interfaces `Lugar` y `Foto` con los campos tal como los manda la API (`cantBanios`, `tieneWifi` como `0`/`1`, etc.).
  - `src/app/utils/formato.ts` — `aNumero` (tolera texto o número), `formatearPrecio` (`$us 30.00`), `urlFoto` (reconstruye la URL de la foto contra la base actual, por el hallazgo de la Fase 0: el campo `url` de la API apunta a un dominio caído).
  - `src/app/services/lugares.service.ts` — `misLugares(idArrendatario)` → `GET lugares/arrendatario/{id}`.
  - `src/app/pages/mis-lugares/mis-lugares.page.ts` (+ `.html`) — reescrita: `signal<Lugar[]>` para los datos, `signal<boolean>` para cargando, `signal<string>` para error; cada estado tiene su propio bloque `@if` en la plantilla.
  - `src/app/pages/lugar-form/lugar-form.page.ts` (+ `.html`, `.scss`) — placeholder nuevo: solo lee el `id` de la ruta para decidir el título ("Nuevo lugar" / "Editar lugar"), sin lógica todavía.
  - `src/app/app.routes.ts` — se agregaron `lugar/nuevo` y `lugar/:id` (en ese orden; si `lugar/:id` fuera primero, Angular tomaría "nuevo" como un id), ambas protegidas con `authGuard`.
- **Flujo de datos**:
  1. El usuario entra a `mis-lugares` (ya sea por login o navegando de vuelta) → Ionic dispara `ionViewWillEnter()` (no `ngOnInit()`, que solo corre la primera vez que se crea el componente).
  2. `ionViewWillEnter()` llama a `cargarLugares()`, que lee el `id` del usuario logueado con `authService.usuarioActual()` y pone `cargando.set(true)`.
  3. `LugaresService.misLugares(id)` → `GET lugares/arrendatario/{id}` → la API devuelve un arreglo de lugares, cada uno con su arreglo `fotos`.
  4. Éxito: `lugares.set(...)` y `cargando.set(false)` → la plantilla recalcula el `@if`/`@else` y muestra la lista. Error: `error.set(mensajeDeError(...))`.
  5. Tocar el botón "+" o un ítem llama a `router.navigate(...)`, que activa el `authGuard` de la ruta destino y carga `LugarFormPage`.
- **Conceptos clave**:
  - `ionViewWillEnter()` vs `ngOnInit()`: Ionic por defecto mantiene las páginas visitadas vivas en el DOM (para animar la transición al volver), así que `ngOnInit()` solo se ejecuta la primera vez que se crea la página; `ionViewWillEnter()` se ejecuta cada vez que la página vuelve a quedar visible, que es lo que hace falta para refrescar la lista después de crear o editar un lugar en la Fase A3.
  - Exponer funciones puras (`formatearPrecio`, `urlFoto`) como propiedades de la clase (`formatearPrecio = formatearPrecio;`) para poder llamarlas directo desde el template sin pasar por un pipe.
  - `(error)` en `<img>`: si la foto no carga, `ocultarImagenRota()` la oculta en vez de mostrar el ícono de imagen rota del navegador.
- **Decisiones y por qué**:
  - El ícono de imagen (`image-outline` de ionicons) se usa como placeholder cuando el lugar no tiene fotos, en vez de un archivo de imagen propio: evita agregar un asset nuevo solo para este caso.
  - `LugarFormPage` se creó ahora (vacía) en vez de esperar a la Fase A3, porque las rutas `lugar/nuevo` y `lugar/:id` ya tenían que existir para que "+" y los ítems de la lista pudieran navegar (parte de "Listo cuando" de esta fase).
- **Preguntas probables del docente**:
  - *¿Por qué la lista no se recarga sola si edito un lugar y vuelvo?* Sí se recarga: `ionViewWillEnter()` se dispara cada vez que la página vuelve a mostrarse, a diferencia de `ngOnInit()`.
  - *¿Qué pasa si un lugar no tiene fotos?* `lugar.fotos.length === 0` muestra un ícono de imagen en vez de intentar cargar una URL inexistente.
  - *¿Por qué `lugar/nuevo` va antes que `lugar/:id` en las rutas?* Angular prueba las rutas en orden; si `lugar/:id` fuera primero, interpretaría "nuevo" como el valor del parámetro `id`.
- **Ejercicio para hacer a mano**: agregar un `ion-refresher` (pull-to-refresh) arriba de la lista que vuelva a llamar a `cargarLugares()`.

### Fase A3 — Arrendatario: formulario para crear un lugar + mapa

- **Qué se hizo**: `LugarFormPage` pasó de placeholder a formulario completo en modo crear, con todos los campos de RA-05 y un mapa Leaflet (`MapaSelectorComponent`) para elegir la ubicación exacta (RA-06). Guardar valida los datos, envía el lugar a la API y vuelve a `mis-lugares` (RA-08, todavía sin fotos — eso es la Fase A4).
- **Archivos**:
  - `src/app/components/mapa-selector/mapa-selector.component.ts` (+ `.html`, `.scss`) — componente nuevo: crea el mapa Leaflet en `ngAfterViewInit`, centra en Santa Cruz si no hay ubicación previa, coloca un `circleMarker` al hacer clic y emite `ubicacionSeleccionada`; lo destruye en `ngOnDestroy`.
  - `src/app/models/lugar.ts` — se agregó `LugarBody` (el cuerpo que se manda a la API, sin `id` ni `fotos`).
  - `src/app/services/lugares.service.ts` — se agregó `guardarLugar(body)` → `POST lugares`.
  - `src/app/pages/lugar-form/lugar-form.page.ts` (+ `.html`) — formulario template-driven con `[(ngModel)]` sobre un objeto `formulario` (no `signal`, porque `ngModel` necesita una propiedad normal); valida y arma el body antes de guardar. El modo editar (`idLugar` presente) todavía muestra un mensaje fijo — se completa en la Fase A5.
- **Flujo de datos**:
  1. El usuario llena el formulario y toca el mapa; cada clic en el mapa dispara el evento `(click)` de Leaflet dentro de `MapaSelectorComponent`, que calcula `evento.latlng` y lo emite con `ubicacionSeleccionada.emit(...)`.
  2. `LugarFormPage` escucha ese evento con `(ubicacionSeleccionada)="alSeleccionarUbicacion($event)"` y guarda `{ latitud, longitud }` en una propiedad local.
  3. Al tocar "Guardar", `validar()` revisa todos los campos y la ubicación; si falta algo, muestra el primer error en un toast y no llama a la API.
  4. Si todo está bien, arma el `body` (convirtiendo con `Number()`, wifi como `1`/`0`, `cantVehiculosParqueo` en `0` si el toggle de parqueo está apagado, lat/long como texto) y llama a `LugaresService.guardarLugar(body)` → `POST lugares`.
  5. Éxito: toast verde "Lugar guardado" y `router.navigate(['mis-lugares'])`, que dispara `ionViewWillEnter()` en `MisLugaresPage` y recarga la lista con el lugar nuevo adentro.
- **Conceptos clave**:
  - `input()` / `output()` en `MapaSelectorComponent`: forma moderna de declarar propiedades de entrada y eventos de salida en un componente standalone, reemplaza a `@Input()`/`@Output()`.
  - `ngAfterViewInit` (no `ngOnInit`): el mapa necesita el `<div>` del template ya renderizado en el DOM (vía `@ViewChild`) antes de poder crearlo con `L.map(...)`.
  - `[(ngModel)]` sobre un objeto plano: cada campo del formulario se liga de a dos vías a una propiedad de `formulario`; Angular actualiza el objeto solo con que el `name` del input sea único.
- **Decisiones y por qué**:
  - Los campos numéricos del formulario se guardan como texto en `formulario` (igual que lo que devuelve `ion-input type="number"`) y se convierten con `Number()` recién al armar el `body`; evita mezclar tipos en el `[(ngModel)]`.
  - `circleMarker` en vez de `marker`: el ícono por defecto de Leaflet se rompe con el empaquetador de Angular (busca imágenes que no quedan en el bundle); un círculo no necesita ningún ícono.
  - El modo editar de `LugarFormPage` se dejó con un mensaje fijo en vez de intentar algo parcial: cargar y actualizar un lugar es trabajo completo de la Fase A5, armarlo a medias ahora sería código que hay que reescribir.
- **Preguntas probables del docente**:
  - *¿Cómo sabe el formulario qué ubicación se eligió?* El mapa no modifica nada del formulario directamente: emite un evento (`output()`) con la ubicación, y es `LugarFormPage` quien lo escucha y lo guarda.
  - *¿Por qué el mapa se crea en `ngAfterViewInit` y no en el constructor?* Porque recién en `ngAfterViewInit` el `<div>` de la plantilla existe en el DOM; crear el mapa antes fallaría porque no hay dónde dibujarlo.
  - *¿Qué pasa si toco "Guardar" sin elegir ubicación?* `validar()` devuelve "Selecciona la ubicacion en el mapa" como primer error encontrado (es la última validación de la lista) y no se manda nada a la API.
- **Ejercicio para hacer a mano**: agregar una validación que impida guardar si `cantPersonas` es mayor a 20 (un límite razonable que el enunciado no pide, pero evita datos absurdos).

**Probado contra la API real** (Fase 0): se creó un lugar de prueba desde el formulario (clic en el mapa, todos los campos llenos); apareció en `mis-lugares` con el precio y ciudad correctos, y `GET lugares/arrendatario/12` confirmó que la `latitud`/`longitud` guardadas coinciden con el punto donde se hizo clic en el mapa.

### Fase A4 — Arrendatario: fotos del lugar

- **Qué se hizo**: el formulario de crear lugar ahora pide fotos (RA-07): selector múltiple con vista previa, opción de quitar una antes de guardar, y exige al menos una. Al guardar, primero se crea el lugar y recién con su `id` se suben las fotos una por una (RA-08 completo para el modo crear).
- **Archivos**:
  - `src/app/services/lugares.service.ts` — se agregó `subirFoto(idLugar, archivo)`: arma un `FormData` con el campo `foto` y hace `POST lugares/{id}/foto`, sin fijar `Content-Type` a mano.
  - `src/app/pages/lugar-form/lugar-form.page.ts` — `fotos: FotoNueva[]` guarda cada archivo elegido junto a su `previewUrl` (de `URL.createObjectURL`); `alSeleccionarFotos()` agrega, `quitarFoto()` saca por índice; `guardar()` pasó de método normal a `async` con `try/catch` y `firstValueFrom()`.
  - `src/app/pages/lugar-form/lugar-form.page.html` (+ `.scss`) — fila de miniaturas con botón "x" para quitar cada una, botón "+" que dispara un `<input type="file" multiple hidden>` via `inputFotos.click()`.
- **Flujo de datos**:
  1. El usuario toca "+" → `inputFotos.click()` abre el selector nativo del sistema operativo.
  2. Al elegir archivos, `(change)` dispara `alSeleccionarFotos(evento)`, que lee `evento.target.files` y por cada uno crea una vista previa con `URL.createObjectURL(archivo)` (una URL temporal que apunta al archivo en memoria, sin subir nada todavía).
  3. Al tocar "Guardar" (con `validar()` ya aprobado, incluida la foto obligatoria): `await firstValueFrom(guardarLugar(body))` crea el lugar y devuelve su `id`.
  4. `for (const foto of this.fotos)`: por cada una, `await firstValueFrom(subirFoto(id, foto.archivo))` — se espera que termine una antes de mandar la siguiente, porque las dos comparten el mismo lugar y conviene que terminen en orden.
  5. Si una falla, se avisa cuál con un toast y se corta ahí (las fotos ya subidas quedan guardadas, el lugar también); si todas terminan bien, toast de éxito y vuelta a `mis-lugares`.
- **Conceptos clave**:
  - `multipart/form-data` vs JSON: un archivo no se puede meter en un string JSON tal cual, por eso las fotos van en un `FormData` (un formato pensado para enviar binarios) en vez del objeto JSON que usa el resto de la app.
  - Por qué no se fija `Content-Type` a mano: el navegador arma el header `multipart/form-data; boundary=...` solo, con un boundary (separador) único generado en el momento; si se lo pisa a mano, falta ese boundary y el servidor no puede separar los campos.
  - `async/await` + `firstValueFrom()` en vez de `subscribe()`: es la única excepción a `subscribe()` en esta app, porque subir una foto necesita el `id` del lugar que recién se conoce después de que la petición anterior termine — son pasos encadenados, no independientes.
- **Decisiones y por qué**:
  - Si una foto falla, se corta el `for...of` en vez de seguir intentando las demás: evita un estado confuso donde no queda claro cuáles subieron y cuáles no. El usuario ve el mensaje con el nombre exacto del archivo que falló y puede reintentar entrando a editar (cuando exista, Fase A5).
  - `URL.createObjectURL` para la vista previa en vez de subir primero y mostrar la URL real: evita subir archivos que el usuario capaz termina quitando antes de guardar.
- **Preguntas probables del docente**:
  - *¿Por qué subir fotos no usa el mismo patrón `subscribe()` que el resto de la app?* Porque subir una foto depende del `id` del lugar, que recién se tiene después de que la petición de crear el lugar responda; encadenar eso con `subscribe()` anidados sería más difícil de leer que `await` en orden.
  - *¿Qué pasa si quito una foto antes de guardar?* Nada se manda a la API: la vista previa solo existe en el navegador (`URL.createObjectURL`) hasta que se confirma el guardado.
  - *¿Por qué `FormData` y no JSON para las fotos?* JSON es texto; un archivo es binario. `FormData` permite mandar ambos (texto y binarios) en una sola petición `multipart/form-data`.
- **Ejercicio para hacer a mano**: cambiar el límite de fotos previas de "sin límite" a un máximo de 6, mostrando un toast si se intenta agregar una séptima.

**Probado contra la API real**: se armó un lugar nuevo con 3 fotos de prueba, se quitó una antes de guardar (quedaron 2) y se guardó. Apareció en `mis-lugares` con la primera foto como miniatura, y `GET lugares/arrendatario/12` confirmó las 2 fotos correctas asociadas al lugar nuevo (`id` 14).

### Fase A5 — Arrendatario: editar un lugar

- **Qué se hizo**: `LugarFormPage` ahora soporta el modo editar completo: si la ruta trae `id`, carga el lugar con `GET lugares/{id}`, precarga todos los campos, las fotos existentes y el mapa con la ubicación guardada, y al guardar usa `PUT lugares/{id}` (confirmado en la Fase 0: `POST` con `id` adentro duplica en vez de actualizar). Aparece el botón "Ver reservas" solo en este modo.
- **Archivos**:
  - `src/app/utils/formato.ts` — se agregó `aBooleano(valor)`: la API manda `tieneWifi` como `0`/`1`, y el `ion-toggle` necesita un `boolean`.
  - `src/app/services/lugares.service.ts` — se agregaron `obtenerLugar(id)` (`GET lugares/{id}`) y `editarLugar(id, body)` (`PUT lugares/{id}`).
  - `src/app/pages/lugar-form/lugar-form.page.ts` — `modoEditar = idLugar !== null` decide todo el comportamiento de la página (patrón `notaSeleccionada` del práctico 2). Nuevo `signal` `cargando` (true solo si hay que esperar la carga); `fotosExistentes` (de la API, sin botón de quitar) separado de `fotosNuevas` (las que se suben); `guardar()` ahora llama a `editarLugar` o `guardarLugar` según `modoEditar`.
  - `src/app/pages/lugar-form/lugar-form.page.html` — todo el formulario queda detrás de `@if (cargando()) { spinner } @else { ...formulario... }`: el mapa (`<app-mapa-selector [latitud] [longitud]>`) recién se crea cuando el lugar ya cargó, así nace con el marcador en el punto guardado en vez de tener que moverlo después.
  - `src/app/pages/reservas-lugar/` (nuevo, temporal) y `src/app/app.routes.ts` — ruta `lugar/:id/reservas`, destino del botón "Ver reservas"; se completa en la Fase A6.
- **Flujo de datos**:
  1. Al entrar a `lugar/:id`, el constructor de `LugarFormPage` ve que `idLugar` no es `null` y llama a `cargarLugar()` con `cargando.set(true)` ya puesto por defecto.
  2. `LugaresService.obtenerLugar(id)` → `GET lugares/{id}` → la API devuelve el lugar completo (incluye `arrendatario` y `fotos`, aunque esta pantalla solo usa estas últimas).
  3. La respuesta llena `formulario`, `ubicacion` y `fotosExistentes`; recién ahí `cargando.set(false)`, lo que hace que Angular recién ahora renderice (y cree) `<app-mapa-selector>` con la ubicación ya conocida.
  4. El usuario edita lo que quiera y toca "Guardar": como `modoEditar` es `true`, se llama `editarLugar(id, body)` → `PUT lugares/{id}` en vez de `guardarLugar(body)` → `POST lugares`.
  5. Las fotos nuevas (si agregó alguna) se suben igual que en la Fase A4, una por una; las que ya estaban no se vuelven a mandar (la API no tiene forma de borrarlas, así que no hace falta re-subirlas).
- **Conceptos clave**:
  - Mismo patrón `notaSeleccionada` del práctico 2, aplicado con una variable (`modoEditar`) calculada una sola vez en vez de revisarla en cada método: más fácil de leer que repetir `this.idLugar !== null` por todos lados.
  - Por qué el mapa espera a `cargando()`: el componente del mapa solo lee sus `input()` una vez, en `ngAfterViewInit()` (ver Fase A3); si se creara antes de tener la ubicación real, nacería centrado en Santa Cruz por defecto y no se movería solo cuando llegaran los datos.
  - Separar `fotosExistentes` (objetos `Foto` de la API, con `url`) de `fotosNuevas` (objetos `File` locales, con `previewUrl`): son dos tipos de datos distintos (uno ya en el servidor, el otro todavía solo en el navegador) y la plantilla los trata distinto (unas tienen botón de quitar, las otras no).
- **Decisiones y por qué**:
  - No se intenta "borrar" fotos existentes porque la API no tiene esa ruta (documentado en `CLAUDE.md`); el único control sobre fotos existentes es no tocarlas.
  - La validación de "al menos una foto" de la Fase A4 se desactiva en modo editar (`!this.modoEditar && fotosNuevas.length === 0`): un lugar que ya existe siempre tiene alguna foto, así que no hace falta exigir una nueva.
- **Preguntas probables del docente**:
  - *¿Cómo decide la pantalla si crea o edita?* Por `modoEditar`, que se calcula una sola vez al entrar a la página mirando si la ruta trajo un `id` (`ActivatedRoute.snapshot.paramMap.get('id')`).
  - *¿Qué pasa si guardo sin cambiar nada?* Igual se manda el `PUT` completo con todos los campos del formulario (la API espera el objeto entero, no un parche); el lugar queda con los mismos datos y mismo `id`.
  - *¿Por qué no se repite el error de "editar duplica" de la Fase 0?* Porque esta pantalla nunca manda el `id` dentro del body: va en la URL (`PUT lugares/{id}`), que es la ruta que sí actualiza en vez de crear otro.
- **Ejercicio para hacer a mano**: agregar un botón "Cancelar" junto a "Guardar" que vuelva a `mis-lugares` sin mandar nada a la API.

**Probado**: con la API real caída (el túnel volvió a cambiar de URL a mitad de esta fase), se usó el mock de Mockoon como respaldo. Se abrió el lugar de ejemplo del mock (`id` 1, "Casa Azul"): todos los campos, el wifi/parqueo y el mapa (con el marcador ya puesto en la ubicación guardada) precargaron correctamente, y apareció el botón "Ver reservas". Se editó el nombre y se movió el marcador, y el registro del servidor del mock confirmó un `PUT /api/lugares/1` (no `POST`) y que la lista siguió teniendo un solo lugar (sin duplicar). El mock no tiene estado real, así que no puede confirmar que el cambio quede guardado al volver a abrir — esa verificación final queda pendiente para cuando vuelva la URL real.

### Fase A6 — Arrendatario: reservas de un lugar

- **Qué se hizo**: última pantalla de la app arrendatario. `ReservasLugarPage` deja de ser un placeholder y muestra, para el lugar cuyo `id` viene en la ruta, cada reserva con la primera foto del lugar, el nombre del cliente, la cantidad de noches (calculada), las fechas en `dd/MM/yyyy` y el precio total.
- **Archivos**:
  - `src/app/models/reserva.ts` — `Reserva`, `Cliente` y `LugarConReservas` (extiende `Lugar` con un arreglo `reservas`): la ruta `reservas/lugar/{id}` devuelve el lugar completo con las reservas adentro, no un arreglo plano (confirmado en la Fase 0).
  - `src/app/services/reservas.service.ts` — `reservasDeLugar(idLugar)` → `GET reservas/lugar/{id}`.
  - `src/app/utils/formato.ts` — se agregaron `formatearFecha` y `calcularNoches`, ambos partiendo el texto de la fecha en vez de usar el constructor `Date` directo.
  - `src/app/pages/reservas-lugar/reservas-lugar.page.ts` (+ `.html`) — reescrita con los mismos signals `cargando`/`error` y el mismo patrón de ícono-placeholder para la foto que `MisLugaresPage` (Fase A2).
- **Flujo de datos**:
  1. Al entrar a `lugar/:id/reservas`, el constructor llama a `cargarReservas()`, que pide `GET reservas/lugar/{id}`.
  2. La API devuelve un solo objeto: el lugar (con sus `fotos`) y, adentro, un arreglo `reservas` donde cada una ya trae el `cliente` completo — no hace falta ninguna petición extra para saber el nombre del cliente ni la foto del lugar.
  3. Por cada reserva, `calcularNoches(fechaInicio, fechaFin)` resta las dos fechas (parseadas a mano) y `formatearFecha` las muestra como texto legible.
- **Conceptos clave**:
  - `fechaInicio.substring(0, 10).split('-')`: la fecha puede venir con hora (`"2026-12-01T00:00:00"`); cortar a 10 caracteres se queda solo con `YYYY-MM-DD` antes de partirla.
  - `Date.UTC(anio, mes - 1, dia)` en vez de `new Date('2026-12-01')`: construye la fecha en UTC a propósito para los dos lados de la resta, así da igual en qué zona horaria corra el navegador — la resta en milisegundos siempre da el mismo número de noches.
  - `reserva.cliente.nombrecompleto` viene anidado directo en la respuesta: mismo patrón de datos "todo junto" que ya se vio en `GET lugares/{id}` (Fase A2) con `arrendatario`.
- **Decisiones y por qué**:
  - No se pidió `GET lugares/{id}` aparte para la foto: la respuesta de `reservas/lugar/{id}` ya la trae, pedirla de nuevo sería una petición de más sin necesidad.
  - Se reutilizó literalmente el mismo patrón de ícono-placeholder de `MisLugaresPage` (Fase A2) en vez de inventar uno nuevo: mismo problema (foto puede no existir o no cargar), misma solución.
- **Preguntas probables del docente**:
  - *¿Por qué no hay un `LugaresService.obtenerLugar()` extra en esta pantalla?* Porque `GET reservas/lugar/{id}` ya devuelve todo lo que hace falta (lugar, fotos y reservas con su cliente) en una sola respuesta.
  - *¿Cómo se calculan las noches sin que la zona horaria del navegador afecte el resultado?* Usando `Date.UTC(...)` para las dos fechas: como las dos se construyen de la misma forma, la diferencia en milisegundos no depende de en qué huso horario esté la computadora.
  - *¿Qué pasa si la fecha de la API viene con hora en vez de solo la fecha?* `substring(0, 10)` se queda solo con los primeros 10 caracteres (`YYYY-MM-DD`) antes de partir el texto, así que no importa si trae hora o no.
- **Ejercicio para hacer a mano**: ordenar la lista de reservas por `fechaInicio` (de la más próxima a la más lejana) antes de mostrarla.

**Probado**: con la API real todavía caída, se usó el mock de nuevo. Se abrió `lugar/1/reservas`: apareció "Cliente de Ejemplo", 2 noches (01/12/2026 al 03/12/2026, calculado correcto) y "$us 400.00" — todos los valores coinciden exactamente con los datos de prueba del mock. También se probó el camino de error con `lugar/99999/reservas`, que mostró "Reserva no encontrada" (el mensaje real que devuelve la API en ese caso). Con esto queda cubierta la Fase A6 **y toda la app arrendatario**; falta repetir la prueba contra la API real en cuanto vuelva, para confirmar los datos reales de la Fase 0 (reserva `id` 7, lugar 11, cliente 14, 4 noches, $us 137.00).

### Fase C1 — Cliente: sesión (login y registro)

- **Qué se hizo**: primera fase de la app cliente (Flutter). Login y registro con la misma lógica de sesión que la app arrendatario, pero con las herramientas de Flutter: `shared_preferences` en vez de `localStorage`, `ChangeNotifier` en vez de `signal()`.
- **Archivos**:
  - `lib/model/usuario_model.dart` — clase con `fromJson`/`toJson` escritos a mano (el `toJson` no se manda a la API; se usa para guardar el usuario en `shared_preferences`).
  - `lib/service/auth_service.dart` — `iniciarSesion`, `registrar` con `Dio`; atrapa `DioException` y arma el mensaje de error mirando la FORMA del cuerpo (mismo criterio que `manejar-error.ts` de la app arrendatario, hallazgo de la Fase 0: `{"message"}` = negocio, `{"campo": [...]}` = validación).
  - `lib/repository/auth_provider.dart` — `ChangeNotifier` con `_usuario`, `_cargando`, `_error` privados y getters públicos; `cargarSesion()` lee `shared_preferences` (clave `sesionCliente`), `iniciarSesion`/`registrar` llaman al service y guardan la sesión si sale bien, `cerrarSesion()` la borra.
  - `lib/screen/login_screen.dart`, `registro_screen.dart` — `StatefulWidget` con `Form` + `GlobalKey<FormState>` + `TextFormField` con `validator`; botón deshabilitado mientras `context.watch<AuthProvider>().cargando` es verdadero.
  - `lib/screen/busqueda_screen.dart` — temporal, con botón de cerrar sesión en el `AppBar`.
  - `lib/main.dart` — ahora es `async`: `WidgetsFlutterBinding.ensureInitialized()` + `AuthProvider().cargarSesion()` antes de `runApp`; `MultiProvider` con el `AuthProvider` ya cargado; la pantalla inicial depende de `authProvider.haySesion`.
- **Flujo de datos**:
  1. Antes de que exista cualquier pantalla, `main()` crea el `AuthProvider` y espera `cargarSesion()` (lee `shared_preferences` de forma asíncrona, por eso `main` es `async` y usa `await`).
  2. `runApp` recién se llama después, con la pantalla inicial ya decidida (`BusquedaScreen` o `LoginScreen`) — así la app nunca "parpadea" mostrando el login si ya había una sesión guardada.
  3. En `LoginScreen`, tocar "Iniciar sesión" llama a `context.read<AuthProvider>().iniciarSesion(...)`, que pone `_cargando = true` y notifica (el botón se deshabilita), llama a `AuthService`, y según el resultado guarda la sesión o guarda el mensaje de error.
  4. La pantalla espera el `Future<bool>` que devuelve el provider y navega o muestra un `SnackBar`, sin que el provider toque nada de UI directamente.
- **Conceptos clave**:
  - `ChangeNotifier` vs `signal()`: en Flutter el estado vive en una clase que extiende `ChangeNotifier` y llama a `notifyListeners()` manualmente después de cada cambio; en Angular cada `signal` se actualiza solo y Angular detecta el cambio sin que haga falta notificar nada a mano.
  - `shared_preferences` guarda pares clave-valor de texto (persisten en el almacenamiento del dispositivo, sobreviven a cerrar la app); el `UsuarioModel` se convierte a JSON con `jsonEncode`/`toJson()` para poder guardarlo como un solo string.
  - `cargarSesion()` antes de `runApp`: si se llamara después (por ejemplo en `initState` de una pantalla), la primera pantalla en dibujarse siempre sería la de login, aunque hubiera sesión guardada, porque leer `shared_preferences` es asíncrono y `initState` no puede esperarlo antes del primer `build`.
- **Decisiones y por qué**:
  - Se usó `Navigator.pushAndRemoveUntil` (no `pushReplacement`) al terminar el registro: `RegistroScreen` se abre encima de `LoginScreen` con `push`, así que `pushReplacement` solo saca a `RegistroScreen` de la pila y deja a `LoginScreen` debajo — aparecía un botón "atrás" que volvía al login estando ya adentro. Se detectó probando la app en el emulador. En `LoginScreen` no hace falta este cuidado porque es la pantalla raíz (no hay nada debajo).
  - El mensaje de error se arma en el `service` (no en el `provider` ni en la pantalla): es el único lugar que ve la respuesta cruda de `Dio`, y así el resto de la app solo trabaja con `Exception`s con mensaje en español.
- **Preguntas probables del docente**:
  - *¿Por qué `main()` es `async`?* Porque `cargarSesion()` necesita leer `shared_preferences`, que es una operación asíncrona (usa un canal de plataforma); `main` tiene que poder hacer `await` antes de llamar a `runApp`.
  - *¿Qué pasa si cierro la app a la fuerza en vez de usar "Cerrar sesión"?* No cambia nada: `shared_preferences` ya tiene el usuario guardado de la última vez que inició sesión, así que la próxima vez que abra la app entra directo (probado relanzando la app completa en el emulador, no solo recargando).
  - *¿Dónde se decide si el login fue exitoso?* `AuthProvider.iniciarSesion()` devuelve `true`/`false`; la pantalla nunca mira la respuesta de la API directamente.
- **Ejercicio para hacer a mano**: agregar un campo de "confirmar contraseña" en `RegistroScreen` que valide que coincide con la contraseña antes de permitir enviar el formulario.

**Probado**: con la API real caída, se usó el mock (apuntando el emulador a `http://10.0.2.2:3001/api`, la dirección con la que el emulador Android ve al `localhost` de la PC — no `localhost` directo). Se registró un cliente nuevo → entró directo a "Buscar lugares" (una vez corregido el bug de navegación). Se cerró sesión → volvió a "Iniciar sesión". Se mató el proceso de la app por completo y se volvió a abrir (relanzamiento real, no hot-reload) → entró directo a "Buscar lugares" sin pedir login, confirmando que la sesión persiste de verdad en el almacenamiento del dispositivo.

### Fase C2 — Cliente: búsqueda simple y resultados en lista

- **Qué se hizo**: la pantalla principal del cliente pasó de placeholder a buscador real (ciudad, fechas, huéspedes), con los tres botones del wireframe. Buscar lleva a `ResultadosScreen`, que muestra los lugares encontrados en una lista con `LugarCard`.
- **Archivos**:
  - `lib/model/lugar_model.dart` (+ `FotoModel` anidado) — incluye `nombreAnfitrion` (sacado del objeto `arrendatario` anidado que manda la API) y la lista de fotos; usa `utils/conversiones.dart` para tolerar texto o número en los campos numéricos.
  - `lib/utils/conversiones.dart` — `aEntero`, `aDecimal`, `aBool` (tolerantes a texto/número/null), `urlFoto` (mismo hallazgo de la Fase 0 que en la app arrendatario: hay que reconstruirla), `formatearPrecio`, `formatearFecha` (con `DateFormat` de `intl`).
  - `lib/utils/manejar_error.dart` — se extrajo de `auth_service.dart` para no repetir la misma lógica en cada `service` nuevo.
  - `lib/service/lugar_service.dart` — `buscar(ciudad)` → `POST lugares/search` con `{"search": ciudad}` (solo la ciudad, nada de fechas ni huéspedes: la API no los recibe).
  - `lib/repository/busqueda_provider.dart` — guarda los criterios (`ciudad`, `fechaLlegada`, `fechaSalida`, `huespedes`) ademas de `resultados`/`cargando`/`error`; `buscar()` llama al service y despues filtra localmente por `cantPersonas >= huespedes`.
  - `lib/widget/vista_estado.dart`, `lib/widget/lugar_card.dart` — widgets reutilizables: el primero decide cargando/error/vacío/datos, el segundo es el ítem de la lista.
  - `lib/screen/resultados_screen.dart`, `busqueda_avanzada_screen.dart` (temporal), `mis_reservas_screen.dart` (temporal).
  - `lib/screen/busqueda_screen.dart` — formulario con `showDatePicker` para las dos fechas y un contador +/- para huéspedes; valida ciudad, fechas elegidas y que la salida sea posterior a la llegada antes de llamar a `buscar()`.
  - `lib/main.dart` — se agregó `BusquedaProvider` al `MultiProvider`.
- **Flujo de datos**:
  1. El usuario llena ciudad, toca las fechas (cada una abre `showDatePicker`, que devuelve un `DateTime?` o `null` si cancela) y ajusta huéspedes con los botones +/-.
  2. Al tocar "Buscar", `_buscar()` valida localmente (sin llamar a la API todavía); si todo está bien, copia esos criterios al `BusquedaProvider` (porque hacen falta de nuevo en la Fase C5, al confirmar la reserva) y llama a `provider.buscar()`.
  3. `BusquedaProvider.buscar()` llama a `LugarService.buscar(ciudad)` → `POST lugares/search`; la API devuelve un arreglo de lugares.
  4. Antes de guardar `_resultados`, se filtra localmente por `cantPersonas >= huespedes`, porque la búsqueda simple de la API no recibe la cantidad de huéspedes.
  5. `ResultadosScreen` lee `context.watch<BusquedaProvider>()` y muestra la lista con `VistaEstado` + `LugarCard` por cada lugar.
- **Conceptos clave**:
  - `showDatePicker`: diálogo nativo de Flutter/Material que devuelve un `Future<DateTime?>`; hay que esperarlo con `await` y revisar `if (fecha == null) return;` porque el usuario puede cancelar.
  - Las fechas se guardan en el `BusquedaProvider` (no solo en la pantalla) porque la Fase C5 (confirmar reserva) las necesita para calcular las noches; si vivieran solo en el `State` de `BusquedaScreen`, se perderían al navegar.
  - `VistaEstado` como widget reutilizable: en vez de repetir el mismo `if (cargando) ... else if (error) ...` en cada pantalla, se escribió una sola vez y recibe los datos por parámetro.
- **Decisiones y por qué**:
  - El filtro por huéspedes vive en `BusquedaProvider.buscar()`, después de recibir la respuesta de la API, con un comentario explicando por qué (la búsqueda simple de la API no tiene ese campo) — mismo patrón que ya anticipaba `CLAUDE.md`.
  - `manejar_error.dart` se extrajo recién ahora (no en la Fase C1) porque recién con el segundo `service` (`LugarService`) la duplicación se volvía evidente; antes, con un solo service, la función privada en `AuthService` todavía no pedía la ventaja de ser compartida.
- **Preguntas probables del docente**:
  - *¿Por qué la cantidad de huéspedes no se manda a la API?* El enunciado dice que la búsqueda simple es solo por ciudad; la API tampoco tiene un campo para eso en esa ruta (confirmado en la Fase 0), así que se filtra después, en la app.
  - *¿Dónde quedan guardadas las fechas elegidas y por qué?* En `BusquedaProvider` (no en `BusquedaScreen`), porque la Fase C5 las va a necesitar para calcular noches y el total de la reserva, y un provider sobrevive a cambiar de pantalla.
  - *¿Qué pasa si elijo una fecha de salida igual a la de llegada?* `_fechaSalida!.isAfter(_fechaLlegada!)` es `false` en ese caso (no es estrictamente posterior), así que se bloquea con el mismo mensaje que una fecha anterior.
- **Ejercicio para hacer a mano**: agregar un texto debajo del buscador que muestre "X noches" en cuanto las dos fechas estén elegidas (sin tocar `BusquedaProvider`, calculándolo en la propia pantalla).

**Probado**: con la API real caída, se usó el mock de nuevo. En el emulador: tocar "Buscar" sin ciudad mostró "Ingresa la ciudad"; con fecha de salida anterior a la de llegada mostró "La fecha de salida debe ser posterior a la de llegada"; con ciudad y fechas válidas, apareció "Casa Azul" (el lugar de ejemplo del mock) en los resultados, con su descripción, "4 personas" y "$us 150.00" — todo coincide con los datos de prueba.

### Fase C3 — Cliente: vista de mapa

- **Qué se hizo**: `ResultadosScreen` ahora puede mostrar los mismos resultados como mapa (RC-08/RC-09), con un marcador por lugar con su precio; tocar un marcador o un ítem de la lista lleva al detalle (RC-10, todavía con placeholder hasta la Fase C4).
- **Archivos**:
  - `lib/widget/mapa_lugares.dart` — `FlutterMap` con un `TileLayer` de OpenStreetMap y un `MarkerLayer` con un `Marker` por lugar (precio arriba, ícono de pin abajo, envueltos en un `GestureDetector` para detectar el toque); se centra en el primer resultado, o en Santa Cruz si la lista viene vacía.
  - `lib/screen/detalle_lugar_screen.dart` (temporal) — recibe el `LugarModel` completo por el constructor, sin pedir nada a la API todavía.
  - `lib/screen/resultados_screen.dart` — pasó de `StatelessWidget` a `StatefulWidget`: agregó `bool _verMapa` (estado local, no vive en `BusquedaProvider` porque es pura cuestión de cómo se *muestra* esta pantalla, no un dato de la búsqueda) y un `bottomNavigationBar` con el botón que lo invierte.
- **Flujo de datos**:
  1. `ResultadosScreen` ya tenía los resultados cargados desde la Fase C2 (vía `BusquedaProvider`); esta fase no agrega ninguna petición nueva a la API, solo una forma distinta de mostrar los mismos datos.
  2. Según `_verMapa`, el `body` de `VistaEstado` muestra `MapaLugares(...)` o el `ListView` de siempre; el botón de abajo llama a `setState(() => _verMapa = !_verMapa)`.
  3. Tocar un marcador (`onTap` del `GestureDetector` dentro de cada `Marker`) o un `LugarCard` de la lista llama a la misma función `_irADetalle(lugar)`, que navega pasando el `LugarModel` completo por el constructor de `DetalleLugarScreen` (sin pedir nada de nuevo a la API: ya se tenía todo desde la búsqueda).
- **Conceptos clave**:
  - Un *tile* es una imagen cuadrada (normalmente 256×256) que representa una porción del mapa a un nivel de zoom dado; `TileLayer` arma la URL de cada tile visible (`{z}/{x}/{y}.png`) y las va pidiendo a medida que el usuario se mueve o hace zoom.
  - Un `Marker` de `flutter_map` no es una imagen fija: es cualquier widget (`child`) posicionado en una coordenada (`point`) del mapa; por eso se pudo poner un precio y un ícono juntos, en vez de un simple pin.
  - Por qué no hizo falta `Expanded` acá: la guía de `CLAUDE.md` advierte que `FlutterMap` necesita una altura definida dentro de una `Column`; en esta pantalla el mapa es directamente el `body` del `Scaffold` (dentro de `VistaEstado`), que ya le da toda la altura disponible sin pasar por una `Column`.
- **Decisiones y por qué**:
  - `_verMapa` vive en el `State` de `ResultadosScreen`, no en `BusquedaProvider`: es el mismo criterio que ya definía `CLAUDE.md` ("estado local de pantalla... en StatefulWidget, no en providers") — es una preferencia de cómo ver el resultado, no un dato de la búsqueda en sí.
  - El precio se muestra siempre sobre el marcador (no solo al tocarlo): el enunciado pide ver "los mismos lugares como marcadores en un mapa", y mostrar el precio de entrada evita que el usuario tenga que tocar cada uno para comparar.
- **Preguntas probables del docente**:
  - *¿Por qué `_verMapa` no está en el provider?* Porque es un detalle de esta pantalla nada más (cómo se ve), no un criterio de búsqueda; si estuviera en el provider, cualquier otra pantalla que mirara `BusquedaProvider` se vería afectada sin necesidad.
  - *¿De dónde sale la ubicación que usa el mapa para centrarse?* Del primer lugar de la lista de resultados (`lugares.first`); si no hay resultados, usa la constante de Santa Cruz.
  - *¿Qué pasa si toco un marcador?* Llama a la misma función que tocar un ítem de la lista (`_irADetalle`), que navega a `DetalleLugarScreen` pasándole el lugar ya cargado.
- **Ejercicio para hacer a mano**: hacer que el marcador del lugar seleccionado se vea de un color distinto al resto (sin agregar ningún estado nuevo al provider).

**Probado**: con la API real caída, se usó el mock. Se buscó en Santa Cruz y se tocó "Vista de mapa": apareció el mapa de OpenStreetMap centrado en el punto correcto, con el marcador de "Casa Azul" mostrando "$us 150.00" justo en el centro de la ciudad (coincide con la latitud/longitud de prueba del mock). Tocar el marcador llevó al detalle ("Casa Azul"); al volver, el botón seguía en "Vista de mapa"/"Vista de lista" y se pudo alternar sin problemas entre las dos vistas.

### Fase C4 — Cliente: detalle del lugar con galería

- **Qué se hizo**: `DetalleLugarScreen` dejó de recibir el lugar completo por el constructor; ahora recibe solo el `id` y pide `GET lugares/{id}` de nuevo, mostrando todos los datos de RC-12 y una galería de fotos (RC-11) con miniaturas tocables.
- **Archivos**:
  - `lib/service/lugar_service.dart` — se agregó `obtenerLugar(id)` → `GET lugares/{id}`.
  - `lib/widget/galeria_fotos.dart` — `StatefulWidget` con `_indiceSeleccionado`: una foto grande arriba (la del índice actual) y una fila horizontal de miniaturas abajo; tocar una miniatura cambia el índice.
  - `lib/screen/confirmar_reserva_screen.dart` (temporal) — recibe el `LugarModel` completo (ya se tiene desde el detalle, no hace falta pedirlo de nuevo).
  - `lib/screen/detalle_lugar_screen.dart` — reescrita: ahora es `StatefulWidget` con `_cargando`/`_error`/`_lugar` propios (sin provider: esta pantalla pide un solo lugar una sola vez, no necesita el patrón `ChangeNotifier` de las búsquedas); llama a `LugarService.obtenerLugar()` en `initState()`.
  - `lib/screen/resultados_screen.dart` — `_irADetalle` ahora pasa `lugar.id` en vez del `LugarModel` completo.
- **Flujo de datos**:
  1. Al entrar a `DetalleLugarScreen(idLugar: ...)`, `initState()` llama a `_cargarLugar()`, que pide `GET lugares/{id}` — los datos de la búsqueda (Fase C2/C3) no se reutilizan a propósito, para que el detalle siempre muestre la versión más actual.
  2. La respuesta ya trae `arrendatario` y `fotos` anidados (igual que en la app arrendatario), así que no hace falta ninguna petición extra para el nombre del anfitrión ni las fotos.
  3. `GaleriaFotos` recibe la lista de fotos ya convertida; su propio estado (`_indiceSeleccionado`) decide cuál se ve grande, sin que `DetalleLugarScreen` necesite saberlo.
  4. "Reservar" navega a `ConfirmarReservaScreen` pasando el `LugarModel` ya cargado por el constructor (sin pedir nada de nuevo).
- **Conceptos clave**:
  - El `StatefulWidget` de la galería: `_indiceSeleccionado` es un número que vive únicamente dentro de `GaleriaFotos`; cuando cambia (`setState`), solo se reconstruye la foto grande y el resaltado de las miniaturas, no el resto de la pantalla de detalle.
  - No todas las pantallas necesitan un provider: `BusquedaProvider` tiene sentido porque sus datos (criterios, resultados) se comparten entre varias pantallas (`BusquedaScreen`, `ResultadosScreen`); el detalle de un lugar se pide una sola vez y se usa en una sola pantalla, así que alcanza con el estado local de un `StatefulWidget`.
- **Decisiones y por qué**:
  - Pedir `GET lugares/{id}` de nuevo (en vez de reusar el `LugarModel` que ya se tenía desde la búsqueda) sigue el flujo que ya documentaba `app-cliente/CLAUDE.md`; además, los datos de búsqueda no traen `nombreAnfitrion` completo en todos los casos y así se evita cualquier duda sobre si el detalle está desactualizado.
  - `ConfirmarReservaScreen` sí recibe el `LugarModel` completo (no un id): a diferencia del detalle, la Fase C5 va a necesitar varios campos del lugar (precio, costo de limpieza) para calcular la reserva, y ya se tienen disponibles sin otra petición.
- **Preguntas probables del docente**:
  - *¿Por qué el detalle pide los datos de nuevo si ya los tenía la lista de resultados?* Para mostrar siempre la versión más reciente del lugar (podría haber cambiado desde que se hizo la búsqueda) y porque así lo define el flujo documentado para esta app.
  - *¿Dónde vive el índice de la foto seleccionada?* Dentro de `GaleriaFotos`, no en `DetalleLugarScreen` ni en ningún provider: es un detalle de cómo se ve ese widget en particular.
  - *¿Qué pasa si el lugar no tiene fotos?* `GaleriaFotos` muestra un ícono de imagen en un contenedor gris en vez de intentar cargar algo; nunca se accede a `fotos[0]` sin revisar antes que la lista no esté vacía.
- **Ejercicio para hacer a mano**: agregar que al tocar la foto grande (no una miniatura) se abra en pantalla completa con `Navigator.push` (sin tocar el estado de `GaleriaFotos`, solo agregando un `GestureDetector` a la foto grande).

**Probado**: con la API real caída, se usó el mock, agregándole temporalmente 2 fotos más al lugar de ejemplo (para poder probar la galería con varias miniaturas). Se abrió el detalle de "Casa Azul": aparecieron las 3 miniaturas con la primera seleccionada, y todos los datos (4 personas, 2 camas, 1 baño, 2 habitaciones, "Anfitrion: Arrendatario de Ejemplo", "Wifi: Si", "Parqueo para 1 vehiculos", "$us 150.00 por noche") coincidiendo exactamente con la respuesta de `GET lugares/1`. Al tocar la segunda miniatura, el resaltado se movió y el registro del servidor del mock confirmó un nuevo pedido a `GET /fotos/casa-azul-2.jpg` — la foto correcta para ese índice.

### Fase C5 — Cliente: confirmar reserva

- **Qué se hizo**: pantalla que muestra el desglose del precio de una reserva (noches × precio, limpieza, servicio, total) y la envía a la API con `POST reservas`.
- **Archivos**:
  - `lib/utils/calculo_reserva.dart` — funciones puras: `calcularNoches`, `calcularSubtotal`, `calcularServicio`, `calcularTotal`, más la constante `porcentajeServicio = 0.10`. Cada una redondea a 2 decimales antes de devolver el valor, para que la suma final no arrastre errores de coma flotante (ej. que 120 + 5 + 12 dé 136.99999999 en vez de 137).
  - `lib/service/reserva_service.dart` — `crearReserva(...)` → `POST /reservas`, mismo patrón try/catch + `mensajeDeError` que los demás services. Los precios se mandan como texto (`toStringAsFixed(2)`), igual que el ejemplo confirmado en `docs/API.md`.
  - `lib/repository/reserva_provider.dart` — `ChangeNotifier` con `_cargando`/`_error` y `confirmarReserva(...)`, que llama al service y devuelve `true`/`false` según el resultado.
  - `lib/screen/confirmar_reserva_screen.dart` — reescrita: ya no es un placeholder. Lee `fechaLlegada`/`fechaSalida` de `BusquedaProvider` (no por constructor) y `cliente_id` de `AuthProvider.usuario.id`; calcula y muestra el desglose; botón "Confirmar reserva" deshabilitado mientras `reservaProvider.cargando` es verdadero.
  - `lib/main.dart` — se agregó `ChangeNotifierProvider(create: (_) => ReservaProvider())` al `MultiProvider`.
- **Flujo de datos**:
  1. Al entrar a esta pantalla ya se tiene el `LugarModel` completo (pasado por el constructor desde el detalle) y las fechas elegidas quedaron guardadas en `BusquedaProvider` desde la búsqueda — no hace falta pedir nada a la API todavía.
  2. Se calculan `noches`, `subtotal`, `servicio` y `total` con `calculo_reserva.dart`, y se muestran formateados con `formatearPrecio`.
  3. Al tocar "Confirmar reserva": `ReservaProvider.confirmarReserva(...)` arma el body (`lugar_id`, `cliente_id`, fechas en `yyyy-MM-dd` con `DateFormat`, precios como texto) y llama a `ReservaService.crearReserva`.
  4. Éxito → `SnackBar` + `Navigator.popUntil((ruta) => ruta.isFirst)`, que vuelve directo a `BusquedaScreen` saltándose el detalle y los resultados (así lo pide el wireframe).
- **Conceptos clave**:
  - **Funciones puras para el cálculo**: `calculo_reserva.dart` no depende de Flutter ni del estado de ninguna pantalla; recibe números y fechas, devuelve números. Esto permite explicar y (en teoría) probar cada fórmula por separado, sin levantar la UI.
  - **Dato que se "pasa" entre pantallas sin repetir la petición**: el `LugarModel` viaja por el constructor desde el detalle; las fechas viajan por el `BusquedaProvider` porque se eligieron varias pantallas atrás (en la búsqueda) y se siguen necesitando acá.
- **Decisiones y por qué**:
  - El 10% de servicio y el redondeo a 2 decimales son una decisión propia del proyecto (no los define la API ni el enunciado), documentada en la tabla de decisiones de `CLAUDE.md`.
  - `ReservaService.crearReserva` no devuelve ni parsea la reserva creada: la pantalla de confirmación no necesita mostrar el `id` ni ningún dato devuelto por la API, así que alcanza con sí/no (éxito o excepción). El modelo `ReservaModel` recién hace falta en la Fase C6, para la lista de "mis reservas".
- **Preguntas probables del docente**:
  - *¿Por qué `calculo_reserva.dart` no es parte de un provider?* Porque no tiene estado: son fórmulas que siempre dan el mismo resultado para las mismas entradas, no hace falta `ChangeNotifier` para eso.
  - *¿De dónde salen las fechas en esta pantalla si no se le pasan por el constructor?* De `BusquedaProvider`, que las guarda desde que el usuario las eligió en `BusquedaScreen` — se comparten porque varias pantallas las necesitan.
  - *¿Qué pasa si la reserva falla (por ejemplo, un campo requerido faltante)?* `ReservaProvider.error` queda con el mensaje que mandó la API (o uno genérico si no hay conexión) y se muestra en un `SnackBar`, sin salir de la pantalla — el usuario puede reintentar.
- **Ejercicio para hacer a mano**: agregar una validación que impida confirmar si `noches` es 0 o negativo (no debería poder pasar porque `BusquedaScreen` ya valida que la salida sea posterior a la llegada, pero es un buen ejercicio de "defensa en profundidad").

**Probado**: con la API real caída (igual que en las fases anteriores), se usó el mock, editando temporalmente el lugar de ejemplo para que tuviera `precioNoche: "30.00"` y `costoLimpieza: "5.00"` (los valores del enunciado de la fase). Se buscó en Santa Cruz con fechas 10/11/2026 a 14/11/2026 (4 noches), se entró al detalle de "Casa Azul" (mostró "$us 30.00 por noche", confirmando el valor editado) y se tocó "Reservar": la pantalla mostró exactamente "4 noches x $us 30.00 = $us 120.00", "Limpieza $us 5.00", "Servicio $us 12.00" y "Total $us 137.00", coincidiendo con el cálculo esperado (120 + 5 + 12 = 137). Al tocar "Confirmar reserva" apareció el `SnackBar` "Reserva confirmada" y la app volvió a "Buscar lugares"; el log del mock registró un único `POST /api/reservas` → 200 en el momento exacto del toque, confirmando la ruta y el método correctos sin reintentos ni envíos duplicados. Se revirtieron después los valores de prueba del lugar en el mock y la URL de `api_config.dart` a la del túnel real.

⚠ Limitación conocida del mock (la misma que en la Fase A5): como no tiene estado persistente, `GET reservas/cliente/{id}` devuelve siempre la misma respuesta de ejemplo (`precioTotal: "400.00"`), sin reflejar la reserva recién creada. Se verificó por separado con `curl` que el endpoint responde 200 con la forma correcta (arreglo con `cliente` anidado), pero la comprobación de que **esta** reserva específica (137.00, 10/11 a 14/11) aparezca ahí queda pendiente para cuando el túnel real esté arriba, o se confirmará indirectamente en la Fase C6 al construir la pantalla de "mis reservas".

### Fase C6 — Cliente: mis reservas

- **Qué se hizo**: pantalla que lista las reservas del cliente logueado, usando `GET reservas/cliente/{id}`.
- **Archivos**:
  - `lib/model/reserva_model.dart` — `ReservaModel` con los campos propios de la reserva (`id`, `fechaInicio`, `fechaFin`, los 4 precios) más los datos del lugar, que vienen anidados en `lugar` como un **arreglo de 1 elemento** (no un objeto) según `docs/API.md`: `nombreLugar`, `primeraFotoUrl` (nullable) y `nombreAnfitrion` salen de ahí. Getter `noches` que reutiliza `calcularNoches` de la Fase C5 en vez de duplicar esa cuenta.
  - `lib/widget/reserva_card.dart` — ítem de la lista (foto, nombre del lugar, noches + fechas, anfitrión, precio total), mismo estilo que `lugar_card.dart`.
  - `lib/service/reserva_service.dart` — se agregó `obtenerReservasCliente(clienteId)` → `GET reservas/cliente/{id}`.
  - `lib/repository/reserva_provider.dart` — se agregaron `_reservas`/`_cargandoReservas`/`_errorReservas` (separados de `_cargando`/`_error`, que ya usaba `confirmarReserva`: son dos operaciones distintas del mismo provider, cada una con su propio estado de carga) y el método `cargarReservas(clienteId)`.
  - `lib/screen/mis_reservas_screen.dart` — reemplaza el placeholder: `StatefulWidget` que pide las reservas en `initState()` con el `cliente_id` del `AuthProvider`, y muestra la lista con `VistaEstado` + `ReservaCard`.
- **Flujo de datos**:
  1. Al entrar a la pantalla, `initState()` llama a `ReservaProvider.cargarReservas(clienteId)`.
  2. El service pide `GET reservas/cliente/{id}` y mapea cada elemento del arreglo a un `ReservaModel`.
  3. `ReservaModel.fromJson` entra al arreglo `lugar`, toma el primer (y único) elemento si existe, y de ahí saca nombre, primera foto y anfitrión — sin pedir `GET lugares/{id}` aparte, porque la API ya los manda anidados (a diferencia de lo que se previó como posibilidad en el plan original de esta fase).
  4. `ReservaCard` muestra todo con `formatearFecha`/`formatearPrecio` de `conversiones.dart`.
- **Conceptos clave**:
  - **Reutilizar una fórmula entre fases**: `ReservaModel.noches` llama a `calcularNoches` (de `calculo_reserva.dart`, Fase C5) en vez de repetir `fechaFin.difference(fechaInicio).inDays` en el modelo. Mismo criterio que calcula la noche de una reserva en toda la app, sin duplicar la lógica.
  - **Un arreglo que siempre tiene 0 o 1 elemento, no una lista real**: la API modela el lugar de una reserva como `lugar: [...]` en vez de `lugar: {...}` (posiblemente porque en el backend es una relación Eloquent cargada con `with()` sobre una tabla intermedia). El modelo lo trata como "un elemento opcional", no como una lista para iterar.
- **Decisiones y por qué**:
  - Los campos de carga/error de "mis reservas" son distintos a los de "confirmar reserva" dentro del mismo `ReservaProvider`: si fueran los mismos campos, mostrar el spinner de "mis reservas" se pisaría con el estado de "confirmando" si el usuario pasara de una operación a la otra rápido (no pasa en esta app porque son pantallas separadas, pero mezclar los dos conceptos en los mismos campos habría sido confuso de explicar).
- **Preguntas probables del docente**:
  - *¿Por qué `lugar` es un arreglo en vez de un objeto?* Porque así lo devuelve la API (confirmado en Fase 0); el modelo simplemente lo adapta tomando el primer elemento.
  - *¿Qué pasa si una reserva no tiene fotos?* `ReservaCard` muestra el ícono de imagen en gris, igual que `LugarCard`; nunca se asume que la lista de fotos tiene al menos un elemento.
  - *¿Por qué `noches` es un getter calculado y no un campo que viene de la API?* Porque la API no manda la cantidad de noches directamente, solo las fechas; se calcula en el cliente con la misma función que usa toda la app.
- **Ejercicio para hacer a mano**: agregar un texto "Sin reservas todavia" con un ícono (no solo el texto plano que ya pone `VistaEstado` para la lista vacía), para mejorar la pantalla cuando un cliente nuevo todavía no reservó nada.

**Probado**: con la API real caída, se usó el mock. Primero se repitió el flujo completo de la Fase C5 (buscar, entrar a "Casa Azul", reservar 4 noches) para generar una reserva nueva — esta vez sin editar los precios del mock, así que el desglose mostrado fue "4 noches x $us 150.00 = $us 600.00" + Limpieza $25 + Servicio $60 + **Total $us 685.00**, matemáticamente correcto con los precios reales del lugar de ejemplo. Al confirmar, volvió a la pantalla principal y se tocó "Ver reservas": apareció el estado de carga (`CircularProgressIndicator`) y luego un ítem con "Casa Azul", "2 noches · 01/12/2026 a 03/12/2026", "Anfitrion: Arrendatario de Ejemplo" y "$us 400.00" — estos datos corresponden a la respuesta fija de ejemplo del mock para `GET reservas/cliente/{id}` (la misma limitación de falta de persistencia ya documentada en la Fase C5), pero confirman que el parseo del arreglo `lugar` anidado, el cálculo de noches y el formato de fecha/precio funcionan correctamente de punta a punta. El log del mock registró `GET /api/reservas/cliente/1` → 200 con el `cliente_id` correcto de la sesión activa. Se revirtieron después la URL de `api_config.dart` y se apagaron emulador, `flutter run` y Mockoon.

### Fase C7 — Cliente: búsqueda avanzada

- **Qué se hizo**: pantalla con los mismos campos de la búsqueda simple más todos los campos filtrables del lugar (sin foto ni anfitrión), que arma el body solo con las claves que el usuario llenó y llama a `POST lugares/advancedsearch`.
- **Archivos**:
  - `lib/service/lugar_service.dart` — se agregó `busquedaAvanzada(Map<String, dynamic> filtros)` → `POST /lugares/advancedsearch`, mismo patrón que `buscar()`.
  - `lib/repository/busqueda_provider.dart` — se agregó `buscarAvanzado(Map<String, dynamic> filtrosLugar)`: arma el body con `{...filtrosLugar, 'ciudad': ciudad}`, llama al service y aplica el mismo filtro local de huéspedes que `buscar()` (la API tampoco recibe huéspedes en la avanzada).
  - `lib/screen/busqueda_avanzada_screen.dart` — reemplaza el placeholder. Reutiliza los controles de ciudad/fechas/huéspedes de `BusquedaScreen` y agrega: descripción, camas, baños, habitaciones, vehículos de parqueo, precio por noche (todos `TextField` opcionales) y wifi con un `DropdownButtonFormField<bool?>` de 3 valores (`null`="Cualquiera", `true`="Si", `false`="No") en vez de un switch de 2 estados, porque la API necesita poder **omitir** el filtro de wifi, no solo prenderlo/apagarlo.
  - Al armar el body: cada campo opcional solo se agrega si el usuario escribió algo (`if (controller.text.trim().isNotEmpty)`); wifi solo se agrega si no quedó en "Cualquiera". Nunca se manda un campo en `0` como forma de "no filtrar" (el hallazgo de la Fase 0: eso filtraría literalmente por `0`).
- **Flujo de datos**:
  1. El usuario llena ciudad + fechas (obligatorios, igual que en la búsqueda simple) y cualquier combinación de los campos opcionales del lugar.
  2. `_buscar()` arma un `Map<String, dynamic> filtros` agregando solo las claves con valor, guarda ciudad/fechas/huéspedes en `BusquedaProvider` (para que `ConfirmarReservaScreen` los pueda seguir usando después, igual que en la búsqueda simple) y llama a `buscarAvanzado(filtros)`.
  3. `BusquedaProvider` agrega `ciudad` al mapa y llama a `LugarService.busquedaAvanzada`, reutilizando `ResultadosScreen` para mostrar la lista o el mapa, exactamente igual que la búsqueda simple.
- **Conceptos clave**:
  - **Armar un body dinámico**: en vez de un objeto fijo con todos los campos (que obligaría a mandar `0` o `null` en los que faltan), se arma un `Map<String, dynamic>` vacío y se le agregan claves una por una solo cuando hay valor. Esto es necesario porque la API de este proyecto trata "campo ausente" y "campo en `0`" como cosas distintas (a diferencia de muchas otras APIs).
  - **Tres estados en vez de dos**: el `DropdownButtonFormField<bool?>` usa `null` como tercer estado ("no filtrar"), algo que un `Switch` normal (que solo tiene `true`/`false`) no puede representar.
- **Decisiones y por qué**:
  - No se usan `nombre` ni `costoLimpieza` como filtros aunque la API los acepta (confirmado en la Fase 0, no documentados en el PDF): el enunciado pide "todos los campos del lugar, menos foto y anfitrión", y esa lista ya queda cubierta por personas/camas/baños/habitaciones/wifi/parqueo/precio/ciudad/descripción. Agregar esos dos filtros sería inventar comportamiento sobre algo que no se pidió.
- **Preguntas probables del docente**:
  - *¿Por qué la búsqueda avanzada reutiliza `ResultadosScreen` en vez de tener su propia pantalla de resultados?* Porque el resultado es siempre una `List<LugarModel>`, sin importar cómo se buscó; `BusquedaProvider.resultados` no distingue el origen.
  - *¿Qué pasa si dejo todos los campos opcionales vacíos?* Se comporta igual que la búsqueda simple: el body solo lleva `ciudad`.
  - *¿Por qué el precio es de coincidencia exacta y no un rango?* Porque así lo confirmó la Fase 0 probando con valores arriba y abajo del precio real: ambos dieron 0 resultados.
- **Ejercicio para hacer a mano**: agregar un botón "Limpiar filtros" que resetee todos los controllers y el dropdown de wifi a sus valores por defecto sin salir de la pantalla.

**Probado**: con la API real caída, se usó el mock. Se llenó el formulario completo (ciudad "Santa Cruz", fechas 10/11 al 14/11, camas 2, baños 1, habitaciones 2, vehículos 1, precio 150, wifi "Si") — verificando cada campo con `adb shell uiautomator dump` en vez de solo capturas de pantalla, porque el teclado de Android (Gboard) tapaba parte del formulario con una barra flotante y en un intento inicial dos campos quedaron con texto duplicado ("21" en vez de "2" y "1" por una colisión del IME al cambiar de campo muy rápido); una vez confirmados los valores correctos en el árbol de UI, se tocó "Buscar" y apareció "Casa Azul" (el único lugar del mock, que coincide con todos los filtros). Luego se repitió la búsqueda cambiando solo la ciudad a `"sin-resultados"` (caso simulado del mock, ver `docs/API.md`) y apareció "No se encontraron lugares". El log del mock confirmó `POST /api/lugares/advancedsearch` → 200 en ambos casos. Se revirtió después `api_config.dart` a la URL real y se apagaron emulador, `flutter run` y Mockoon.

⚠ Limitación de esta prueba: igual que con la búsqueda simple y con `POST /reservas`, el mock no evalúa realmente los filtros recibidos (siempre devuelve el mismo lugar de ejemplo si la ciudad no es `"sin-resultados"`), así que no se pudo verificar con el mock que un campo incompatible (ej. `cantCamas: 99`) excluya al lugar por coincidencia exacta real — esa semántica ya había sido confirmada directamente contra la API real en la Fase 0 (ver hallazgos en `docs/API.md`) y queda pendiente de una verificación visual en la app cuando el túnel vuelva a estar arriba.

### Fase E0 — Correcciones previas (ambas apps)

- **Qué se hizo**: primera subfase de la Fase E (mejora estética, rama `mejora-estetica`, tag `v1-funcional` sobre la última versión funcional). Son correcciones de comportamiento, no de estilo: navegación hacia atrás en Ionic, tildes/eñes en todo el texto visible, manejo de foto rota en el formulario del arrendatario, atribución obligatoria del mapa de OpenStreetMap en Flutter, y el rango de fechas del selector de salida. El punto 1 del documento (misma URL de API en ambas apps) ya estaba resuelto de antes: las dos apuntan al mock local de Mockoon.
- **Archivos**:
  - `app-arrendatario/src/app/pages/lugar-form/lugar-form.page.html` (+ `.ts`) — se agregó `<ion-back-button defaultHref="/mis-lugares">`, el manejo `(error)` en la foto existente (mismo patrón que `mis-lugares`) y se corrigieron tildes en etiquetas y mensajes de validación.
  - `app-arrendatario/src/app/pages/reservas-lugar/reservas-lugar.page.html` (+ `.ts`) — se agregó `<ion-back-button defaultHref="/lugar/{{ idLugar }}">` (vuelve al lugar concreto, no a una ruta fija) y se corrigió una tilde.
  - `app-arrendatario/src/app/pages/login/login.page.html`, `registro/registro.page.html`, `mis-lugares/mis-lugares.page.html` — tildes en títulos, etiquetas y botones.
  - `app-cliente/lib/screen/login_screen.dart`, `registro_screen.dart`, `detalle_lugar_screen.dart`, `confirmar_reserva_screen.dart`, `mis_reservas_screen.dart`, `lib/widget/reserva_card.dart` — tildes en títulos, etiquetas, validaciones y mensajes.
  - `app-cliente/lib/widget/mapa_lugares.dart` — se agregó `SimpleAttributionWidget` como hijo de `FlutterMap` (la licencia de OpenStreetMap exige mostrar la atribución sobre el mapa).
  - `app-cliente/lib/screen/busqueda_screen.dart` y `busqueda_avanzada_screen.dart` — se reescribió `_elegirFecha()` (ver abajo) y se corrigieron tildes.
  - `contexto/mockoon-backend-airbnb.json` (fuera de las dos apps, solo para poder probar): no tenía ninguna ruta que sirviera los archivos de foto — toda foto daba 404 desde que se armó el mock. Se agregó la ruta `GET /fotos/:archivo` (fuera del prefijo `/api`, igual que lo espera `urlFoto()`) que devuelve el archivo correspondiente de una carpeta nueva `contexto/fotos-mock/`.
- **Flujo de datos** (lo que cambió, no lo que ya existía):
  1. **Volver en Ionic**: `ion-back-button` usa la pila de navegación del navegador, no un clic que llame a un método propio; por eso alcanza con `defaultHref` (a dónde ir si no hay historial, por ejemplo al abrir la página por URL directa).
  2. **Fecha de salida**: `_elegirFecha(esLlegada: true)` limita su propio rango a hoy..hoy+364 días; `_elegirFecha(esLlegada: false)` calcula `primerDiaSalida = llegada + 1 día` (o hoy, si todavía no hay llegada) y lo usa como `firstDate` e `initialDate`, con `lastDate` en hoy+365. Al elegir una llegada nueva que empata o pasa la salida ya elegida, se borra `_fechaSalida` para forzar a elegirla de nuevo.
- **Conceptos clave**:
  - **Por qué el límite es 364/365 y no comparar con `min()`**: Dart no tiene un `min()` para `DateTime` (sí para números). En vez de comparar fechas, se fijó el límite superior de la llegada un día antes que el de la salida: así el día siguiente a la llegada más tardía posible (hoy+364+1 = hoy+365) nunca supera el `lastDate` de la salida, sin necesitar comparar nada.
  - **`ion-back-button` con interpolación en `defaultHref`**: `defaultHref="/lugar/{{ idLugar }}"` arma la URL con el dato de la propia página (el `id` del lugar que ya se leyó de la ruta), en vez de un valor fijo.
- **Decisiones y por qué**:
  - El ajuste de fechas no valida nada nuevo: la regla de negocio ("salida posterior a llegada") sigue solo en `_buscar()`, igual que antes. Los cambios de esta subfase solo evitan que el selector *ofrezca* una fecha inválida; no reemplazan la validación.
  - La ruta de fotos del mock se agregó sin tocar las 16 rutas de la API documentadas en `docs/API.md` (se les anteponió `api/` moviendo el prefijo del entorno a cada endpoint, en vez de dejarlo en `endpointPrefix`, justo para poder sacar `/fotos` de ese prefijo): se verificó con `curl` que `/api/cliente/login`, `/api/lugares/search` y `/api/lugares/{id}` siguen respondiendo exactamente igual que antes.
- **Preguntas probables del docente**:
  - *¿Por qué `defaultHref` y no un método `volver()` con `Router.navigate`?* `ion-back-button` ya sabe volver a la página anterior de la pila de Ionic; `defaultHref` solo cubre el caso de que no haya una (por ejemplo, abrir la URL del formulario directo). Agregar un método propio sería repetir algo que el componente ya hace.
  - *¿Por qué se borra la fecha de salida al cambiar la llegada, y no simplemente dejar la salida inválida hasta que el usuario toque "Buscar"?* Porque `_buscar()` recién valida al tocar el botón; dejar una fecha de salida que ya no tiene sentido mostrada en pantalla (por ejemplo, anterior a la nueva llegada) confundiría antes de llegar a ese punto.
  - *¿La atribución de OpenStreetMap es obligatoria o es solo buena práctica?* Es una condición de la licencia de uso de los tiles (`tile.openstreetmap.org`), no una sugerencia; por eso se agrega siempre, no solo cuando se nota que falta.
- **Ejercicio para hacer a mano**: en `busqueda_screen.dart`, agregar que si el usuario elige una fecha de salida y después una de llegada que la invalida, además de borrarse la salida (ya lo hace) se muestre un mensaje corto avisando que hay que elegirla de nuevo.

**Probado**: con el mock de Mockoon corriendo (ver más abajo el arreglo de la ruta de fotos), se verificó con `curl` que `/api/cliente/login`, `/api/lugares/search` y `/api/lugares/1` responden igual que antes de mover el `endpointPrefix`, y que `/fotos/casa-azul.jpg`, `/fotos/casa-azul-2.jpg` y `/fotos/casa-azul-3.jpg` devuelven `200 image/jpeg` (antes daban 404 siempre, desde que existe el mock).

**Verificación posterior (app-arrendatario, automatizada con Playwright)**: se escribió un test temporal (`e2e/fase-e0.spec.ts`, borrado al terminar) que corrió contra `ng serve` real (Playwright lo levanta y lo apaga solo): login/registro muestran los textos con tilde; login → abrir "Casa Azul" → las 3 fotos cargan (`naturalWidth > 0`, ya no 404) → la flecha de volver lleva a `/mis-lugares`; desde el lugar, "Ver reservas" → la flecha vuelve al mismo lugar (`/lugar/1`, no a la lista); abrir `/lugar/nuevo` directo y recargar → la flecha igual lleva a `/mis-lugares` (usa `defaultHref` al no haber historial de navegación); "Guardar" con la descripción vacía muestra el toast "Ingresa una descripción" con tilde. Los 5 tests pasaron; se revisaron las capturas de cada paso a mano antes de borrar el test.

**Verificación posterior (app-cliente, manual en emulador Android)**: se probó el flujo completo (login → búsqueda con el ajuste de fechas → detalle de "Casa Azul" → vista de mapa con la atribución → búsqueda avanzada → reservar → "Mis reservas") con un checklist. Todo correcto, con un hallazgo: en "Búsqueda avanzada", el desplegable de Wifi mostraba el texto "Cualquiera" como valor por defecto, lo cual se veía como si ya hubiera algo seleccionado. Se corrigió **sin tocar la lógica** (`_tieneWifi` sigue en `null` por defecto, el filtro se sigue omitiendo del body si no se toca el campo): se agregó `selectedItemBuilder` al `DropdownButtonFormField` de `busqueda_avanzada_screen.dart` para que el campo cerrado se vea vacío cuando el valor es `null`, mostrando "Sí"/"No" solo cuando el usuario elige uno; la opción "Cualquiera" sigue disponible dentro del menú desplegado, por si se quiere volver a "sin filtro".

### Fase E1 — App cliente: tema visual

- **Qué se hizo**: toda la app cliente pasó a usar un tema centralizado (verde de la bandera de Santa Cruz como color de marca, dorado como acento exclusivo para destacar precios, formas redondeadas, un solo lugar con el estilo) en vez de los widgets por defecto de Material. Se tocaron las 10 pantallas/widgets del plan de `docs/FASE-E-ESTETICA.md` (tema, login/registro, búsqueda, `LugarCard`, resultados, marcadores del mapa, detalle, confirmar reserva, `ReservaCard`, `VistaEstado`), sin cambiar ningún endpoint, cálculo ni flujo de pantallas. Se verificó con `flutter --version` (3.47.5) que `ColorScheme.fromSeed` y `DynamicSchemeVariant.fidelity` existen en esta versión, y que `ThemeData.cardTheme` ahora exige `CardThemeData` (no el `CardTheme` clásico).
  - **Cambio de paleta (ya cerrada esta subfase)**: el primer intento usó coral (`#E8505B`, el mismo de Airbnb); se cambió a verde/dorado porque varios compañeros de la materia habían elegido ese mismo coral. El verde (`#0B6E4F`) sale de la bandera de Santa Cruz de la Sierra (ciudad donde se ambienta el proyecto); el dorado (`#E9A23B`) se usa **solo** como fondo para destacar precios (nunca como color de botones ni textos), y siempre con texto oscuro encima (`#1D2622`), nunca blanco, porque blanco sobre dorado no se lee bien.
- **Archivos**:
  - `lib/config/tema.dart` (nuevo) — función `crearTema()`: `ColorScheme.fromSeed` con el verde como semilla, con `.copyWith(primary: colorMarca, onPrimary: Colors.white, tertiary: colorAcento, onTertiary: textoSobreAcento)` para fijar el verde y el dorado exactos (no un tono calculado), fondo, `AppBarTheme` (blanco, sin sombra), `InputDecorationTheme`/`FilledButtonThemeData`/`OutlinedButtonThemeData` (radio 12, alto 48), `CardThemeData` (radio 16) y `ChipThemeData`; expone además `colorMarca`, `colorAcento`, `textoSobreAcento`, `colorTextoPrincipal` y `colorTextoSecundario` como constantes para los pocos lugares que necesitan un color por fuera de un widget con tema (ej. un ícono gris en un texto secundario).
  - `lib/main.dart` — una línea: `theme: crearTema()` en el `MaterialApp`.
  - `lib/widget/encabezado_bnb.dart` (nuevo) — ícono de casa en un círculo de `colorScheme.primary`, "bnb" y un subtítulo; reutilizado por login y registro.
  - `lib/screen/login_screen.dart`, `registro_screen.dart` — sin `AppBar`; contenido centrado en `SingleChildScrollView` (para que el teclado no tape los campos), `EncabezadoBnb`, campos con `prefixIcon`, botón principal `FilledButton`.
  - `lib/widget/campo_fecha.dart`, `contador_huespedes.dart` (nuevos) — extraídos de `busqueda_screen.dart` para que el archivo no pasara de ~200 líneas y porque son los mismos controles que ya existían, solo reempaquetados como widgets con nombre.
  - `lib/screen/busqueda_screen.dart` — saludo "Hola, {primer nombre}", formulario dentro de una `Card`, llegada/salida lado a lado con `CampoFecha` (un `InputDecorator` que hereda el estilo de campos de `tema.dart` en vez de pintar un cuadro a mano), huéspedes con `ContadorHuespedes`, "Buscar" como `FilledButton.icon`, "Búsqueda avanzada"/"Ver reservas" como `OutlinedButton.icon`.
  - `lib/widget/foto_lugar.dart` (nuevo) — `Image.network(urlFoto(...))` con `errorBuilder`, placeholder cuando no hay foto y radio de borde configurable; reemplaza el `Image.network` que antes estaba repetido en `LugarCard`, `GaleriaFotos`, `ConfirmarReservaScreen` y `ReservaCard`.
  - `lib/widget/lugar_card.dart` — foto 16:9 arriba (sin radio propio: el `Card` ya recorta sus esquinas), nombre, descripción en 2 líneas, personas y precio en una fila. Sigue mostrando los 5 datos de RC-07.
  - `lib/screen/resultados_screen.dart` — el botón de mapa/lista pasó a `FloatingActionButton.extended` centrado abajo; el título de la `AppBar` muestra la ciudad y la cantidad de resultados.
  - `lib/widget/mapa_lugares.dart` — los marcadores pasaron de "pin + etiqueta" a una pastilla de precio (`colorScheme.tertiary` de fondo — el dorado, para destacar el precio —, texto en negrita `colorScheme.onTertiary`, sombra suave), sin el ícono de pin.
  - `lib/widget/caracteristicas_lugar.dart`, `barra_reservar.dart` (nuevos) — extraídos de `detalle_lugar_screen.dart` por la misma razón que `campo_fecha.dart`/`contador_huespedes.dart`: mantener cada archivo corto. `CaracteristicasLugar` arma un `Wrap` de `Chip`s (personas, camas, baños, habitaciones, wifi, parqueo — los datos de RC-12 que no son nombre/descripción/anfitrión/precio). `BarraReservar` es la barra inferior fija con el precio y el botón "Reservar".
  - `lib/screen/detalle_lugar_screen.dart` — galería, nombre, ciudad, `CircleAvatar` con la inicial del anfitrión + "Anfitrión: X", `CaracteristicasLugar`, subtítulo "Acerca de este lugar" + descripción. La `BarraReservar` solo se pasa a `bottomNavigationBar` cuando el lugar ya cargó (`lugar == null ? null : BarraReservar(...)`): mientras carga o si hubo un error, el `Scaffold` no tiene barra inferior.
  - `lib/widget/galeria_fotos.dart` — reescrito para usar `FotoLugar` (foto grande y miniaturas), con esquinas redondeadas y el borde del color de marca en la miniatura seleccionada.
  - `lib/screen/confirmar_reserva_screen.dart` — se agregó una `Card` de resumen (miniatura con `FotoLugar`, nombre, fechas `dd/MM/yyyy`, cantidad de huéspedes) antes de la `Card` de desglose ya existente; la fila "Total" quedó con `fontSize` mayor además de negrita; el botón "Confirmar reserva" pasó a `bottomNavigationBar` fijo.
  - `lib/widget/reserva_card.dart` — foto de 80×80 con `FotoLugar`, nombre en negrita, fila con ícono de calendario y fechas, "N noches · Anfitrión: X", precio total en negrita.
  - `lib/widget/vista_estado.dart` — parámetro opcional `icono`: lo usa el estado vacío (cada pantalla elige el suyo, ej. `Icons.search_off` en resultados, `Icons.event_busy_outlined` en mis reservas); el estado de error siempre usa `Icons.wifi_off`, porque casi todos los errores de esta app son de conexión con la API.
  - Limpieza de colores sueltos encontrada al revisar el resultado: `encabezado_bnb.dart` pintaba el círculo con la constante `colorMarca` y el ícono con `Colors.white` a mano; se cambiaron ambos a `colorScheme.primary`/`colorScheme.onPrimary` (el par que el tema garantiza con buen contraste). `vista_estado.dart` usaba `Colors.grey` para el ícono; se cambió a la constante `colorTextoSecundario` de `tema.dart`. `foto_lugar.dart` pintaba su placeholder con `Colors.grey.shade300`/`Colors.white`; se cambió a `colorScheme.surfaceContainerHighest`/`colorScheme.onSurfaceVariant`.
- **Flujo de datos**: no cambió ningún flujo (misma secuencia pantalla → provider/service → API → respuesta → pantalla de las fases C1-C7). Lo único nuevo es que varias pantallas ahora arman su UI a partir de widgets compartidos (`FotoLugar`, `CampoFecha`, `ContadorHuespedes`, `CaracteristicasLugar`, `BarraReservar`, `EncabezadoBnb`) en vez de repetir el mismo código de `Image.network`, campo de fecha o fila de `Chip`s en cada pantalla.
- **Conceptos clave**:
  - **Un tema centralizado (`ThemeData`)**: cualquier widget de Material (`FilledButton`, `TextFormField`, `Card`, `Chip`, `AppBar`) sin estilo propio toma automáticamente los valores de `crearTema()`; cambiar el color de marca implica tocar unas pocas líneas en `tema.dart` (`colorMarca`/`colorAcento` y el `copyWith`), no cada pantalla — así se cambió de coral a verde/dorado sin tocar ninguna screen.
  - **`ColorScheme.fromSeed` + `DynamicSchemeVariant.fidelity`**: a partir de un solo color (el de marca) genera los ~15 colores que Material 3 necesita (primario, superficie, bordes, etc.) ya combinados para tener buen contraste entre sí; `fidelity` hace que el color primario resultante se parezca al color semilla en vez de suavizarlo (que es lo que hace la variante por defecto, `tonalSpot`).
  - **`InputDecorator` para un campo "falso"**: `CampoFecha` no es un `TextField` real (no se puede escribir una fecha a mano), pero usa `InputDecorator` para heredar exactamente el mismo relleno, borde y label flotante que sí define `tema.dart`, en vez de copiar esos valores a mano.
  - **`selectedItemBuilder` de un `DropdownButtonFormField` vs. las nuevas extracciones de widgets**: son soluciones al mismo problema ("un widget de Flutter no tiene, de fábrica, el aspecto que pide el diseño") en capas distintas: una ajusta cómo un widget existente se dibuja, la otra agrupa código repetido en un widget con nombre propio.
- **Decisiones y por qué**:
  - `FotoLugar` se creó recién en el punto 4 (su primer uso, `LugarCard`) y no antes, en el punto 1: no tenía sentido crear un widget compartido antes de tener al menos dos pantallas que lo fueran a usar.
  - `CaracteristicasLugar` y `BarraReservar` se separaron de `detalle_lugar_screen.dart` únicamente por tamaño de archivo (la regla de ~200 líneas de `CLAUDE.md`), no porque se reutilicen en otra pantalla todavía; si en el futuro otra pantalla necesita los mismos chips o la misma barra, ya están listos para reutilizarse.
  - La barra inferior del detalle (y el botón de confirmar reserva) usan `bottomNavigationBar` del `Scaffold` en vez de ponerse como el último elemento de la lista: así quedan siempre visibles sin necesidad de bajar hasta el final, y es el patrón estándar de Flutter para una barra de acción fija.
  - Los marcadores del mapa y el placeholder de `FotoLugar` toman su color de `Theme.of(context).colorScheme`, no de las constantes de `tema.dart` (`colorMarca`, etc.): `colorScheme` ya resuelve automáticamente el contraste entre fondo y texto/ícono (ej. `surface`+`onSurfaceVariant`), mientras que las constantes son valores sueltos pensados para los pocos casos sin ese emparejamiento automático (ej. un texto secundario suelto).
- **Preguntas probables del docente**:
  - *¿Dónde cambiarías el color principal de la app?* En una sola línea: `seedColor` dentro de `crearTema()`, en `lib/config/tema.dart`. Todos los botones, campos, `AppBar`s y chips lo toman automáticamente de ahí.
  - *¿Por qué casi ninguna pantalla tiene colores escritos a mano?* Porque cada widget de Material ya sabe pintarse con los valores de `ThemeData` (`colorScheme`, `cardTheme`, etc.); escribir un color a mano en una pantalla rompería esa fuente única de verdad y quedaría desactualizado si el tema cambia.
  - *¿Qué pasa si `_lugar` es `null` en el detalle (cargando o con error)?* `bottomNavigationBar: lugar == null ? null : BarraReservar(...)` — el `Scaffold` directamente no muestra ninguna barra inferior en esos casos, en vez de mostrar una con el botón deshabilitado.
  - *¿Por qué `CampoFecha` no es un `TextFormField` con `readOnly: true`?* Porque no es parte de ningún `Form`/`validator` (la pantalla ya valida las fechas a mano en `_buscar()`); usar `InputDecorator` directamente es más simple y de todas formas se ve igual, porque solo se necesitaba el aspecto visual del campo, no su comportamiento de edición de texto.
- **Ejercicio para hacer a mano**: en `widget/caracteristicas_lugar.dart`, agregar un chip más que muestre el precio de limpieza (`costoLimpieza`) del lugar, con un ícono de limpieza (`Icons.cleaning_services_outlined`).

**Probado**: `flutter analyze` sin advertencias después de cada uno de los 10 puntos (se corrió 11 veces en total, incluida la limpieza final de colores). No se hizo una prueba visual punto por punto en el emulador durante esta subfase por tiempo; la prueba completa de punta a punta en el emulador queda pendiente antes de cerrar la Fase E (E3).

### Fase E2 — App arrendatario: Android con Capacitor y tema visual

- **Qué se hizo**: dos cosas distintas en la misma subfase. Primero (punto 0, agregado por el usuario a mitad de la fase): la app arrendatario pasó de "solo navegador" a correr también como app nativa Android con Capacitor, con su propio `appId` y las URLs correctas según dónde corre. Segundo (puntos 1 a 6, el plan original de `docs/FASE-E-ESTETICA.md`): toda la app pasó a usar el tema verde/dorado (igual que la Fase E1 en Flutter) con componentes modernos de Ionic (`ion-input` con `label`/`fill`, `ion-list inset`, `ion-input-password-toggle`), un componente nuevo reutilizable (`selector-cantidad`) y el marcador del mapa tomando su color del tema en vez de un valor fijo.
- **Archivos**:
  - `app-arrendatario/capacitor.config.ts` — `appId: 'bo.edu.nur.bnb_arrendatario'`, `appName: 'bnb Anfitriones'` y `server: { androidScheme: 'http', cleartext: true }` (ver "Conceptos clave").
  - `app-arrendatario/android/` (nuevo, generado por `npx cap add android`) — proyecto nativo completo; su propio `.gitignore` ya excluye `build/`, `.gradle/` y `local.properties` (se verificó con `git add -n` que solo entran los ~53 archivos fuente, nada compilado).
  - `app-arrendatario/src/environments/environment.ts` y `environment.prod.ts` — cada uno con un comentario de para qué se usa (ver "Conceptos clave").
  - `app-arrendatario/package.json` — se agregó `@capacitor/android@8.6.2` (misma versión mayor que `@capacitor/core@8.6.0`, ya instalado); es la única dependencia nueva de esta subfase.
  - `app-cliente/android/app/src/main/AndroidManifest.xml` — `android:label` de "BNB Cliente" a "bnb" (pedido del usuario, sin relación con la app arrendatario).
  - `app-arrendatario/src/theme/variables.scss` — colores de marca (`--ion-color-primary` verde, `--ion-color-secondary` dorado con su `rgb`/`contrast`/`shade`/`tint`), `--ion-color-medium` (texto secundario), `--ion-background-color`/`--ion-text-color`, `--ion-card-background`/`--ion-item-background` (superficies blancas) y `--ion-toolbar-background`/`--ion-toolbar-color` (encabezado del color del fondo, no blanco).
  - `app-arrendatario/src/global.scss` — se comentó el import de `dark.system.css` (solo modo claro) y se agregaron las clases compartidas: `.estado-vacio`, `.foto-portada`, `.encabezado-marca`/`.icono-marca`/`.pastilla-marca` (login, registro), `.campo-arena` (el mismo estilo de campo en login, registro y el formulario de lugar, en un solo lugar), `.boton-flecha`, `.titulo-seccion`, `.pastilla-conteo` y `.texto-enlace`.
  - `app-arrendatario/src/index.html` — `<meta name="color-scheme" content="light">`.
  - `app-arrendatario/src/app/pages/login/` y `registro/` (`.html`+`.ts`) — encabezado con ícono en círculo y pastilla "Para anfitriones"; formulario dentro de `ion-card`; campos `ion-input` con `labelPlacement="stacked"`, `fill="solid"` y la clase `.campo-arena`; ícono de sobre/teléfono al final del campo; `ion-input-password-toggle` en la contraseña; botón principal con ícono de flecha; enlace de texto hacia la otra pantalla. En los `.ts` solo cambiaron los imports de componentes Ionic y los íconos (`addIcons`) — `iniciarSesion()`/`registrar()` quedaron intactos.
  - `app-arrendatario/src/app/pages/mis-lugares/` (`.html`+`.ts`+`.scss`, nuevo) — encabezado con `resumenLugares()` (singular/plural); cada lugar como `ion-card` con foto de portada, pastilla dorada de precio superpuesta, fila de características y los botones "Editar"/"Ver reservas" con `$event.stopPropagation()`; botón flotante "Publicar nuevo" (un `ion-button` normal dentro de `ion-fab`, no un `ion-fab-button`, para poder llevar texto además del ícono); estado vacío con `.estado-vacio`.
  - `app-arrendatario/src/app/pages/lugar-form/` (`.html`+`.ts`+`.scss`) — formulario reorganizado en 6 secciones (`ion-list [inset]="true"` + `ion-list-header` con ícono); grilla de 3 columnas para las fotos; los 4 campos de cantidad pasaron a `app-selector-cantidad`; footer fijo con "Guardar".
  - `app-arrendatario/src/app/components/selector-cantidad/` (nuevo: `.ts`+`.html`+`.scss`) — componente reutilizable con botones −/+, usado 4 veces en el formulario.
  - `app-arrendatario/src/app/pages/reservas-lugar/` (`.html`+`.ts`+`.scss`) — tarjeta de resumen con `resumenReservas()`; cada reserva como `ion-card` con foto, cliente, fechas, `ion-chip` de noches y total en pastilla dorada.
  - `app-arrendatario/src/app/components/mapa-selector/mapa-selector.component.ts` — `colocarMarcador()` lee `--ion-color-primary` y `--ion-color-primary-contrast` del tema en vez de un color escrito a mano.
  - `app-arrendatario/CLAUDE.md` (no versionado, ver `.gitignore`) — nota de que ahora se valida también en el emulador Android.
  - `docs/FASE-E-ESTETICA.md` — sección "Referencia Stitch" dentro de E2: qué se tomó de cada pantalla de `docs/diseño-stitch/` y qué se dejó fuera.
  - `app-arrendatario/angular.json` — un cambio que **no** es de esta subfase: Angular CLI agregó `"analytics": false` solo porque, al correr `npm run build` manualmente, el usuario respondió "No" a la pregunta de telemetría que el CLI hace la primera vez; es un efecto del CLI, no un cambio deliberado del plan.
- **Flujo de datos**:
  1. **Qué URL usa la app y cuándo**: `ionic serve` (navegador) compila con la configuración `development` de `angular.json` → usa `environment.ts` (`http://localhost:3001/api`, porque el navegador y Mockoon corren en la misma PC). `npm run build` (lo que después empaqueta `npx cap sync android` hacia el emulador) usa la configuración `production` (`defaultConfiguration` en `angular.json`) → `fileReplacements` cambia `environment.ts` por `environment.prod.ts` (`http://10.0.2.2:3001/api`), porque dentro del emulador "localhost" apuntaría al propio emulador, no a la PC que lo hospeda — `10.0.2.2` es el alias fijo que usa el emulador de Android para llegar a la PC.
  2. **`selector-cantidad` en el formulario**: `LugarFormPage` pasa el número actual con `[valor]="obtenerCantidad('cantCamas')"` → el componente dibuja el número y, al tocar +/-, llama a `sumar()`/`restar()` (que valida el mínimo) → emite el nuevo número con `cambio.emit(...)` → `(cambio)="actualizarCantidad('cantCamas', $event)"` en la página convierte ese número de vuelta a texto y lo guarda en `formulario.cantCamas`. `obtenerCantidad()`/`actualizarCantidad()` son el único lugar de conversión texto↔número; `guardar()`/`validar()` no se tocaron.
  3. **`stopPropagation()` en Mis lugares**: tocar en cualquier parte de la tarjeta dispara `irAEditarLugar()` (el `click` del `ion-card`); los botones "Editar" y "Ver reservas" están *dentro* de esa misma tarjeta, así que su propio `click` burbujea hacia arriba y dispararía también el de la tarjeta — `$event.stopPropagation()` corta esa burbuja antes de que llegue al `ion-card`, dejando que cada botón navegue solo a su propio destino.
- **Conceptos clave**:
  - **Variables de Ionic (`--ion-color-*`) vs `ThemeData` de Flutter**: cumplen el mismo rol (un solo lugar con los colores de marca) con una diferencia clave — en Angular/Ionic son variables CSS normales (`:root { --ion-color-primary: #0b6e4f; }`, en `variables.scss`), no un objeto de Dart; cualquier componente de Ionic ya sabe leerlas solo (`color="primary"`), sin que la página tenga que importar nada.
  - **Clases reutilizables de `global.scss`** (`.campo-arena`, `.estado-vacio`, `.pastilla-conteo`, etc.): el mismo problema que `tema.dart` resuelve con un `ThemeData` completo, aquí se resuelve con clases CSS comunes que varias páginas comparten — por ejemplo `.campo-arena` se escribió una sola vez y se usa en los campos de login, registro y el formulario de lugar.
  - **`input()`/`output()` en `selector-cantidad`**: mismo patrón que ya usaba `mapa-selector` desde la Fase A3 — un componente hijo no modifica nada del padre directamente, solo recibe datos (`input()`) y avisa con un evento (`output()`); quien decide qué hacer con ese aviso es siempre el padre.
  - **`$event.stopPropagation()`**: necesario cuando un elemento clicable (un botón) vive adentro de otro elemento clicable (la tarjeta completa); sin cortar la propagación, un solo toque dispararía las dos acciones a la vez.
  - **Leer una variable CSS en tiempo de ejecución (`getComputedStyle`)**: Leaflet es una librería de JavaScript puro, no sabe nada de Angular ni de variables de Ionic — `L.circleMarker` necesita el color ya resuelto como texto (`"#0b6e4f"`), no como `var(--ion-color-primary)`; `getComputedStyle(document.documentElement).getPropertyValue(...)` es la forma de "preguntarle" al navegador cuál es el valor actual de esa variable, para no escribir el verde a mano una segunda vez fuera de `variables.scss`.
  - **Capacitor `server.androidScheme`/`cleartext`**: Android, desde la versión 9, bloquea por defecto cualquier petición HTTP que no sea HTTPS. En desarrollo, la app llama a Mockoon por `http://10.0.2.2:3001` (HTTP simple); `androidScheme: 'http'` hace que la propia app también se sirva a sí misma por HTTP (en vez de HTTPS, su valor por defecto), y `cleartext: true` autoriza explícitamente ese tráfico sin cifrar. Antes de la defensa, si se usa la API real (HTTPS), estas dos líneas dejan de ser necesarias pero no hace falta quitarlas: no afectan a una app que ya usa HTTPS.
- **Decisiones y por qué**:
  - El `appId` (`bo.edu.nur.bnb_arrendatario`) se fijó en `capacitor.config.ts` **antes** de correr `npx cap add android`, porque Capacitor genera el proyecto Android completo (carpetas, `AndroidManifest.xml`, `build.gradle`) a partir de ese valor; cambiarlo después implicaría editar varios archivos nativos a mano en vez de uno solo.
  - "Vehículos de parqueo" se quedó como `ion-input` numérico normal, no como `selector-cantidad`: el usuario solo pidió el selector para personas/camas/baños/habitaciones, y agregarlo ahí también habría sido una extensión no pedida.
  - `lugar-form.page.ts`/`.html` quedaron por encima de las ~200 líneas sugeridas por `CLAUDE.md` (323 y 226 líneas): la alternativa (mover `fotosExistentes`/`fotosNuevas` a un componente aparte) habría obligado a cambiar cómo `guardar()` lee esas listas, y la regla de esta fase es no tocar `guardar()`/`validar()` bajo ninguna circunstancia — se prefirió el archivo más largo a romper esa regla.
  - En los placeholders de foto rota (`mis-lugares`, `reservas-lugar`, `lugar-form`) se usa `var(--ion-color-light)` sin un valor de respaldo (`var(--x, #hex)`): Ionic ya define esa variable por defecto en su propio `core.css`, así que escribir un `#hex` de respaldo a mano habría sido un color fuera de `variables.scss`/`global.scss` sin ninguna necesidad real.
- **Preguntas probables del docente**:
  - *¿Por qué la app necesita `cleartext: true` en `capacitor.config.ts`?* Porque en desarrollo llama a Mockoon por HTTP simple (`http://10.0.2.2:3001`) y Android bloquea el tráfico sin cifrar por defecto; `androidScheme: 'http'` + `cleartext: true` lo autorizan explícitamente, solo mientras no se use la API real (HTTPS).
  - *¿Cómo decide `selector-cantidad` si puede seguir restando?* No lo decide el componente solo con su propio estado: el padre le pasa `minimo` (siempre 1 en este formulario) como `input()`, y `restar()` compara `valor() > minimo()` antes de emitir el cambio; si ya está en el mínimo, el botón queda deshabilitado (`[disabled]="valor() <= minimo()"`).
  - *¿Por qué el botón "Editar" de una tarjeta de Mis lugares necesita `stopPropagation()` si total hace casi lo mismo que tocar la tarjeta?* Porque sin cortar la propagación del clic, tocar "Editar" dispararía *dos* navegaciones a la vez (la del botón y la de la tarjeta que lo contiene), y con "Ver reservas" sería peor: terminaría en una pantalla distinta a la que el botón dice llevar.
- **Ejercicio para hacer a mano**: en `lugar-form.page.html`, cambiar el campo "Vehículos de parqueo" de `ion-input type="number"` a un `app-selector-cantidad` más (mismo patrón que personas/camas/baños/habitaciones), sin tocar `guardar()` ni `validar()`.

### Ajustes entre E2 y E3 — diseños de Stitch de referencia, pluralización y mapa del cliente

- **Qué se hizo**: dos cambios fuera del plan original de `docs/FASE-E-ESTETICA.md`, hechos entre el cierre de la Fase E2 y el cierre de la Fase E3. Primero, se agregaron a `docs/diseño-stitch/` los 7 diseños de referencia de Stitch usados para orientar los rediseños de las Fases E1 y E2 (solo HTML de referencia visual, nunca copiado tal cual — ver la tabla "Referencia Stitch" dentro de la Fase E2 de `docs/FASE-E-ESTETICA.md`). Segundo, se corrigió un detalle que había quedado mal desde la Fase E1/E2: varias pantallas de las dos apps mostraban cantidades siempre en plural ("1 baños", "1 noches"), y al precio del detalle le faltaba la palabra "noche". Se aprovechó el mismo cambio para rediseñar el marcador del mapa del cliente (pastilla de precio + círculo con ícono de casa sobre la coordenada exacta, en vez de solo la pastilla) y agregar una barra flotante con el resumen de la búsqueda sobre el mapa, siguiendo el diseño de referencia `mapa_de_alojamientos_santa_cruz` de Stitch que hasta ese momento no se había aplicado.
- **Archivos**:
  - `app-cliente/lib/utils/conversiones.dart` — función nueva `pluralizar(cantidad, singular, plural)` y `formatearFechaCorta()` (versión sin año, para la barra de resumen).
  - `app-arrendatario/src/app/utils/formato.ts` — función nueva `pluralizar(cantidad, singular, plural)`, misma firma que en Flutter.
  - `app-cliente/lib/widget/caracteristicas_lugar.dart`, `lugar_card.dart`, `reserva_card.dart`, `lib/screen/confirmar_reserva_screen.dart` — cada cantidad (personas, camas, baños, habitaciones, vehículos de parqueo, huéspedes, noches) pasó de texto fijo (`'$n camas'`) a `pluralizar(n, 'cama', 'camas')`.
  - `app-cliente/lib/widget/barra_reservar.dart` — el precio del detalle pasó de `"$us 30.00 noche"` a `"$us 30.00 / noche"`.
  - `app-arrendatario/src/app/pages/mis-lugares/mis-lugares.page.ts` (+ `.html`), `reservas-lugar/reservas-lugar.page.ts` (+ `.html`) — mismo cambio: `pluralizar` expuesta a la plantilla igual que las demás funciones de formato.
  - `app-cliente/lib/widget/mapa_lugares.dart` — el marcador pasó de una sola pastilla a una `Column` (pastilla de precio arriba, círculo con `Icons.home` abajo); se agregó un punto de anclaje (`alignment`) calculado para que el círculo, no el centro de toda la columna, quede exactamente sobre la coordenada del lugar.
  - `app-cliente/lib/widget/barra_resumen_mapa.dart` (nuevo) — tarjeta flotante sobre el mapa con ciudad, huéspedes y fechas de la búsqueda actual (lee `BusquedaProvider` de solo lectura); tocarla vuelve a la pantalla de búsqueda (`Navigator.pop`).
  - `app-cliente/lib/screen/resultados_screen.dart` — en la vista de mapa, `MapaLugares` y `BarraResumenMapa` se apilan con `Stack`+`Positioned`; el botón flotante de alternar vista pasa a fondo oscuro cuando ya está en el mapa.
  - `docs/diseño-stitch/` (nuevo, 7 archivos `code.html` + `DESIGN.md` de la paleta) — solo referencia visual, no se ejecutan ni se empaquetan con ninguna app.
- **Flujo de datos**: no cambió ningún flujo de pantalla → provider/servicio → API; `pluralizar()` y `formatearFechaCorta()` son funciones puras de formato, igual que `formatearPrecio()`/`formatearFecha()` ya existentes, y `BarraResumenMapa` solo lee datos que `BusquedaProvider` ya tenía guardados desde la búsqueda.
- **Conceptos clave**:
  - **Una función de formato en vez de un ternario repetido**: antes cada pantalla escribía su propio `cantidad == 1 ? singular : plural` (o se olvidaba de hacerlo, que fue el bug); `pluralizar()` centraliza esa regla una vez por app, igual que ya pasaba con `formatearPrecio()`.
  - **`alignment` de un `Marker` de `flutter_map`**: por defecto, un marcador se centra sobre su punto geográfico usando el centro de todo su contenido (ancho × alto). Si el contenido tiene dos partes de alturas distintas (pastilla + círculo), hay que indicarle explícitamente qué fracción vertical del widget corresponde a la coordenada real (acá, el centro del círculo), con un `Alignment` calculado a partir de las medidas fijas de cada parte.
  - **`Stack` + `Positioned` + `SafeArea`**: la barra de resumen flota sobre el mapa sin ocupar espacio propio en el árbol de widgets (`Stack` superpone en vez de apilar en columna); `SafeArea(bottom: false)` evita que la barra quede debajo de la muesca/cámara del celular, sin agregar espacio abajo (donde ya está el botón flotante).
- **Decisiones y por qué**:
  - El cambio de pluralización se hizo en las dos apps a la vez, aunque el usuario reportó el síntoma en una sola pantalla: una vez identificado el patrón (`'$n singular'` sin revisar el plural), se buscó en todas las pantallas de ambas apps para no dejar el mismo defecto a medias.
  - `BarraResumenMapa` solo se agregó en la vista de mapa del cliente, no en la de lista: en la lista, la `AppBar` ya muestra la ciudad y la cantidad de resultados (RC-09, Fase E1); en el mapa ese título no es visible porque el mapa ocupa toda la pantalla.
- **Preguntas probables del docente (rediseño y Android)**:
  1. *¿Por qué el marcador del mapa ahora tiene dos partes (pastilla y círculo) en vez de una sola?* Para que quede claro cuál es el punto exacto del lugar en el mapa (el círculo) y, al mismo tiempo, destacar el precio sin tapar ese punto; antes la pastilla sola no marcaba ninguna coordenada precisa.
  2. *¿De dónde salió la idea de la barra flotante sobre el mapa?* Del diseño de referencia de Stitch `mapa_de_alojamientos_santa_cruz` (`docs/diseño-stitch/`), adaptado a los datos reales que ya tenía `BusquedaProvider` (no se inventó ningún dato nuevo).
  3. *¿Por qué `pluralizar()` recibe el singular y el plural como texto en vez de agregar una "s" automáticamente?* Porque en español el plural no siempre es "agregar s" (`habitación` → `habitaciones`) y porque así es una función genérica reutilizable para cualquier palabra, no una regla gramatical completa.
  4. *¿Los diseños de Stitch se ejecutan en algún lado?* No: `docs/diseño-stitch/` son archivos HTML sueltos, solo para mirarlos como referencia visual al escribir los widgets de Flutter/Ionic; nunca se importaron ni se copiaron literalmente (ver la tabla de qué se tomó y qué se dejó fuera, Fase E2).
  5. *¿Por qué la app arrendatario necesitó agregar Android con Capacitor si el enunciado solo pide una app Ionic?* Porque Ionic genera una app web que Capacitor empaqueta como app nativa sin cambiar el código Angular; se agregó para poder probar y defender la app corriendo en un emulador Android igual que la app cliente (Flutter), no porque el enunciado lo exigiera.
- **Ejercicio para hacer a mano**: en `conversiones.dart`/`formato.ts`, agregar a `pluralizar()` un tercer caso para la cantidad `0` (por ejemplo, devolver "sin baños" en vez de "0 baños"), sin cambiar la firma que ya usan las pantallas.

### Fase E3 — Cierre de la fase

- **Qué se hizo**: cierre de la Fase E (mejora estética). Se verificó que las dos apps siguen compilando sin errores (`flutter analyze`: sin advertencias; `npm run build`: sin errores), se recorrieron los 35 requisitos de `docs/REQUISITOS.md` corrigiendo la columna "Dónde se cumple" donde la Fase E movió la UI a un widget nuevo (RC-09 el botón de mapa/lista, RC-12 las características del detalle, RC-13 el botón "Reservar"), se regeneró `docs/contexto_defensa.txt` completo (rutas, rangos de línea y fragmentos actualizados, más secciones nuevas de tema/paleta, widgets de la Fase E, Capacitor/Android, clases de `global.scss`, `pluralizar` y los diseños de Stitch), se buscó código muerto (se encontró y corrigió un solo color escrito a mano fuera de los archivos de tema: `Colors.white` en `barra_resumen_mapa.dart`, cambiado a `colorScheme.surface`) y se actualizaron las tres decisiones de `CLAUDE.md` (raíz, `app-cliente`, `app-arrendatario`) que habían quedado desactualizadas: el detalle de qué URL usa cada app según cómo corre, que la app arrendatario también corre en Android con Capacitor, y la paleta verde/dorado.
- **Archivos**:
  - `docs/REQUISITOS.md` — "Dónde se cumple" actualizado en RC-09, RC-12 y RC-13.
  - `docs/contexto_defensa.txt` — regenerado completo.
  - `CLAUDE.md`, `app-cliente/CLAUDE.md`, `app-arrendatario/CLAUDE.md` — decisiones de URL/Mockoon, Capacitor/Android y paleta.
  - `app-cliente/lib/widget/barra_resumen_mapa.dart` — único hallazgo de código muerto (color sin tema), corregido.
  - `docs/ESTUDIO.md` (este archivo) — esta entrada y la anterior ("Ajustes entre E2 y E3").
- **Conceptos clave**:
  - **Qué es un tema y por qué centraliza el estilo**: un tema es un único objeto (`ThemeData` en Flutter) o un conjunto de variables (`--ion-color-*` en Ionic) que guarda los colores, formas y tamaños de toda la app; cada widget de Material o componente de Ionic ya sabe leer esos valores por su cuenta (`FilledButton`, `Card`, `ion-button color="primary"`) sin que la pantalla tenga que pasárselos. Centralizarlo en un solo archivo por app (`tema.dart` / `variables.scss`+`global.scss`) significa que cambiar el color de marca, el radio de los bordes o el alto de los botones es una edición en un solo lugar, y se refleja automáticamente en todas las pantallas que usan ese tema — en vez de buscar y reemplazar un color en cada archivo.
  - **`ThemeData` (Flutter) frente a variables CSS de Ionic**: cumplen el mismo rol con una diferencia de lenguaje. `ThemeData` es un objeto de Dart que se construye una vez (`crearTema()`) y se pasa a `MaterialApp(theme: ...)`; cualquier widget lo lee con `Theme.of(context)`. Las variables de Ionic (`--ion-color-primary: #0b6e4f;`) son variables CSS normales definidas en `:root` (`variables.scss`); cualquier elemento HTML/componente de Ionic ya las resuelve solo, sin importar nada ni pasar ningún objeto — es el mecanismo nativo del navegador (`var(--ion-color-primary)`), no algo que Angular agregue. Por eso Leaflet (que no es Angular ni Ionic) necesita leerlas a mano con `getComputedStyle()` en vez de heredarlas automáticamente como hace un `ion-button`.
- **Decisiones y por qué**:
  - El color `Colors.white` de `barra_resumen_mapa.dart` se cambió a `colorScheme.surface` en vez de dejarlo (aunque visualmente es el mismo blanco): la regla de la Fase E es que ningún color se escriba a mano fuera de `tema.dart` y del mapa (`mapa_lugares.dart`, que tiene su propia excepción documentada en la Fase E1), y esta tarjeta no es el mapa, es un widget nuevo que se agregó encima de él.
  - No se tocó ningún endpoint, cálculo ni flujo de pantalla en todo el cierre: los únicos cambios de código de esta subfase fueron el color de `barra_resumen_mapa.dart`; el resto fue documentación (`REQUISITOS.md`, `contexto_defensa.txt`, `CLAUDE.md`, `ESTUDIO.md`).
- **Preguntas probables del docente**:
  1. *¿Dónde cambiarías el color principal de la app?* Cliente: `seedColor`/`colorMarca` en `lib/config/tema.dart`. Arrendatario: `--ion-color-primary` (y su `rgb`/`shade`/`tint`) en `src/theme/variables.scss`. En ambos casos, una sola edición que se refleja en toda la app.
  2. *¿Por qué casi ninguna pantalla tiene colores escritos a mano?* Porque tanto los widgets de Material como los componentes de Ionic ya saben pintarse solos con los valores del tema (`colorScheme`, `color="primary"`); escribir un color a mano en una pantalla rompería esa fuente única de verdad y quedaría desactualizado si el tema cambia — es justamente el defecto que se encontró y corrigió en esta subfase.
  3. *¿Qué hace `labelPlacement`?* Es un atributo de `ion-input` (sintaxis moderna de Ionic, usada en la Fase E2) que decide dónde se dibuja la etiqueta del campo: `"floating"` la pone dentro del campo y la sube cuando se escribe (login/registro); `"stacked"` la pone siempre arriba del campo, aunque esté vacío (usado en el formulario de lugar, donde conviene ver todas las etiquetas aunque el campo tenga un valor precargado al editar).
- **Ejercicio para hacer a mano**: en `app-arrendatario/src/theme/variables.scss`, calcular y agregar `--ion-color-primary-shade`/`-tint` para un color de marca distinto (por ejemplo el dorado como si fuera el primario), siguiendo la misma fórmula que ya usan `shade`/`tint` del verde actual (más oscuro/más claro en un ~10-15%).

**Prueba completa de punta a punta**: ver el mensaje de cierre de la Fase E3 en la conversación (pasos con Mockoon, por separado los pasos de la prueba cruzada con la API real).


### Fase E3 — Cierre de la fase

- **Qué se hizo**: cierre de la Fase E (mejora estética, rama `mejora-estetica`). Sin cambiar ninguna pantalla de código: se verificó que las dos apps siguen compilando sin errores, se recorrieron los 35 requisitos de `docs/REQUISITOS.md` corrigiendo la columna "Dónde se cumple" donde E1 movió el botón/widget que cumple un requisito, se regeneró `docs/contexto_defensa.txt` completo (todas las citas de línea quedaron desactualizadas desde E1/E2), se actualizaron en `CLAUDE.md` (raíz, cliente, arrendatario) las decisiones que la Fase E dejó desactualizadas (URL/Mockoon según cómo corre cada app, Capacitor/Android, paleta verde/dorado), se buscó código muerto en ambas apps (ninguno encontrado: `flutter analyze` y `ng lint --max-warnings 0` ambos limpios, sin `print`/`console.log`, sin restos de plantilla, sin colores escritos a mano fuera de `tema.dart`/`variables.scss`) y se armó la prueba completa de punta a punta.
- **Archivos**: `docs/REQUISITOS.md` (RC-09, RC-12, RC-13 actualizados), `docs/contexto_defensa.txt` (regenerado completo), `CLAUDE.md`, `app-cliente/CLAUDE.md`, `app-arrendatario/CLAUDE.md`, `docs/ESTUDIO.md` (esta entrada y la anterior).
- **Conceptos clave**:
  - **Qué es un tema y por qué centraliza el estilo**: un tema es un solo lugar (un objeto, en Flutter; un archivo de variables, en Ionic) que guarda todos los colores, formas y tamaños que una app usa, y cada widget/componente los lee de ahí en vez de tenerlos escritos adentro. Centralizarlo tiene una sola razón práctica: cambiar un color (o un radio de borde, o un alto de botón) implica tocar una línea en un solo archivo, no buscar y reemplazar en cada pantalla — y en una defensa oral, "¿dónde está definido el estilo?" tiene una sola respuesta por app.
  - **`ThemeData` (Flutter) frente a variables CSS de Ionic**: las dos resuelven el mismo problema con mecanismos distintos. `ThemeData` (`app-cliente/lib/config/tema.dart`) es un objeto Dart que se construye una vez (`crearTema()`) y se pasa a `MaterialApp(theme: ...)`; cada widget de Material (`FilledButton`, `Card`, `TextFormField`) lo lee automáticamente a través de `Theme.of(context)`, en tiempo de construcción del árbol de widgets. Las variables de Ionic (`--ion-color-primary` en `app-arrendatario/src/theme/variables.scss`) son variables CSS normales: no son un objeto de ningún lenguaje, viven en la hoja de estilos, y cualquier componente de Ionic ya sabe leerlas solo con un atributo (`color="primary"`), sin que la página importe nada. La diferencia práctica: en Flutter, si un valor no viene de un widget de Material (por ejemplo, un color en un `Icon` suelto), hay que leerlo a mano con `Theme.of(context).colorScheme` o una constante de `tema.dart`; en Ionic, si Leaflet (una librería de JavaScript puro, ajena a Angular) necesita ese mismo color, hay que "preguntarle" al navegador su valor resuelto con `getComputedStyle()` (ver `mapa-selector.component.ts`, Fase E2), porque Leaflet no entiende variables CSS.
- **Decisiones y por qué**:
  - No se tocó ninguna pantalla en esta subfase: E3 es solo verificación y documentación; si algo hubiera necesitado un cambio de código, habría sido una regresión de E1/E2 que corregir, no un punto nuevo del plan.
  - `docs/contexto_defensa.txt` se regeneró completo en vez de parchear solo las citas rotas: casi todas las líneas del documento se movieron por los cambios de E0–E2 y por los dos commits posteriores (diseños de Stitch, plurales/mapa), así que corregir cita por cita habría sido más trabajo y más propenso a error que rehacerlo con el código ya estable.
- **Preguntas probables del docente**:
  1. *¿Dónde cambiarías el color principal?* En Flutter, una sola constante (`seedColor`/`colorMarca`) dentro de `crearTema()`, en `lib/config/tema.dart`. En Ionic, una sola variable (`--ion-color-primary`) en `src/theme/variables.scss`. En ningún caso hay que tocar una pantalla.
  2. *¿Por qué casi ninguna pantalla tiene colores escritos a mano?* Porque cada widget de Material o componente de Ionic ya sabe pintarse con los valores del tema (`colorScheme`, `cardTheme`, `color="primary"`); escribir un color a mano en una pantalla duplicaría ese valor y quedaría desactualizado si el tema cambia — además de romper la regla de "un solo lugar con el estilo" de `CLAUDE.md`.
  3. *¿Qué hace `labelPlacement`?* Es un atributo de `ion-input` (Ionic 7+, sintaxis moderna usada en la Fase E2) que decide dónde se dibuja la etiqueta del campo: `"floating"` la pone encima del valor cuando el campo tiene foco o contenido (y dentro, como placeholder, cuando está vacío); `"stacked"` la deja siempre fija arriba del campo. Reemplaza al patrón viejo de `ion-item` + `ion-label` por fuera del campo.
- **Ejercicio para hacer a mano**: en `tema.dart`, cambiar `colorMarca` a un azul cualquiera y correr la app: confirmar que botones, `AppBar`, campos y chips cambiaron de color sin tocar ninguna pantalla; después revertirlo al verde.

**Probado**: `flutter analyze` sin advertencias y `npm run build`/`ng lint --max-warnings 0` sin errores (ver arriba). La prueba visual completa de punta a punta en el emulador (pendiente desde el cierre de E1/E2) se hizo al cerrar esta subfase, con Mockoon para el flujo de cada app por separado y, aparte, una prueba cruzada contra la API real antes de la defensa (el flujo cruzado arrendatario→cliente no se puede verificar con Mockoon porque el mock devuelve siempre los mismos lugares de ejemplo).
