# Contrato de la API

> **Estado: VERIFICADO** (Fase 0, 2026-11-05). Confirmado ejecutando el procedimiento completo contra `https://aspect-emotions-johnston-mls.trycloudflare.com/api`. Backend Laravel. La API es compartida por todo el curso: las búsquedas devuelven lugares de otros alumnos (se ven ejemplos reales de eso abajo). Los ejemplos de prueba de esta fase quedaron identificados como "...Dylan" o "...Prueba".
>
> ⚠ La URL es un túnel temporal (Cloudflare): si deja de responder, pedir la URL nueva y cambiarla solo en `app-cliente/lib/config/api_config.dart` y en `app-arrendatario/src/environments/environment.ts` / `environment.prod.ts`.

## Datos generales

- URL base: `https://aspect-emotions-johnston-mls.trycloudflare.com/api/`
- Headers en peticiones JSON: `Accept: application/json` y `Content-Type: application/json`.
- Backend Laravel confirmado. Importante: **todos los errores (validación, no encontrado, credenciales) responden HTTP 404**, nunca 422 ni 401/403. Hay que distinguir el tipo de error por la FORMA del cuerpo, no por el código HTTP:
  - Validación (faltó un campo, tipo incorrecto): `{"campo": ["mensaje de error", ...], ...}` — un objeto con una clave por campo, cada una con un arreglo de strings.
  - Error de negocio (no encontrado, credenciales): `{"message": "texto en español"}` — un objeto con una sola clave `message`.
  - Las dos apps deben mirar la forma del cuerpo para decidir qué mensaje mostrar (si hay `message`, mostrarlo tal cual; si hay otras claves, tomar el primer arreglo).
- CORS: abierto (`Access-Control-Allow-Origin: *`). No afecta a la app Ionic en el navegador.
- `latitud` y `longitud` deben enviarse **como texto** (string), no como número: si se mandan como número la API responde error de validación (404 con `{"latitud": ["The latitud must be a string."]}`).
- Los precios (`precioNoche`, `costoLimpieza`, `precioNoches`, `precioLimpieza`, `precioServicio`, `precioTotal`) vuelven de la API como **texto** con 2 decimales (ej. `"30.00"`) en casi todas las respuestas, excepto en la respuesta inmediata de crear/editar un lugar (`POST`/`PUT /lugares`), donde vuelven como **número** (ej. `30`). Los modelos deben tolerar ambos casos (igual que ya preveía `CLAUDE.md`).

## ⚠ Hallazgo importante: las fotos no usan la URL que manda la API

`POST /lugares/{id}/foto` y cualquier respuesta que incluya `fotos` devuelven cada foto como `{"id", "url", "lugar_id", "created_at", "updated_at"}`, pero el campo `url` viene **hardcodeado al dominio viejo del PDF** (`https://bnb-backend.loca.lt/fotos/archivo.jpg`), que está **caído** (probado: 503 "Tunnel Unavailable"). El archivo sí existe y responde 200 si se arma la URL con el dominio del túnel ACTUAL + la misma ruta `/fotos/archivo.jpg`.

**Consecuencia para `urlFoto()` en ambas apps**: nunca usar el campo `url` tal cual. Hay que tomar solo el nombre de archivo (lo último después de la última `/`) y armar la URL con la base actual: `` `${apiBaseSinApi}/fotos/${nombreArchivo}` `` (la base sin `/api`, porque `/fotos/` cuelga de la raíz, no de `/api/fotos/`). Esto hay que revisarlo de nuevo si la URL del túnel cambia, porque el problema es justamente que el backend no sabe su propia URL pública actual.

## Endpoints (confirmados)

Rutas relativas a `https://aspect-emotions-johnston-mls.trycloudflare.com/api`. Ninguna ruta del PDF dio 404 por no existir; las alternativas de Postman (`/api/lugar`, `/api/arrendatario`, `/api/users/login`) **no se probaron porque no hicieron falta** — las del PDF funcionan.

| # | Método | Ruta | Lo usa | Notas |
|---|---|---|---|---|
| 1 | POST | `cliente/registro` | Cliente | body: `nombrecompleto`, `email`, `password`, `telefono`. Devuelve el usuario creado (incluye `password` hasheada, ignorar ese campo) |
| 2 | POST | `cliente/login` | Cliente | body: `email`, `password`. Devuelve el usuario directo, sin token |
| 3 | POST | `arrendatario/registro` | Arrendatario | igual forma que cliente |
| 4 | POST | `arrendatario/login` | Arrendatario | igual forma que cliente |
| 5 | POST | `lugares/search` | Cliente | body: `{"search": texto}`. Busca por coincidencia parcial en **ciudad** (y aparentemente otros campos de texto); ver detalle abajo |
| 6 | POST | `lugares/advancedsearch` | Cliente | ver semántica detallada abajo (clave: campos sin filtro se **omiten**, no se mandan en `0`) |
| 7 | GET | `lugares/{id}` | Ambas | trae `arrendatario` (objeto completo) y `fotos` (arreglo) anidados |
| 8 | GET | `lugares/arrendatario/{id}` | Arrendatario | arreglo de lugares, cada uno con `fotos` anidado (sin `arrendatario` anidado, no hace falta) |
| 9 | POST | `lugares` | Arrendatario | crear. Devuelve el lugar creado con su `id`. **No sirve para editar** (ver más abajo) |
| 10 | POST | `lugares/{id}/foto` | Arrendatario | `multipart/form-data`, campo `foto`. Devuelve el lugar completo actualizado (con `fotos`) |
| 11 | GET | `reservas/cliente/{id}` | Cliente | arreglo de reservas, cada una con `cliente` (objeto) y `lugar` (**arreglo** de 1 elemento, no objeto — ver nota) |
| 12 | POST | `reservas` | Cliente | guardar. Devuelve la reserva creada con su `id` |
| 13 | GET | `reservas/lugar/{id}` | Arrendatario | **devuelve el lugar completo**, con un arreglo `reservas` adentro (cada reserva trae `cliente` anidado) — no es un arreglo plano de reservas |
| — | PUT | `lugares/{id}` | Arrendatario | **esta es la ruta real para editar** (no está en el PDF, se encontró probando). Mismo body que crear, sin `arrendatario_id` obligatorio si no cambia. Devuelve el lugar actualizado, mismo `id` |

### ⚠ Hallazgo importante: editar un lugar es `PUT`, no `POST` con `id`

El PDF no menciona ningún endpoint de edición, y la colección de Postman sugería mandar `POST /lugares` con un `"id"` adentro del body para editar. **Se probó y no funciona así**: `POST /lugares` con `id` **ignora el id y crea un lugar nuevo** (duplicado, con otro id autogenerado). Se probó `PATCH /lugares/{id}` → 404 (ruta no existe). Se probó `PUT /lugares/{id}` → **200, actualiza el lugar existente correctamente** (mismo `id`, `updated_at` cambia, no se duplica).

**Acción pendiente para `CLAUDE.md` / `PLAN.md` (Fase A5)**: `LugaresService.guardarLugar()` en la app arrendatario debe usar `POST lugares` para crear y `PUT lugares/{id}` para editar (no reusar el mismo POST con id adentro). Falta tu OK para actualizar esos documentos — lo dejo marcado aquí y te lo resumo al final.

## Cuerpos de petición confirmados

### Registro (cliente y arrendatario)

```json
{ "nombrecompleto": "Nombre Apellido", "email": "correo@dominio.com", "password": "prueba123", "telefono": "70000000" }
```

Confirmado: misma forma para cliente y arrendatario, clave `nombrecompleto` en minúscula sin tilde.

### Login (cliente y arrendatario)

```json
{ "email": "correo@dominio.com", "password": "prueba123" }
```

Devuelve el usuario directo (sin `data` envolviendo, sin token). Password incorrecta → HTTP 401 (única petición que NO respondió 404 en los errores probados) con `{"message": "Contraseña incorrecta"}`. Email que no existe → HTTP 404 con `{"message": "Usuario no encontrado"}`.

### Búsqueda simple

```json
{ "search": "Santa Cruz" }
```

Confirmado: busca por **ciudad**, con coincidencia parcial (ej. `"Santa Cruz"` también encuentra lugares en `"Santa Cruz de la Sierra"`). Probado que **no** busca por nombre del lugar ni por descripción (devolvió `[]` buscando el nombre exacto de un lugar de prueba). Devuelve un arreglo de lugares, cada uno con `arrendatario` y `fotos` anidados.

### Búsqueda avanzada

```json
{
  "ciudad": "Santa Cruz",
  "descripcion": "plaza",
  "cantPersonas": 4,
  "cantCamas": 4,
  "cantBanios": 2,
  "cantHabitaciones": 3,
  "tieneWifi": 1,
  "cantVehiculosParqueo": 1,
  "precioNoche": 30
}
```

Confirmado con pruebas cruzadas:

- `ciudad` es **obligatorio** (sin él, error de validación) y hace coincidencia **exacta** (a diferencia de la búsqueda simple).
- `descripcion` hace coincidencia **parcial** ("plaza" encontró un lugar cuya descripción contiene "...cerca de la plaza...").
- `cantPersonas`, `cantCamas`, `cantBanios`, `cantHabitaciones`, `tieneWifi`, `cantVehiculosParqueo`, `precioNoche` son todos de coincidencia **EXACTA**, no mínimo ni máximo (probado subiendo y bajando `precioNoche` alrededor del valor real: ambos casos dieron 0 resultados, solo el valor exacto encontró el lugar).
- **Un campo "sin filtro" se debe OMITIR del body, nunca mandarlo en `0`**: mandar `"cantCamas": 0` filtra literalmente por lugares con 0 camas (casi siempre 0 resultados). Se confirmó que omitiendo las claves opcionales el filtro deja de aplicarse.
- La API acepta además `nombre` y `costoLimpieza` como filtros (no documentados en el PDF). No es necesario usarlos para cumplir el enunciado («todos los campos del lugar, menos foto y anfitrión» ya cubre personas/camas/baños/habitaciones/wifi/parqueo/precio/ciudad/descripción), así que **no se usan** para no inventar comportamiento sobre algo no pedido.

**Consecuencia para la pantalla de búsqueda avanzada (Fase C7)**: el body que arma la app debe incluir solo las claves de los campos que el usuario efectivamente llenó (incluida `ciudad`, que además es obligatoria igual que en la búsqueda simple). No usar `0` como valor por defecto de "no filtrar".

### Guardar lugar (crear)

```json
{
  "nombre": "Depto prueba Dylan",
  "descripcion": "Lugar de prueba del proyecto",
  "cantPersonas": 4,
  "cantCamas": 2,
  "cantBanios": 1,
  "cantHabitaciones": 2,
  "tieneWifi": 1,
  "cantVehiculosParqueo": 1,
  "precioNoche": 30.00,
  "costoLimpieza": 5.00,
  "ciudad": "Santa Cruz",
  "latitud": "-17.7828703",
  "longitud": "-63.180618",
  "arrendatario_id": 12
}
```

`POST /lugares` con este body → 200, devuelve el lugar creado completo con su `id` nuevo (hace falta ese id para subirle fotos). `latitud`/`longitud` **deben ir como string** (ver nota general arriba).

### Editar lugar

`PUT /lugares/{id}` con el mismo body (sin `id` adentro, el id va en la URL) → 200, devuelve el lugar actualizado. Ver el hallazgo detallado más arriba.

### Subir foto

`multipart/form-data` con un campo `foto` de tipo archivo, una petición por foto. Confirmado con un `.jpg` real: `POST /lugares/{id}/foto` → 200, devuelve el **lugar completo actualizado** (no solo la foto), con `fotos` incluyendo la nueva. Ver el hallazgo sobre el dominio del campo `url` más arriba.

### Guardar reserva

```json
{
  "lugar_id": 11,
  "cliente_id": 14,
  "fechaInicio": "2026-12-01",
  "fechaFin": "2026-12-05",
  "precioNoches": "120.00",
  "precioLimpieza": "5.00",
  "precioServicio": "12.00",
  "precioTotal": "137.00"
}
```

Confirmado, `POST /reservas` → 200, devuelve la reserva creada con su `id`. `precioNoches` es el subtotal de todas las noches (no el precio de una noche).

## Respuestas reales (confirmadas en la Fase 0)

Resumen aquí; respuesta completa en `docs/api-ejemplos/`.

| # | Endpoint | Código OK | Forma de la respuesta (campos principales) | Ejemplo |
|---|---|---|---|---|
| 1 | registro cliente | 200 | objeto del usuario creado (incluye `password` hasheada, `id`) | `01-registro-cliente.json` |
| 2 | login cliente | 200 | objeto del usuario, sin token | `02-login-cliente.json` |
| 3 | registro arrendatario | 200 | igual que cliente | `03-registro-arrendatario.json` |
| 4 | login arrendatario | 200 | igual que cliente | `04-login-arrendatario.json` |
| 5 | búsqueda simple | 200 | arreglo de lugares, cada uno con `arrendatario` y `fotos` anidados | `05-busqueda.json` |
| 6 | búsqueda avanzada | 200 | igual forma que búsqueda simple | `06-busqueda-avanzada.json` |
| 7 | lugar por id | 200 | lugar con `arrendatario` (objeto) y `fotos` (arreglo) anidados | `07-lugar.json` |
| 8 | lugares de arrendatario | 200 | arreglo de lugares con `fotos` anidado (sin `arrendatario`) | `08-lugares-arrendatario.json` |
| 9 | guardar lugar (crear) | 200 | lugar creado, precios como número (no string) | `09-guardar-lugar.json` |
| 9b | editar lugar (`PUT`) | 200 | lugar actualizado, mismo `id` | `09b-editar-lugar.json` (ojo: el nombre del archivo quedó del intento viejo con `POST`+id, que DUPLICÓ; el `PUT` se probó aparte, ver sección de hallazgos) |
| 10 | subir foto | 200 | lugar completo con `fotos` actualizado | `10-subir-foto.json` |
| 11 | reservas de cliente | 200 | arreglo de reservas, cada una con `cliente` (objeto) y `lugar` (**arreglo** de 1) anidados | `11-reservas-cliente.json` |
| 12 | guardar reserva | 200 | reserva creada con `id` | `12-guardar-reserva.json` |
| 13 | reservas de lugar | 200 | **el lugar completo**, con `reservas` (arreglo, cada una con `cliente` anidado) adentro | `13-reservas-lugar.json` |
| — | login con contraseña incorrecta | 401 | `{"message": "Contraseña incorrecta"}` | `14-login-fallido.json` |

## Respuestas a las preguntas de la Fase 0

1. **Login**: devuelve el objeto del usuario directo (incluye `id`, `nombrecompleto`, `email`, `telefono`, y la `password` hasheada que se debe ignorar). No devuelve token; no hace falta mandar nada extra en las demás peticiones.
2. **Login fallido**: contraseña incorrecta → HTTP 401, `{"message": "Contraseña incorrecta"}`. Email inexistente → HTTP 404, `{"message": "Usuario no encontrado"}`.
3. **¿Directas o envueltas?**: directas, sin `{"data": ...}`.
4. **Fotos**: arreglo de **objetos** `{"id", "url", "lugar_id", "created_at", "updated_at"}` (no arreglo de strings). El campo `url` es absoluto pero apunta a un dominio viejo y caído — hay que reconstruirlo con la base actual (ver hallazgo arriba).
5. **`GET lugares/{id}` trae el anfitrión**: sí, en `arrendatario.nombrecompleto` (objeto completo anidado).
6. **`POST lugares` devuelve el id**: sí, en el campo `id` de la respuesta.
7. **Editar**: `POST lugares` con `id` **no** actualiza, duplica. La ruta real es `PUT lugares/{id}`.
8. **`GET reservas/lugar/{id}` trae nombre del cliente y datos del lugar**: la respuesta ES el lugar, con los datos del lugar directos y un arreglo `reservas` donde cada una trae `cliente.nombrecompleto`.
9. **`GET reservas/cliente/{id}` trae datos del lugar**: sí, cada reserva trae `lugar` (foto, nombre, anfitrión incluidos) — **pero como arreglo de 1 elemento**, no como objeto. No hace falta pedir `GET lugares/{id}` aparte.
10. **`lugares/search` busca solo por ciudad o también nombre/descripción**: solo por ciudad (coincidencia parcial). Nombre y descripción no matchean en la búsqueda simple.
11. **Tipos**: `tieneWifi` llega como `0`/`1` (número). Precios llegan como texto `"30.00"` en casi todas las respuestas, excepto como número en la respuesta inmediata de crear/editar lugar. `latitud`/`longitud` llegan (y se mandan) como texto.
12. **CORS**: sí responde `Access-Control-Allow-Origin: *`. No afecta a la app Ionic.

## Datos de prueba creados en la Fase 0

- Arrendatario: `arr.prueba.dylan@test.com` / `prueba123`, id `12`.
- Cliente: `cli.prueba.dylan@test.com` / `prueba123`, id `14`.
- Lugar: "Depto prueba Dylan (PUT editado)", id `11`, ciudad Santa Cruz, con 1 foto de prueba.
- Reserva de prueba: id `7`, lugar `11`, cliente `14`, 2026-12-01 a 2026-12-05, total `137.00`.
- (Dato colateral del hallazgo de edición): quedó un lugar duplicado id `12` ("Depto prueba Dylan (editado)"), sin fotos, generado al probar que `POST` con `id` no actualiza. Se deja así porque no hay endpoint para borrar lugares y es dato de prueba identificable.
