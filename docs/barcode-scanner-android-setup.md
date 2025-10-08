# Configuração Android - Scanner de Código de Barras

## 📱 Permissões Necessárias

Para que o scanner de código de barras funcione no Android, é necessário configurar as permissões de câmera.

## ⚙️ Configuração

### 1. AndroidManifest.xml

Abra o arquivo `android/app/src/main/AndroidManifest.xml` e adicione as permissões:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.seuapp.exp">

    <!-- Adicionar estas permissões -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />

    <application
        android:label="exp"
        android:icon="@mipmap/launcher_icon">
        <!-- ... resto do código ... -->
    </application>
</manifest>
```

### 2. Verificar MinSdkVersion

No arquivo `android/app/build.gradle`, verifique se a versão mínima do SDK está correta:

```gradle
android {
    compileSdkVersion 34

    defaultConfig {
        minSdkVersion 21  // Mínimo para flutter_barcode_scanner
        targetSdkVersion 34
        // ...
    }
}
```

### 3. Permissões em Runtime (Automático)

O pacote `flutter_barcode_scanner` solicita permissão de câmera automaticamente em runtime quando você chama o método `scanBarcode()`.

Se você quiser solicitar permissão manualmente antes, pode usar o pacote `permission_handler`:

```yaml
dependencies:
  permission_handler: ^11.0.0
```

```dart
import 'package:permission_handler/permission_handler.dart';

Future<void> requestCameraPermission() async {
  final status = await Permission.camera.request();

  if (status.isGranted) {
    // Permissão concedida
    print('Permissão de câmera concedida');
  } else if (status.isDenied) {
    // Permissão negada
    print('Permissão de câmera negada');
  } else if (status.isPermanentlyDenied) {
    // Permissão permanentemente negada
    // Abrir configurações do app
    openAppSettings();
  }
}
```

## 🧪 Testando

### 1. Em um Dispositivo Real

O scanner de código de barras **só funciona em dispositivos reais** com câmera. Não funciona em emuladores.

Para testar:

```bash
# Conectar dispositivo Android via USB ou WiFi
flutter run
```

### 2. Build de Release

Para criar um APK de release:

```bash
flutter build apk --release
```

### 3. Build de Debug

Para criar um APK de debug:

```bash
flutter build apk --debug
```

## 🔍 Troubleshooting

### Erro: "Camera permission denied"

**Solução:**

1. Verificar se as permissões estão no `AndroidManifest.xml`
2. Desinstalar e reinstalar o app
3. Verificar se o dispositivo tem câmera funcionando

### Erro: "MissingPluginException"

**Solução:**

```bash
flutter clean
flutter pub get
flutter run
```

### Erro: "Unsupported operation: Platform.\_operatingSystem"

**Solução:**

- O scanner não funciona em emuladores
- Use um dispositivo real para testar

### Scanner não abre ou fecha imediatamente

**Solução:**

1. Verificar se o app tem permissão de câmera
2. Verificar se outra app está usando a câmera
3. Reiniciar o dispositivo

## 📋 Checklist de Configuração

- [ ] Permissões adicionadas no `AndroidManifest.xml`
- [ ] `minSdkVersion` configurado para 21 ou superior
- [ ] Pacote `flutter_barcode_scanner` instalado (`flutter pub get`)
- [ ] App testado em dispositivo real (não emulador)
- [ ] Permissão de câmera concedida no dispositivo

## 📖 Referências

- [flutter_barcode_scanner - Pub.dev](https://pub.dev/packages/flutter_barcode_scanner)
- [Android Permissions](https://developer.android.com/guide/topics/permissions/overview)
- [Flutter Platform Plugins](https://docs.flutter.dev/platform-integration/platform-channels)

## 🎯 Exemplo Completo de AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.data7.exp">

    <!-- Permissões -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.FLASHLIGHT" />

    <!-- Features -->
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    <uses-feature android:name="android.hardware.camera.flash" android:required="false" />

    <application
        android:label="Expedição"
        android:name="${applicationName}"
        android:icon="@mipmap/launcher_icon">

        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />

            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

---

**Última atualização:** Outubro 2025  
**Testado em:** Android 8.0+ (API 26+)
