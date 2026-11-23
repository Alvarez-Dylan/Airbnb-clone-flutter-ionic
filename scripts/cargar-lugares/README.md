# Cargar lugares de prueba

Herramienta de datos para cargar 4 lugares de prueba (con sus fotos) directamente en
la API, sin crearlos a mano desde la app del arrendatario. No forma parte de
`app-cliente/` ni `app-arrendatario/`.

## Preparación

1. Copiar `credenciales.ejemplo.json` a `credenciales.json` (este último está en
   `.gitignore`, nunca se sube) y completarlo con una cuenta de arrendatario que ya
   exista en la API:

   ```json
   {
     "apiUrl": "http://10.0.2.2:3001/api",
     "email": "arr.prueba.dylan@test.com",
     "password": "prueba123"
   }
   ```

   `apiUrl` **debe incluir el `/api` final** (igual que `api_config.dart` /
   `environment.ts` de las dos apps). Ejemplos válidos:
   - Mock local: `http://localhost:3001/api` o `http://10.0.2.2:3001/api`
   - API real: `https://api.airbnbmob2.online/api`

2. Las fotos se leen desde `contexto/fotos-mock/` (no se tocan, no se copian). Si
   falta alguna de las 16, el script avisa cuál.

## Uso (PowerShell, desde cualquier carpeta)

Validar que `lugares.json` y las 16 fotos estén bien, sin tocar la API:

```powershell
node "scripts\cargar-lugares\cargar.mjs" --probar
```

Cargar los lugares de verdad (inicia sesión, crea los que falten y sube sus fotos):

```powershell
node "scripts\cargar-lugares\cargar.mjs"
```

Si `apiUrl` apunta al mock local (`localhost`, `127.0.0.1` o `10.0.2.2`), el script
avisa que el mock no guarda datos entre reinicios y termina sin hacer ninguna
petición.

## Cómo decide qué crear

Antes de crear nada, pide los lugares actuales del arrendatario
(`GET lugares/arrendatario/{id}`) y compara por `nombre`:

- Si el nombre ya existe, **lo salta** (para poder correr el script varias veces
  sin duplicar). Si ese lugar existente tiene menos fotos que las 4 de
  `lugares.json`, el resumen lo marca como "incompleto" — el script no vuelve a
  subir fotos de un lugar que ya existe, aunque le falten.
- Si no existe, lo crea (`POST lugares`) y sube sus 4 fotos en orden, una petición
  por foto (`POST lugares/{id}/foto`, campo `foto`). Cada foto se manda con un
  nombre sin tildes ni espacios (`lugarN-M.jpeg`, según su posición en
  `lugares.json`), tipo `image/jpeg`.

Una foto que no existe, pesa más de 2 MB, o que la API rechaza, se avisa en la
consola y se sigue con la siguiente — no frena la carga del resto del lugar.
