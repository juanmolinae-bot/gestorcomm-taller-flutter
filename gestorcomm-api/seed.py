"""
seed.py - carga datos de ejemplo en la base
Uso: python seed.py
"""
import sqlite3
import os
from datetime import datetime, timedelta

DB_PATH = os.path.join(os.path.dirname(__file__), 'gestorcomm.db')

# Asegurar que la tabla exista
conn = sqlite3.connect(DB_PATH)
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

# Solo cargar si la tabla está vacía
count = cur.execute('SELECT COUNT(*) FROM incidencias').fetchone()[0]
if count > 0:
    print(f"Ya hay {count} incidencias en la base, no se cargan duplicados.")
    conn.close()
    exit(0)

now = datetime.now()

incidencias_demo = [
    {
        'titulo': 'Falla comunicacion inversor INV-12',
        'descripcion': 'No responde a polling modbus desde SCADA. Revisar fibra y switch.',
        'zona': 'Inversores',
        'prioridad': 'alta',
        'estado': 'abierta',
        'fecha': (now - timedelta(hours=2)).isoformat(timespec='seconds')
    },
    {
        'titulo': 'Alarma BMS celda 3 rack 7',
        'descripcion': 'Voltaje fuera de rango. Revisar conexion CAN.',
        'zona': 'BESS Cristales',
        'prioridad': 'critica',
        'estado': 'en_revision',
        'fecha': (now - timedelta(hours=5)).isoformat(timespec='seconds')
    },
    {
        'titulo': 'OLTC transformador T1 no opera',
        'descripcion': 'Tap changer no responde a comando remoto desde sala de control.',
        'zona': 'SE Futuro',
        'prioridad': 'alta',
        'estado': 'en_revision',
        'fecha': (now - timedelta(days=1)).isoformat(timespec='seconds')
    },
    {
        'titulo': 'Tracker fila 24 desalineado',
        'descripcion': 'Tracker no sigue posicion comandada, revisar GCU.',
        'zona': 'Inversores',
        'prioridad': 'media',
        'estado': 'resuelta',
        'fecha': (now - timedelta(days=2)).isoformat(timespec='seconds')
    }
]

for inc in incidencias_demo:
    cur.execute("""
        INSERT INTO incidencias (titulo, descripcion, zona, prioridad, estado, fecha_creacion)
        VALUES (?, ?, ?, ?, ?, ?)
    """, (inc['titulo'], inc['descripcion'], inc['zona'], inc['prioridad'], inc['estado'], inc['fecha']))

conn.commit()
print(f"Se cargaron {len(incidencias_demo)} incidencias de demo.")
conn.close()
