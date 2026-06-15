#!/usr/bin/env bash
# run_api.sh - Lanza la API Flask y opcionalmente ngrok
# Uso:
#   bash run_api.sh         # solo API local
#   bash run_api.sh --ngrok # API + ngrok público

set -e

echo "================================================"
echo " GestorComm API - Arranque"
echo "================================================"
echo ""

# Verificar Python
if ! command -v python3 &> /dev/null; then
    echo "❌ python3 no encontrado"
    exit 1
fi

# Crear venv si no existe
if [ ! -d "venv" ]; then
    echo "[1/3] Creando entorno virtual..."
    python3 -m venv venv
fi

# Activar venv e instalar deps
echo "[2/3] Instalando dependencias..."
source venv/bin/activate
pip install -r requirements.txt --quiet

# Cargar datos demo si la base no existe
if [ ! -f "gestorcomm.db" ]; then
    echo "[3/3] Cargando datos demo..."
    python seed.py
else
    echo "[3/3] Base de datos ya existe, no se recargan datos."
fi

echo ""
echo "================================================"
echo " ✅ Backend listo"
echo "================================================"
echo ""

# Verificar si pidió ngrok
if [ "$1" == "--ngrok" ]; then
    if ! command -v ngrok &> /dev/null; then
        echo "❌ ngrok no encontrado. Instalalo:"
        echo "   https://ngrok.com/download"
        echo "   o snap install ngrok"
        exit 1
    fi

    echo "Lanzando API en background..."
    python app.py > api.log 2>&1 &
    API_PID=$!
    sleep 3

    echo "Lanzando ngrok en puerto 5000..."
    echo ""
    echo "================================================"
    echo " 📱 Copia la URL https que aparece abajo (ej: https://abc123.ngrok-free.app)"
    echo " 🔧 Pégala en lib/services/api_service.dart (baseUrl)"
    echo "    de la app Flutter."
    echo " ⚠️  Para detener todo: Ctrl+C"
    echo "================================================"
    echo ""

    # Cleanup al salir
    trap "kill $API_PID 2>/dev/null; exit" INT TERM

    ngrok http 5000
else
    echo "Lanzando API en http://0.0.0.0:5000"
    echo ""
    echo "Endpoints:"
    echo "  GET    /api/incidencias"
    echo "  GET    /api/incidencias/<id>"
    echo "  POST   /api/incidencias"
    echo "  PUT    /api/incidencias/<id>"
    echo "  DELETE /api/incidencias/<id>"
    echo ""
    echo "Para exponer con ngrok, ejecuta en otra terminal: ngrok http 5000"
    echo "Para detener: Ctrl+C"
    echo ""

    python app.py
fi
