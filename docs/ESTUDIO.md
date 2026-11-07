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

Se completa en la Fase final:
- Recorrido de 5 minutos por cada app: qué pantalla llama a qué y por qué.
- Las 10 preguntas más probables del docente, con respuesta corta basada en el código.
- Las 3 partes más difíciles del proyecto (fotos, mapa selector, cálculo de reserva) explicadas paso a paso.

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
