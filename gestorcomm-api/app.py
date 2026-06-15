"""
GestorComm API - Flask con SQLite
Examen Taller Web y Movil - UAB
Juan Molina E
"""
from flask import Flask, request, jsonify
from flask_cors import CORS
import sqlite3
import os
from datetime import datetime

app = Flask(__name__)
CORS(app)  # necesario para que la app flutter pueda llamar desde otro origen

DB_PATH = os.path.join(os.path.dirname(__file__), 'gestorcomm.db')


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    # crea la tabla si no existe todavia
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS incidencias (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT NOT NULL,
            descripcion TEXT,
            zona TEXT NOT NULL,
            prioridad TEXT NOT NULL DEFAULT 'media',
            estado TEXT NOT NULL DEFAULT 'abierta',
            fecha_creacion TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()


def row_to_dict(row):
    # helper para convertir sqlite3.Row a dict (porque jsonify no lo hace solo)
    return {k: row[k] for k in row.keys()}


@app.route('/')
def home():
    # endpoint raiz, solo informativo
    return jsonify({
        'name': 'GestorComm API',
        'version': '1.0',
        'endpoints': [
            'GET /api/incidencias',
            'GET /api/incidencias/<id>',
            'POST /api/incidencias',
            'PUT /api/incidencias/<id>',
            'DELETE /api/incidencias/<id>'
        ]
    })


@app.route('/api/incidencias', methods=['GET'])
def listar_incidencias():
    # lista todas las incidencias, ordenadas por fecha mas reciente primero
    # opcional: filtrar por estado con ?estado=abierta
    conn = get_db()
    estado = request.args.get('estado')
    if estado:
        rows = conn.execute(
            'SELECT * FROM incidencias WHERE estado = ? ORDER BY fecha_creacion DESC',
            (estado,)
        ).fetchall()
    else:
        rows = conn.execute(
            'SELECT * FROM incidencias ORDER BY fecha_creacion DESC'
        ).fetchall()
    conn.close()
    return jsonify([row_to_dict(r) for r in rows])


@app.route('/api/incidencias/<int:pk>', methods=['GET'])
def obtener_incidencia(pk):
    conn = get_db()
    row = conn.execute('SELECT * FROM incidencias WHERE id = ?', (pk,)).fetchone()
    conn.close()
    if row is None:
        return jsonify({'error': 'Incidencia no encontrada'}), 404
    return jsonify(row_to_dict(row))


@app.route('/api/incidencias', methods=['POST'])
def crear_incidencia():
    data = request.get_json()
    # validacion minima: titulo y zona son obligatorios, el resto tiene default
    if not data or not data.get('titulo') or not data.get('zona'):
        return jsonify({'error': 'titulo y zona son obligatorios'}), 400

    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO incidencias (titulo, descripcion, zona, prioridad, estado, fecha_creacion)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (
        data.get('titulo'),
        data.get('descripcion', ''),
        data.get('zona'),
        data.get('prioridad', 'media'),
        data.get('estado', 'abierta'),
        datetime.now().isoformat(timespec='seconds')
    ))
    conn.commit()
    new_id = cur.lastrowid
    row = conn.execute('SELECT * FROM incidencias WHERE id = ?', (new_id,)).fetchone()
    conn.close()
    return jsonify(row_to_dict(row)), 201


@app.route('/api/incidencias/<int:pk>', methods=['PUT'])
def actualizar_incidencia(pk):
    data = request.get_json()
    if not data:
        return jsonify({'error': 'No se enviaron datos'}), 400

    conn = get_db()
    row = conn.execute('SELECT * FROM incidencias WHERE id = ?', (pk,)).fetchone()
    if row is None:
        conn.close()
        return jsonify({'error': 'Incidencia no encontrada'}), 404

    # si un campo no viene en el body, dejo el valor anterior
    titulo = data.get('titulo', row['titulo'])
    descripcion = data.get('descripcion', row['descripcion'])
    zona = data.get('zona', row['zona'])
    prioridad = data.get('prioridad', row['prioridad'])
    estado = data.get('estado', row['estado'])

    conn.execute("""
        UPDATE incidencias
        SET titulo = ?, descripcion = ?, zona = ?, prioridad = ?, estado = ?
        WHERE id = ?
    """, (titulo, descripcion, zona, prioridad, estado, pk))
    conn.commit()

    updated = conn.execute('SELECT * FROM incidencias WHERE id = ?', (pk,)).fetchone()
    conn.close()
    return jsonify(row_to_dict(updated))


@app.route('/api/incidencias/<int:pk>', methods=['DELETE'])
def eliminar_incidencia(pk):
    conn = get_db()
    row = conn.execute('SELECT * FROM incidencias WHERE id = ?', (pk,)).fetchone()
    if row is None:
        conn.close()
        return jsonify({'error': 'Incidencia no encontrada'}), 404

    conn.execute('DELETE FROM incidencias WHERE id = ?', (pk,))
    conn.commit()
    conn.close()
    return jsonify({'mensaje': 'Incidencia eliminada', 'id': pk})


if __name__ == '__main__':
    init_db()
    # TODO: en algun momento agregar autenticacion, por ahora la api es abierta
    print("=" * 50)
    print(" GestorComm API - corriendo en http://0.0.0.0:5000")
    print(" Para exponer con ngrok: ngrok http 5000")
    print("=" * 50)
    app.run(host='0.0.0.0', port=5000, debug=True)
