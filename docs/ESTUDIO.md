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
