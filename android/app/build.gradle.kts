import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()

if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { input ->
        keystoreProperties.load(input)
    }
}

fun keystoreProperty(name: String): String? =
    keystoreProperties.getProperty(name)?.trim()?.takeIf { it.isNotEmpty() }

val hasReleaseSigningConfig =
    listOf("storePassword", "keyPassword", "keyAlias", "storeFile").all { key ->
        keystoreProperty(key) != null
    }

val requireReleaseSigning =
    providers.gradleProperty("requireReleaseSigning")
        .orElse(providers.environmentVariable("REQUIRE_RELEASE_SIGNING"))
        .orElse("false")
        .get()
        .toBoolean()

val isReleaseTaskRequested =
    gradle.startParameter.taskNames.any { taskName ->
        taskName.contains("release", ignoreCase = true)
    }

if (keystorePropertiesFile.exists() && !hasReleaseSigningConfig) {
    throw GradleException(
        "android/key.properties exists but is incomplete. Required keys: " +
            "storePassword, keyPassword, keyAlias, storeFile.",
    )
}

if (requireReleaseSigning && !hasReleaseSigningConfig) {
    throw GradleException(
        "Release signing is required, but android/key.properties was not found or is incomplete.",
    )
}

android {
    namespace = "br.com.se7esistemassinop.exp"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "br.com.se7esistemassinop.exp"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigningConfig) {
                keyAlias = keystoreProperty("keyAlias")
                keyPassword = keystoreProperty("keyPassword")
                storeFile = rootProject.file(keystoreProperty("storeFile")!!)
                storePassword = keystoreProperty("storePassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(
                if (hasReleaseSigningConfig) "release" else "debug",
            )

            if (!hasReleaseSigningConfig && isReleaseTaskRequested) {
                logger.warn(
                    "Release build is using debug signing. Configure android/key.properties " +
                        "or set REQUIRE_RELEASE_SIGNING=true to fail unsigned production builds.",
                )
            }
        }
    }

    testOptions {
        unitTests.isIncludeAndroidResources = true
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    testImplementation("junit:junit:4.13.2")
    testImplementation("androidx.test:core:1.6.1")
    testImplementation("org.robolectric:robolectric:4.12.2")
}
