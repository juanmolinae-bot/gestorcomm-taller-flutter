# GestorComm Flutter

Aplicaciòn movil en Flutter que se conecta a la API en Flask (carpeta `gestorcomm-api/`) para gestionar incidencias de comisionamiento elèctrico.

Esta aplicaciòn es la parte mòvil del proyecto del examen del Taller de Desarrollo Web y Móvil (APTC106) de la UAB.

## Arquitectura

App Flutter (Android) → llamadas HTTPS → Ngrok tunnel → Flask API en el PC → SQLite

El celular no puede llegar directo a la api en mi maquina, por eso uso ngrok como puente.

## Pantallas

Son 4 pantallas en total:

1. **Home** con el dashboard de resumen (cuantas abiertas, en revisiòn, cerradas) y las incidencias más recientes.
2. **Lista de incidencias** con filtros por estado y pull-to-refresh
3. **Detalle** de cada incidencia con botones para editar o eliminar
4. **Formulario** que sirve para crear y para editar (el mismo widget, solo cambia el modo segun el parametro)

## Stack

- Flutter 3.x con Material 3
- Package `http` para las llamadas REST
- Sin state management externo, solo `StatefulWidget` + `FutureBuilder` (es un proyecto chico, no se justifica meter Provider o BLoC).

## Como correrlo

Para Linux Mint, no probé en otros SO.

```bash
# instalar flutter si no esta
sudo snap install flutter --classic

# verificar
flutter doctor
```

`flutter doctor` te avisa si falta algo (Android SDK, licencias, etc).

Setup:

```bash
cd gestorcomm_flutter
flutter pub get
```

Antes de correr hay que editar `lib/services/api_service.dart` y cambiar la URL del backend por la que entrega ngrok:

```dart
static const String baseUrl = 'https://TU-URL-DE-NGROK.ngrok-free.dev';
```

Despues:

```bash
# verificar dispositivos conectados (deberia aparecer mi celular)
flutter devices

# correr en debug
flutter run

# o generar el APK release
flutter build apk --release
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk` (~21 MB).

Para instalarlo:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Estructura del codigo

```
gestorcomm_flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart                 → entry point, define el theme
│   ├── models/
│   │   └── incidencia.dart       → el modelo de datos
│   ├── services/
│   │   └── api_service.dart      → cliente http hacia la api
│   └── screens/
│       ├── home_screen.dart      → dashboard con resumen
│       ├── lista_screen.dart     → lista con filtros
│       ├── detalle_screen.dart   → detalle individual
│       └── formulario_screen.dart → crear/editar
└── android/                      → configuracion nativa
```

## Notas

- Si la API esta caida o si ngrok cambió de URL, la app muestra un error con boton "Reintentar" (esto pasa harto porque ngrok free se cae si esta inactivo).
- La cabecera `ngrok-skip-browser-warning: true` esta en todas las llamadas, sino ngrok devuelve una pagina html en vez del JSON.
- En el AndroidManifest hay que agregar el permiso `INTERNET`, sino el build release no puede hacer llamadas (la debug si pero la release no, eso me costo un rato darme cuenta).
- La app no tiene login. Es un MVP, no consideré cuentas de usuario para esta versión del trabajo.

Juan Molina E
