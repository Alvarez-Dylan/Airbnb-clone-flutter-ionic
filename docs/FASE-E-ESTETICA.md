# Fase E — Correcciones y mejora estética

Fase opcional, posterior a la versión funcional. Objetivo: que las dos apps se vean como un mismo producto y no como plantillas por defecto, **sin cambiar la lógica** y sin agregar nada que no se pueda explicar en la defensa.

## Antes de empezar (una sola vez)

```bash
git tag v1-funcional
git checkout -b mejora-estetica
```

`v1-funcional` es la versión que ya cumple todos los requisitos. Si algo de esta fase sale mal o no alcanza el tiempo, se vuelve con `git checkout main` y se defiende esa versión.

## Reglas de esta fase (además de las de `CLAUDE.md`)

1. **Solo cambios visuales.** No se tocan `service/`, `repository/`, `model/`, `services/`, `models/`, `guards/` ni `utils/` (salvo lo indicado en E0). Mismos endpoints, mismos cálculos y mismo flujo de pantallas.
2. **Sin dependencias nuevas**: nada de `google_fonts`, paquetes de animación, Tailwind ni librerías de íconos extra. Alcanza con Material (Flutter) e `ionicons` (Ionic).
3. **El estilo vive en un solo lugar por app**: Flutter `lib/config/tema.dart`; Ionic `src/theme/variables.scss` y `src/global.scss`. Las pantallas usan el tema (`Theme.of(context)`, `color="primary"`) en vez de colores escritos a mano. Así, en la defensa la explicación es una sola: "todo el estilo sale de este archivo".
4. **Se mantienen los textos que pide el enunciado** (botones de ambas apps): "Búsqueda avanzada", "Ver reservas", "Vista de mapa", "Vista de lista", "Reservar" y "Confirmar reserva". También se mantienen todos los datos que cada requisito pide mostrar en cada pantalla.
5. **Solo modo claro** en las dos apps: una sola paleta para probar y explicar.
6. Al cerrar cada subfase: `flutter analyze` / `npm run build` sin errores, entrada corta en `docs/ESTUDIO.md` y propuesta de commit.

## Identidad visual común (las dos apps)

| Elemento | Valor |
|---|---|
| Color de marca (primario) | `#E8505B` (coral) |
| Texto principal | `#222222` |
| Texto secundario | `#717171` |
| Fondo de pantalla | `#F7F7F7` |
| Superficie (tarjetas) | `#FFFFFF` |
| Bordes redondeados | 12 en campos y botones; 16 en tarjetas y fotos |
| Espaciado base | múltiplos de 8 (8, 16, 24) |
| Alto de botón principal | 48 |
| Ícono de la marca | casa (`Icons.home_work_rounded` / `home-outline`) + texto "bnb" |

---

## E0 — Correcciones previas (ambas apps)

No son estéticas, pero se notan al usarlas y conviene arreglarlas primero.

**Prompt**
```text
Ejecuta la subfase E0 de docs/FASE-E-ESTETICA.md siguiendo CLAUDE.md. Antes de escribir código, muéstrame el plan y la lista de archivos a tocar, y espera mi OK. Para el punto 1, pregúntame qué URL usar.
```

**Hacer**
1. **URL de la API coherente.** Hoy el cliente apunta a `http://10.0.2.2:3001/api` (Mockoon), el arrendatario en desarrollo a `http://localhost:3001/api` y en producción a `https://api.airbnbmob2.online/api`. Preguntarme cuál usar para la defensa y dejar las dos apps apuntando a la misma API (sin cambiar nada más).
2. **Botón de volver en Ionic.** `lugar-form` y `reservas-lugar` no tienen cómo volver en el navegador. Agregar `<ion-buttons slot="start"><ion-back-button defaultHref="..."></ion-back-button></ion-buttons>` en el header (`/mis-lugares` en el formulario; `/lugar/:id` en reservas). Importar `IonBackButton`.
3. **Tildes y eñes en todo texto visible** de ambas apps: "Iniciar sesión", "Contraseña", "Búsqueda avanzada", "huéspedes", "baños", "Anfitrión", "Sí", "vehículos", "Descripción", "ubicación", "Teléfono", "Todavía", "aún", y los mensajes de validación y error. **No** cambiar identificadores de código ni claves JSON (`cantBanios`, `sesionCliente`, `busqueda_provider.dart` se quedan igual). Reemplazar "Todavía no tenes lugares publicados" por "Todavía no tienes lugares publicados".
4. **Foto rota en el formulario del arrendatario**: las fotos existentes de `lugar-form` no tienen `(error)`, y si una no carga se ve el texto alternativo. Usar el mismo manejo que en `mis-lugares`.
5. **Atribución del mapa en Flutter**: el `TileLayer` de OpenStreetMap exige mostrar "© OpenStreetMap contributors". Agregar `SimpleAttributionWidget` (o `RichAttributionWidget`) de `flutter_map`, según la versión instalada.
6. **Fecha de salida**: en `busqueda_screen.dart` y `busqueda_avanzada_screen.dart`, el selector de salida debe empezar el día siguiente a la llegada (`firstDate` e `initialDate`) cuando ya hay llegada elegida. La validación actual se mantiene.

**Listo cuando**: no queda ningún texto visible sin tilde ni eñe, se puede volver desde el formulario y desde reservas, y las dos apps funcionan contra la misma API.

---

## E1 — App cliente (Flutter)

**Prompt**
```text
Ejecuta la subfase E1 de docs/FASE-E-ESTETICA.md siguiendo CLAUDE.md y app-cliente/CLAUDE.md. Revisa la versión de Flutter instalada antes de usar APIs de tema. Muéstrame el plan y espera mi OK. Hazlo en este orden y avísame después de cada punto para que lo pruebe en el emulador.
```

**Hacer (en orden)**
1. **`lib/config/tema.dart`** con una función `crearTema()` que devuelve `ThemeData`:
   - `colorScheme: ColorScheme.fromSeed(seedColor: colorMarca, dynamicSchemeVariant: DynamicSchemeVariant.fidelity)` (fidelity mantiene el coral parecido al elegido);
   - `scaffoldBackgroundColor` `#F7F7F7`;
   - `appBarTheme`: fondo blanco, sin sombra, título a la izquierda;
   - `inputDecorationTheme`: relleno blanco, `OutlineInputBorder` con radio 12;
   - `filledButtonTheme` y `outlinedButtonTheme`: alto mínimo 48, radio 12;
   - `cardTheme`: blanco, radio 16, elevación baja, `clipBehavior: Clip.antiAlias`;
   - `chipTheme` con fondo suave.
   En `main.dart` solo se agrega `theme: crearTema()`.
2. **Login y registro**: encabezado con ícono de casa en un círculo del color de marca, "bnb" grande y un subtítulo ("Encuentra dónde quedarte"); campos con `prefixIcon` (email, candado, persona, teléfono); botón principal `FilledButton`. Contenido centrado y con scroll (`SingleChildScrollView`) para que el teclado no tape los campos.
3. **Búsqueda**: saludo "Hola, {nombre}" con el nombre del `AuthProvider`; formulario dentro de una `Card`; llegada y salida lado a lado en un `Row` como campos con ícono de calendario; huéspedes con los mismos botones − / + dentro de un contenedor con borde; "Buscar" como `FilledButton.icon`; "Búsqueda avanzada" y "Ver reservas" como `OutlinedButton.icon`.
4. **`LugarCard`** al estilo de un listado de alojamientos: foto arriba con `AspectRatio(16/9)` y esquinas redondeadas; debajo, nombre en negrita, descripción en 2 líneas gris, y una fila con ícono de personas + "N huéspedes" a la izquierda y "$us X noche" en negrita a la derecha. Sigue mostrando los mismos 5 datos que pide RC-07.
5. **Resultados**: el botón "Vista de mapa" / "Vista de lista" pasa a ser un `FloatingActionButton.extended` centrado abajo (`FloatingActionButtonLocation.centerFloat`), con ícono de mapa o lista. El título de la `AppBar` muestra la ciudad y la cantidad de resultados.
6. **Marcadores del mapa** como "pastillas" de precio: fondo blanco, borde redondeado, sombra suave y texto en negrita (sin el ícono de pin debajo).
7. **Detalle**: galería con esquinas redondeadas y miniaturas con borde del color de marca en la seleccionada; nombre como título; ciudad y "Anfitrión: X" con un `CircleAvatar` con su inicial; características en un `Wrap` de `Chip` con ícono (personas, camas, baños, habitaciones, wifi sí/no, parqueo); descripción con subtítulo "Acerca de este lugar"; barra inferior fija (`bottomNavigationBar`) con "$us X noche" a la izquierda y el botón "Reservar" a la derecha.
8. **Confirmar reserva**: `Card` de resumen con miniatura, nombre del lugar, fechas (dd/MM/yyyy) y huéspedes; `Card` de desglose (mismas 4 líneas actuales); total en negrita y más grande; botón "Confirmar reserva" fijo abajo.
9. **Mis reservas (`ReservaCard`)**: foto de 80×80 redondeada a la izquierda; nombre del lugar en negrita; fila con ícono de calendario y fechas; "N noches · Anfitrión: X"; total en negrita a la derecha.
10. **`VistaEstado`**: ícono grande gris arriba del mensaje (`Icons.search_off` para vacío, `Icons.wifi_off` o `Icons.error_outline` para error), mediante un parámetro opcional `icono`.

**Listo cuando**: todas las pantallas usan el coral como color principal, ninguna tiene colores escritos a mano fuera de `tema.dart` y del mapa, y el flujo completo (login → buscar → lista/mapa → detalle → reservar → mis reservas) funciona igual que antes.

---

## E2 — App arrendatario (Ionic + Angular)

**Prompt**
```text
Ejecuta la subfase E2 de docs/FASE-E-ESTETICA.md siguiendo CLAUDE.md y app-arrendatario/CLAUDE.md. Muéstrame el plan y espera mi OK. Hazlo en este orden y avísame después de cada punto para que lo pruebe con ionic serve.
```

**Hacer (en orden)**
1. **Tema** en `src/theme/variables.scss`: `--ion-color-primary` y sus variantes (`-rgb`, `-contrast`, `-shade`, `-tint`) con el coral `#E8505B`; `--ion-background-color` `#F7F7F7`; `--ion-text-color` `#222222`. En `global.scss`: comentar el import de `dark.system.css` (solo modo claro) y agregar dos clases reutilizables: `.estado-vacio` (ícono grande + texto centrados) y `.foto-portada` (`object-fit: cover`, radio 16). En `index.html`: `<meta name="color-scheme" content="light">`.
2. **Login y registro**: encabezado con ícono `home-outline` en un círculo coral, "bnb" y el subtítulo "Para anfitriones"; campos con la sintaxis moderna de Ionic (`<ion-input label="Email" labelPlacement="floating" fill="outline">`) en vez de `ion-item` + `ion-label`; botón principal con `shape="round"` o radio 12.
3. **Mis lugares**: cada lugar como `ion-card` con la foto como portada (16:9), `ion-card-title` con el nombre, `ion-card-subtitle` con ícono de ubicación + ciudad, y el precio en negrita. Cerrar sesión como botón de ícono (`log-out-outline`). Estado vacío con ícono, el texto "Todavía no tienes lugares publicados" y un botón "Publicar mi primer lugar".
4. **Formulario de lugar** en secciones con `ion-list` `inset` y `ion-list-header`: **Fotos**, **Información** (nombre, descripción con `ion-textarea`, ciudad), **Capacidad** (personas y camas en una fila; baños y habitaciones en otra, con `ion-grid`/`ion-row`/`ion-col`), **Servicios** (wifi y parqueo con íconos `wifi-outline` y `car-outline`), **Precios** (noche y limpieza en una fila) y **Ubicación** (mapa con esquinas redondeadas). Fotos en una grilla de 3 columnas con esquinas redondeadas y el botón "+" del mismo tamaño que una foto. El botón "Guardar" fijo en un `ion-footer`. "Ver reservas" con ícono `calendar-outline`.
5. **Reservas del lugar**: cada reserva como `ion-card` o `ion-item` con la foto del lugar, el nombre del cliente con ícono de persona, una fila con `ion-chip` "N noches", las fechas con ícono de calendario y el total en negrita a la derecha. Estado vacío con ícono.
6. **Marcador del mapa selector** con el color de marca: `L.circleMarker` con `color` y `fillColor` coral y `fillOpacity` 0.9.

**Listo cuando**: el coral es el color principal en todas las páginas, el formulario se lee por secciones y el flujo (login → mis lugares → nuevo / editar con fotos y mapa → ver reservas → volver) funciona igual que antes.

---

## E3 — Cierre de la fase

**Prompt**
```text
Ejecuta la subfase E3 de docs/FASE-E-ESTETICA.md siguiendo CLAUDE.md. Muéstrame primero la lista de lo que vas a revisar y espera mi OK.
```

**Hacer**
- `flutter analyze` sin advertencias y `npm run build` sin errores.
- Recorrer `docs/REQUISITOS.md`: cada requisito se sigue cumpliendo; actualizar la columna "Dónde se cumple" si cambió el archivo o el widget.
- **Regenerar `docs/contexto_defensa.txt`**: ese documento cita números de línea exactos y esta fase los movió todos. Volver a verificar cada ruta, rango de líneas y fragmento contra el código actual.
- Entrada "Fase E" en `docs/ESTUDIO.md` con: qué es un tema y por qué centraliza el estilo, `ThemeData` frente a variables CSS de Ionic, y 3 preguntas probables ("¿dónde cambiarías el color principal?", "¿por qué no hay colores en las pantallas?", "¿qué hace `labelPlacement`?").
- Darme los pasos de la prueba completa de punta a punta en ambas apps.
- Proponer el mensaje de commit y recordarme hacer merge a `main` solo si todo funciona.

**Listo cuando**: la prueba completa funciona, `contexto_defensa.txt` coincide línea por línea con el código y puedo explicar el tema de cada app sin mirar.
