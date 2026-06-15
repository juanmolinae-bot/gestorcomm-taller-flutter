# GestorComm API

Esta es la API en Flask que use para el ultimo trabajo del taller. Maneja un CRUD simple de incidencias y los guarda en SQLite.

Es la parte backend del proyecto, despues el celular se conecta via ngrok.

## Como funciona

Son 5 endpoints, los básicos de un CRUD:

- GET `/api/incidencias` → lista todas. Tambien acepta `?estado=abierta` para filtrar
- GET `/api/incidencias/<id>` → trae una sola por id
- POST `/api/incidencias` → crea una nueva (requiere titulo y zona si o si)
- PUT `/api/incidencias/<id>` → actualiza
- DELETE `/api/incidencias/<id>` → elimina

Devuelve JSON en todos los casos. El formato es algo asi:

```json
{
  "id": 1,
  "titulo": "Falla comunicacion inversor INV-12",
  "descripcion": "No responde a polling modbus",
  "zona": "Inversores",
  "prioridad": "alta",
  "estado": "abierta",
  "fecha_creacion": "2026-06-13T12:00:00"
}
```

Los valores válidos:
- prioridad: baja, media, alta, critica
- estado: abierta, en_revision, resuelta, cerrada

## Levantar la API

Lo hice con Linux Mint, no probé en otro SO.

```bash
cd gestorcomm-api
bash run_api.sh
```

El script arma el venv, instala las dependencias del requirements y arranca Flask en el puerto 5000. Si es la primera vez, también carga 4 incidencias demo con seed.py.

Si lo querís hacer a mano:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python seed.py   # solo la primera vez
python app.py
```

## Para que el celular se pueda conectar — ngrok

Como Flask corre en mi PC y el celular no esta en la misma red local, use ngrok que arma un tunnel HTTPS publico. En otra terminal:

```bash
ngrok http 5000
```

Te devuelve una URL tipo `https://algo-random.ngrok-free.dev` que es la que va en el archivo `api_service.dart` de la app Flutter.

OJO que en plan free de ngrok la URL cambia cada vez que lo reinicias.

## Pruebas rapidas con curl

```bash
# listar
curl http://localhost:5000/api/incidencias

# crear
curl -X POST http://localhost:5000/api/incidencias \
  -H "Content-Type: application/json" \
  -d '{"titulo":"Test","zona":"Test"}'

# actualizar el estado
curl -X PUT http://localhost:5000/api/incidencias/1 \
  -H "Content-Type: application/json" \
  -d '{"estado":"resuelta"}'

# eliminar
curl -X DELETE http://localhost:5000/api/incidencias/1
```

Juan Molina E
