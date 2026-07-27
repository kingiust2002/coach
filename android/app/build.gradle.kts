import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val hasReleaseSigning =
    listOf(
        "keyAlias",
        "keyPassword",
        "storeFile",
        "storePassword",
    ).all { key -> !keystoreProperties.getProperty(key).isNullOrBlank() }

// This checked-in key is intentionally development-only. It gives every
// FlutLab/GitHub debug build the same certificate, so APKs from newly imported
// workspaces can update one another without deleting app data.
val developmentKeystoreFile = rootProject.file("coach-flutlab-dev.jks")
val developmentKeyAlias = "coach-flutlab-dev"
val developmentKeyPassword = "coach-flutlab-development-2026"

android {
    namespace = "com.kingiust.coach"
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
        applicationId = "com.kingiust.coach"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("development") {
            keyAlias = developmentKeyAlias
            keyPassword = developmentKeyPassword
            storeFile = developmentKeystoreFile
            storePassword = developmentKeyPassword
        }

        if (hasReleaseSigning) {
            create("release") {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    buildTypes {
        getByName("debug") {
            signingConfig = signingConfigs.getByName("development")
        }

        getByName("release") {
            // Production builds can override the public development key by
            // supplying android/key.properties and a private keystore.
            signingConfig =
                if (hasReleaseSigning) {
                    signingConfigs.getByName("release")
                } else {
                    signingConfigs.getByName("development")
                }
        }
    }
}

flutter {
    source = "../.."
}
