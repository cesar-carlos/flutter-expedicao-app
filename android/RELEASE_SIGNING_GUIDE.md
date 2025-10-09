# Guia de Assinatura de Release para Android

## Status Atual

Atualmente, o aplicativo está configurado para usar as **chaves de debug** para assinatura de release (ver `app/build.gradle.kts` linha 37). Isso é adequado para testes, mas **NÃO DEVE ser usado para distribuição em produção na Play Store**.

## Arquivos Gerados

### APK de Release

- **Localização**: `build/app/outputs/flutter-apk/app-release.apk`
- **Tamanho**: ~73MB
- **Uso**: Distribuição direta (instalação manual, testes internos)

### App Bundle (AAB)

- **Localização**: `build/app/outputs/bundle/release/app-release.aab`
- **Tamanho**: ~53MB
- **Uso**: Upload para Google Play Store (recomendado)
- **Vantagem**: A Play Store gera APKs otimizados para cada dispositivo

## Configurando Assinatura de Produção

### Passo 1: Criar o Keystore

Execute o seguinte comando para criar um keystore de produção:

```bash
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**IMPORTANTE**:

- Guarde a senha do keystore em local seguro
- Guarde a senha da chave (alias) em local seguro
- **NUNCA** comite o arquivo `.jks` no Git
- Faça backup do keystore em local seguro (se perder, não poderá mais atualizar o app)

### Passo 2: Criar o arquivo key.properties

Crie o arquivo `android/key.properties` com o seguinte conteúdo:

```properties
storePassword=<senha-do-keystore>
keyPassword=<senha-da-chave>
keyAlias=upload
storeFile=<caminho-para-o-arquivo-jks>
```

**Exemplo**:

```properties
storePassword=minhasenha123
keyPassword=minhasenha456
keyAlias=upload
storeFile=../upload-keystore.jks
```

### Passo 3: Atualizar build.gradle.kts

Substitua o conteúdo do arquivo `android/app/build.gradle.kts` para incluir a configuração de assinatura:

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// Carregar propriedades do keystore
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "br.com.se7esistemassinop.exp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "br.com.se7esistemassinop.exp"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // Habilitar minificação e ofuscação (opcional)
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
```

### Passo 4: Adicionar ao .gitignore

Adicione as seguintes linhas ao arquivo `android/.gitignore`:

```gitignore
key.properties
*.jks
*.keystore
```

## Gerando Releases Assinadas

Após configurar o keystore:

### Para APK:

```bash
flutter build apk --release
```

### Para App Bundle (Play Store):

```bash
flutter build appbundle --release
```

## Versionamento

Antes de gerar uma nova release, atualize a versão no arquivo `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        └─┬─┘ └┬┘
#          │    └─ versionCode (Android) / build number
#          └────── versionName
```

Incrementar:

- **Major** (1.x.x): Mudanças significativas/breaking changes
- **Minor** (x.1.x): Novas funcionalidades
- **Patch** (x.x.1): Correções de bugs
- **Build** (+X): Cada novo build

## Upload para Play Store

1. Acesse o [Google Play Console](https://play.google.com/console)
2. Selecione seu aplicativo
3. Vá em "Produção" > "Releases"
4. Clique em "Criar novo release"
5. Faça upload do arquivo `.aab` (App Bundle)
6. Preencha as informações de release
7. Revise e publique

## Solução de Problemas

### Erro: "Storage for [...] is already registered"

Este erro ocorre quando há processos Java/Kotlin em execução. Solução:

1. Parar processos Java:

```bash
# Windows
taskkill /F /IM java.exe

# Linux/Mac
killall java
```

2. Limpar build:

```bash
flutter clean
flutter pub get
```

3. Tentar novamente

### Verificar Assinatura do APK

Para verificar se o APK/AAB está assinado corretamente:

```bash
# Para APK
keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk

# Para AAB
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

## Referências

- [Documentação oficial Flutter - Build e release Android](https://docs.flutter.dev/deployment/android)
- [Guia de assinatura de apps Android](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)

---

**Última atualização**: 08/10/2025
**Versão atual do app**: 1.0.0+1
