import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Signaturschlüssel für den Release-Build (siehe PLAN.md Phase 15.1). Die
// Datei enthält Passwörter und liegt deshalb NICHT im Repository — Vorlage:
// `android/key.properties.example`. Fehlt sie, bleibt es beim Debug-Schlüssel
// (siehe `buildTypes.release` unten): so bleibt das Projekt ohne Schlüssel
// baubar, ein Upload in die Play Console ist damit aber nicht möglich.
val keystoreProperties = Properties().apply {
    val file = rootProject.file("key.properties")
    if (file.exists()) file.inputStream().use { load(it) }
}
val hasReleaseKeystore = keystoreProperties.getProperty("storeFile") != null

android {
    // Muss zum Kotlin-Paket unter src/main/kotlin passen: `home_widget` löst
    // die Widget-Klassen zur Laufzeit über `context.packageName` auf — also
    // über die applicationId. Weichen Paket und applicationId voneinander ab,
    // finden die Home-Screen-Widgets ihre Klassen nicht mehr (Phase 15.1).
    namespace = "com.rootin.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications benötigt Core Library Desugaring.
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // ⚠️ Nach der Veröffentlichung im Play Store unveränderlich (Phase 15.1,
        // vom Nutzer am 2026-07-26 gewählt).
        applicationId = "com.rootin.app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (hasReleaseKeystore) {
            create("release") {
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseKeystore) {
                signingConfigs.getByName("release")
            } else {
                // Nur damit `flutter run --release` lokal weiterläuft. Ein so
                // signiertes Bundle weist die Play Console ab. `println` statt
                // `logger.warn`, weil Flutter die Gradle-Logausgabe filtert.
                println(
                    "\n⚠️  android/key.properties fehlt — Release wird mit dem DEBUG-Schlüssel " +
                        "signiert und ist NICHT hochladbar (siehe PLAN.md Phase 15.1).\n"
                )
                signingConfigs.getByName("debug")
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
