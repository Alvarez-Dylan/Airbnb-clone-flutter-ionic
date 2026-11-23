// Carga los 4 lugares de prueba de lugares.json (con sus fotos) directamente en
// la API, para no tener que crearlos a mano desde la app del arrendatario.
// Herramienta de datos: no forma parte de app-cliente/ ni app-arrendatario/.
//
// Uso (ver README.md para el detalle):
//   node cargar.mjs --probar   -> solo valida lugares.json y las 16 fotos
//   node cargar.mjs            -> inicia sesion y carga de verdad contra la API
import { readFile, readdir, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import path from 'node:path';

const dirScript = path.dirname(fileURLToPath(import.meta.url));
const rutaLugares = path.join(dirScript, 'lugares.json');
const rutaCredenciales = path.join(dirScript, 'credenciales.json');
const dirFotos = path.join(dirScript, '..', '..', 'contexto', 'fotos-mock');

const PESO_MAXIMO = 2 * 1024 * 1024; // 2 MB
const FOTOS_POR_LUGAR = 4;
const soloProbar = process.argv.includes('--probar');

// Hostnames del mock local (Mockoon): no guarda datos entre reinicios, asi
// que cargar lugares de prueba ahi no sirve para nada persistente.
const HOSTS_MOCK = new Set(['localhost', '127.0.0.1', '10.0.2.2']);

async function cargarLugares() {
  const texto = await readFile(rutaLugares, 'utf-8');
  return JSON.parse(texto);
}

async function cargarCredenciales() {
  let texto;
  try {
    texto = await readFile(rutaCredenciales, 'utf-8');
  } catch {
    throw new Error(
      `No se encontro credenciales.json en ${dirScript}. Copia credenciales.ejemplo.json a credenciales.json y completa apiUrl/email/password (ver README.md).`,
    );
  }
  return JSON.parse(texto);
}

function esApiMock(apiUrl) {
  try {
    return HOSTS_MOCK.has(new URL(apiUrl).hostname);
  } catch {
    return false;
  }
}

// La API responde errores como {"message": "texto"} (negocio) o
// {"campo": ["mensaje", ...]} (validacion) - nunca HTTP 422 (ver docs/API.md).
function mensajeDeError(cuerpo) {
  if (cuerpo && typeof cuerpo === 'object') {
    if (typeof cuerpo.message === 'string') return cuerpo.message;
    const primeraClave = Object.keys(cuerpo)[0];
    if (primeraClave && Array.isArray(cuerpo[primeraClave])) return cuerpo[primeraClave][0];
  }
  return typeof cuerpo === 'string' && cuerpo ? cuerpo : '(sin mensaje del servidor)';
}

async function leerCuerpo(resp) {
  const texto = await resp.text();
  try {
    return JSON.parse(texto);
  } catch {
    return texto;
  }
}

async function listarArchivosFotos() {
  const nombres = await readdir(dirFotos);
  return nombres.map((n) => n.normalize('NFC'));
}

// Compara nombres normalizados en NFC: los archivos tienen tildes y espacios,
// y distintas fuentes pueden entregar la misma letra acentuada descompuesta
// (NFD) o precompuesta (NFC).
function resolverRutaFoto(nombreArchivo, archivosDisponibles) {
  const buscado = nombreArchivo.normalize('NFC');
  const encontrado = archivosDisponibles.find((n) => n === buscado);
  return encontrado ? path.join(dirFotos, encontrado) : null;
}

async function revisarFoto(nombreFoto, archivosDisponibles) {
  const rutaFoto = resolverRutaFoto(nombreFoto, archivosDisponibles);
  if (!rutaFoto) {
    return { ok: false, motivo: `no se encontro el archivo "${nombreFoto}" en ${dirFotos}` };
  }
  const info = await stat(rutaFoto);
  if (info.size > PESO_MAXIMO) {
    const pesoMb = (info.size / 1024 / 1024).toFixed(2);
    return { ok: false, motivo: `"${nombreFoto}" pesa ${pesoMb} MB (mas de 2 MB)` };
  }
  return { ok: true, ruta: rutaFoto, pesoKb: Math.round(info.size / 1024) };
}

async function validarTodo(lugares) {
  const archivosDisponibles = await listarArchivosFotos();
  let ok = true;
  console.log(`Validando ${lugares.length} lugares (fotos en ${dirFotos}):\n`);
  for (const lugar of lugares) {
    console.log(`"${lugar.nombre}":`);
    if (!Array.isArray(lugar.fotos) || lugar.fotos.length !== FOTOS_POR_LUGAR) {
      console.log(`  x debe tener ${FOTOS_POR_LUGAR} fotos en el JSON (tiene ${lugar.fotos?.length ?? 0}).`);
      ok = false;
      continue;
    }
    for (const nombreFoto of lugar.fotos) {
      const resultado = await revisarFoto(nombreFoto, archivosDisponibles);
      if (resultado.ok) {
        console.log(`  OK "${nombreFoto}" (${resultado.pesoKb} KB)`);
      } else {
        console.log(`  x ${resultado.motivo}`);
        ok = false;
      }
    }
  }
  return ok;
}

async function login(apiUrl, email, password) {
  const resp = await fetch(`${apiUrl}/arrendatario/login`, {
    method: 'POST',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  const cuerpo = await leerCuerpo(resp);
  if (!resp.ok) {
    throw new Error(`no se pudo iniciar sesion (HTTP ${resp.status}): ${mensajeDeError(cuerpo)}`);
  }
  return cuerpo;
}

async function obtenerLugaresExistentes(apiUrl, arrendatarioId) {
  const resp = await fetch(`${apiUrl}/lugares/arrendatario/${arrendatarioId}`, {
    headers: { Accept: 'application/json' },
  });
  // Un arrendatario sin lugares todavia puede responder 404 con {"message": ...}
  // en vez de un arreglo vacio: en ambos casos significa "sin lugares".
  if (resp.status === 404) return [];
  const cuerpo = await leerCuerpo(resp);
  if (!resp.ok) {
    throw new Error(`no se pudo obtener los lugares del arrendatario (HTTP ${resp.status}): ${mensajeDeError(cuerpo)}`);
  }
  return Array.isArray(cuerpo) ? cuerpo : [];
}

async function crearLugar(apiUrl, lugar, arrendatarioId) {
  const { fotos, ...campos } = lugar;
  const body = {
    ...campos,
    // La API rechaza latitud/longitud como numero: deben ir como texto.
    latitud: String(lugar.latitud),
    longitud: String(lugar.longitud),
    arrendatario_id: arrendatarioId,
  };
  const resp = await fetch(`${apiUrl}/lugares`, {
    method: 'POST',
    headers: { Accept: 'application/json', 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  const cuerpo = await leerCuerpo(resp);
  if (!resp.ok) {
    throw new Error(mensajeDeError(cuerpo));
  }
  return cuerpo.id;
}

async function subirFoto(apiUrl, lugarId, rutaArchivo, nombreParaEnviar) {
  const datos = await readFile(rutaArchivo);
  const formulario = new FormData();
  formulario.append('foto', new Blob([datos], { type: 'image/jpeg' }), nombreParaEnviar);
  const resp = await fetch(`${apiUrl}/lugares/${lugarId}/foto`, {
    method: 'POST',
    // Sin Content-Type a mano: fetch arma el boundary del multipart solo.
    headers: { Accept: 'application/json' },
    body: formulario,
  });
  const cuerpo = await leerCuerpo(resp);
  if (!resp.ok) {
    throw new Error(mensajeDeError(cuerpo));
  }
}

async function cargarDeVerdad(lugares) {
  const credenciales = await cargarCredenciales();

  if (esApiMock(credenciales.apiUrl)) {
    console.log(
      `"${credenciales.apiUrl}" es el mock local (Mockoon): no guarda datos entre reinicios, ` +
        'asi que cargar lugares de prueba ahi no sirve para nada permanente. ' +
        'No se hizo ninguna peticion. Cambia "apiUrl" en credenciales.json a la API real y volve a correr el script.',
    );
    return;
  }

  const apiUrl = credenciales.apiUrl.replace(/\/+$/, '');

  console.log(`Iniciando sesion como arrendatario (${credenciales.email})...`);
  const usuario = await login(apiUrl, credenciales.email, credenciales.password);
  console.log(`OK sesion iniciada: ${usuario.nombrecompleto} (id ${usuario.id})\n`);

  const existentes = await obtenerLugaresExistentes(apiUrl, usuario.id);
  const archivosDisponibles = await listarArchivosFotos();
  const resumen = [];

  for (let i = 0; i < lugares.length; i++) {
    const lugar = lugares[i];
    const yaExiste = existentes.find((l) => l.nombre === lugar.nombre);

    if (yaExiste) {
      const cantidadFotos = Array.isArray(yaExiste.fotos) ? yaExiste.fotos.length : 0;
      const estado =
        cantidadFotos < lugar.fotos.length
          ? `incompleto (${cantidadFotos}/${lugar.fotos.length} fotos)`
          : `ya existia (${cantidadFotos}/${lugar.fotos.length} fotos)`;
      console.log(`"${lugar.nombre}": ya existe (id ${yaExiste.id}), omitido. ${estado}.`);
      resumen.push({ nombre: lugar.nombre, id: yaExiste.id, estado });
      continue;
    }

    console.log(`Creando "${lugar.nombre}"...`);
    let idCreado;
    try {
      idCreado = await crearLugar(apiUrl, lugar, usuario.id);
      console.log(`OK creado con id ${idCreado}.`);
    } catch (e) {
      console.error(`x no se pudo crear "${lugar.nombre}": ${e.message}`);
      resumen.push({ nombre: lugar.nombre, id: '-', estado: 'ERROR al crear, sin fotos' });
      continue;
    }

    let subidas = 0;
    for (let j = 0; j < lugar.fotos.length; j++) {
      const nombreFoto = lugar.fotos[j];
      const nombreParaEnviar = `lugar${i + 1}-${j + 1}.jpeg`;
      const revision = await revisarFoto(nombreFoto, archivosDisponibles);

      if (!revision.ok) {
        console.warn(`  x foto ${j + 1}/${lugar.fotos.length}: ${revision.motivo}, se omite.`);
        continue;
      }
      try {
        await subirFoto(apiUrl, idCreado, revision.ruta, nombreParaEnviar);
        subidas++;
        console.log(`  OK foto ${j + 1}/${lugar.fotos.length} subida (${nombreParaEnviar}).`);
      } catch (e) {
        console.warn(`  x foto ${j + 1}/${lugar.fotos.length} ("${nombreFoto}") fallo: ${e.message}`);
      }
    }

    resumen.push({ nombre: lugar.nombre, id: idCreado, estado: `${subidas}/${lugar.fotos.length} fotos subidas` });
    console.log('');
  }

  console.log('--- Resumen ---');
  for (const r of resumen) {
    console.log(`${r.nombre} | id ${r.id} | ${r.estado}`);
  }
}

async function main() {
  const lugares = await cargarLugares();

  if (soloProbar) {
    const ok = await validarTodo(lugares);
    console.log(ok ? '\nOK: los 4 lugares y sus 16 fotos estan listos.' : '\nSe encontraron problemas, revisa los mensajes de arriba.');
    process.exitCode = ok ? 0 : 1;
    return;
  }

  await cargarDeVerdad(lugares);
}

main().catch((e) => {
  console.error(`x error inesperado: ${e.message}`);
  process.exitCode = 1;
});
