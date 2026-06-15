# GestorComm Flutter

App móvil Flutter que consume la API REST en Flask para gestionar incidencias.

Parte del Taller de Desarrollo Web y Móvil (APTC106) — Universidad Andrés Bello.

## Arquitectura

```
[ App Flutter ] ───HTTPS───► [ Ngrok ] ───► [ Flask API ] ───► [ SQLite ]
   (celular o emulador)         (tunnel)      (PC localhost)     (file)
```

## Pantallas

1. **Lista de incidencias** con filtros por estado (chips), pull-to-refresh
2. **Detalle** de cada incidencia con botones Editar y Eliminar
3. **Formulario** para crear o editar (mismo widget, modo controlado por parámetro)

## Stack

- Flutter 3.x con Material 3
- Package `http` para llamadas REST
- Sin state management externo (solo StatefulWidget + FutureBuilder)

## Instalación de Flutter en Linux Mint

```bash
# Si aún no tienes Flutter:
sudo snap install flutter --classic

# Verificar
flutter doctor
```

`flutter doctor` te dirá si te falta algo (Android SDK, licencias, etc).

## Setup del proyecto

```bash
cd gestorcomm_flutter
flutter pub get
```

## Configurar la URL de la API

Edita `lib/services/api_service.dart` y cambia la constante `baseUrl`:

```dart
static const String baseUrl = 'https://TU-URL-DE-NGROK.ngrok-free.app';
```

Para obtener la URL de ngrok:

```bash
# En el proyecto de la API
cd ../gestorcomm-api
ngrok http 5000
```

Copia la URL `https://...ngrok-free.app` que aparece y pégala en el `api_service.dart`.

## Ejecutar la app

**En emulador Android:**

```bash
# Lanzar emulador desde Android Studio o desde CLI:
flutter emulators
flutter emulators --launch <emulator_id>

# En el proyecto Flutter:
flutter run
```

**En celular físico conectado por USB:**

```bash
# Verificar que el celular se ve:
flutter devices

# Correr:
flutter run
```

## Generar el APK

```bash
flutter build apk --release
```

El APK queda en: `build/app/outputs/flutter-apk/app-release.apk`

Para instalarlo en un celular conectado:

```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

## Estructura

```
gestorcomm_flutter/
├── pubspec.yaml
├── lib/
│   ├── main.dart                           ← entry point
│   ├── models/
│   │   └── incidencia.dart                 ← modelo de datos
│   ├── services/
│   │   └── api_service.dart                ← cliente HTTP
│   └── screens/
│       ├── lista_screen.dart               ← pantalla principal
│       ├── detalle_screen.dart             ← detalle individual
│       └── formulario_screen.dart          ← crear/editar
└── android/
    └── (configuración Android Studio)
```

## Notas

- Si la API está caída o ngrok cambió de URL, la app muestra un error con botón "Reintentar".
- La cabecera `'ngrok-skip-browser-warning': 'true'` se incluye en todos los requests para saltarse la página de advertencia que ngrok muestra a navegadores.
- La app NO tiene autenticación (es un MVP), cualquiera con la URL puede llamar a la API.

## Autor

Juan Molina Escalante – APTC106 – 2026
