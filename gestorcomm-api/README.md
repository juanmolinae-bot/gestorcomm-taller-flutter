# GestorComm API - Flask + SQLite

API REST construida con Flask que expone operaciones CRUD sobre una tabla de incidencias en SQLite.

Parte del Taller de Desarrollo Web y Móvil (APTC106) — Universidad Andrés Bello.

**Arquitectura:** `App Flutter → API REST Flask → SQLite`

## Endpoints

| Método | Ruta | Descripción |
|---|---|---|
| GET | `/` | Info de la API |
| GET | `/api/incidencias` | Listar todas (opcional: `?estado=abierta`) |
| GET | `/api/incidencias/<id>` | Obtener una incidencia |
| POST | `/api/incidencias` | Crear nueva |
| PUT | `/api/incidencias/<id>` | Actualizar |
| DELETE | `/api/incidencias/<id>` | Eliminar |

## Modelo de datos

```json
{
  "id": 1,
  "titulo": "Falla comunicacion inversor INV-12",
  "descripcion": "No responde a polling modbus...",
  "zona": "Inversores",
  "prioridad": "alta",     // baja, media, alta, critica
  "estado": "abierta",     // abierta, en_revision, resuelta, cerrada
  "fecha_creacion": "2026-06-13T12:00:00"
}
```

## Instalación y arranque (Linux Mint)

```bash
cd gestorcomm-api
bash run_api.sh          # solo API en localhost
# o
bash run_api.sh --ngrok  # API + ngrok público
```

El script crea el venv, instala dependencias, carga datos demo y arranca el servidor en el puerto 5000.

## Manual (sin script)

```bash
cd gestorcomm-api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python seed.py        # solo la primera vez
python app.py
```

## Exposición pública con ngrok

Para que la app Flutter (en emulador o celular) pueda comunicarse con la API que corre en tu PC, hay dos opciones:

**Opción A — Localhost del emulador:**
- Si usas el emulador Android Studio, la IP `10.0.2.2` apunta al localhost del host. Configura en Flutter: `baseUrl = 'http://10.0.2.2:5000'`
- Necesitas agregar `android:usesCleartextTraffic="true"` en el AndroidManifest.xml para que permita HTTP.

**Opción B — ngrok (recomendado, también funciona en celular físico):**

```bash
# Con la API corriendo en otra terminal:
ngrok http 5000
```

ngrok te entrega una URL pública tipo `https://abc123.ngrok-free.app`. Esta URL es la que va en el `baseUrl` de Flutter.

## Pruebas de los endpoints (curl)

```bash
# Listar todas
curl http://localhost:5000/api/incidencias

# Crear
curl -X POST http://localhost:5000/api/incidencias \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Test","zona":"Test","prioridad":"baja"}'

# Filtrar por estado
curl "http://localhost:5000/api/incidencias?estado=abierta"

# Actualizar
curl -X PUT http://localhost:5000/api/incidencias/1 \
  -H "Content-Type: application/json" \
  -d '{"estado":"resuelta"}'

# Eliminar
curl -X DELETE http://localhost:5000/api/incidencias/1
```

## Autor

Juan Molina Escalante – APTC106 – 2026
