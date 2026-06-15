**Configuración Android  Permisos**

Para que la aplicaiòn en Flutter pueda hacer llamadas HTTP/HTTPS a la API expuesta por ngrok, el archivo `android/app/src/main/AndroidManifest.xml` debe incluir el permiso de INTERNET sino no funka la apliaciòn y queda colgada.

El Flutter ya lo agrega por defecto al crear el proyecto, pero *verifica* que estè presente justo antes de la etiqueta `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <!-- Permiso para que la app pueda hacer requests HTTP/HTTPS -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="GestorComm"
        ...
```

**Autor**

Juan Molina E
