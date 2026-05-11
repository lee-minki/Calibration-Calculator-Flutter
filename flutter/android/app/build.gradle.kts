import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
val hasKeystoreFile = keystorePropertiesFile.exists()
if (hasKeystoreFile) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// Environment variables override key.properties (preferred for CI).
val envStorePassword: String? = System.getenv("ANDROID_KEYSTORE_PASSWORD")
val envKeyPassword: String? = System.getenv("ANDROID_KEY_PASSWORD")
val envKeyAlias: String? = System.getenv("ANDROID_KEY_ALIAS")
val envStoreFile: String? = System.getenv("ANDROID_KEYSTORE_PATH")

val resolvedStorePassword: String? = envStorePassword ?: keystoreProperties["storePassword"] as String?
val resolvedKeyPassword: String? = envKeyPassword ?: keystoreProperties["keyPassword"] as String?
val resolvedKeyAlias: String? = envKeyAlias ?: keystoreProperties["keyAlias"] as String?
val resolvedStoreFile: String? = envStoreFile ?: keystoreProperties["storeFile"] as String?

val hasReleaseSigning =
    resolvedStorePassword != null &&
    resolvedKeyPassword != null &&
    resolvedKeyAlias != null &&
    resolvedStoreFile != null

android {
    namespace = "com.leeminki.calibration_calculator"
    // Pin SDK levels explicitly instead of inheriting Flutter's moving defaults,
    // so Play Store policy compliance does not silently regress across Flutter
    // SDK upgrades. Bump these intentionally when Play raises the floor.
    // google_mobile_ads 5.x requires compileSdk 36.
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyAlias = resolvedKeyAlias
                keyPassword = resolvedKeyPassword
                storeFile = file(resolvedStoreFile!!)
                storePassword = resolvedStorePassword
            }
        }
    }

    defaultConfig {
        applicationId = "com.leeminki.calibration_calculator"
        // Android 6.0 floor — google_mobile_ads 5.x supports down to API 23.
        minSdk = flutter.minSdkVersion
        // Play Store requires targetSdk ≥ 35 for new apps from Aug 2025.
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                logger.warn("⚠️  No release keystore found — falling back to debug signing. " +
                    "Set ANDROID_KEYSTORE_PASSWORD / ANDROID_KEY_PASSWORD / ANDROID_KEY_ALIAS / ANDROID_KEYSTORE_PATH " +
                    "or provide android/key.properties for a real release build.")
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Make Play Store-side per-device splits explicit. AAB already does this by
    // default, but pinning it here protects against future Gradle/AGP changes.
    bundle {
        density { enableSplit = true }
        abi     { enableSplit = true }
        language { enableSplit = true }
    }

    // Standard packaging cleanup — strip duplicate META-INF entries that some
    // transitive deps ship and that fail the build with merge conflicts.
    packaging {
        resources {
            excludes += setOf(
                "META-INF/AL2.0",
                "META-INF/LGPL2.1",
                "META-INF/DEPENDENCIES",
            )
        }
    }
}

flutter {
    source = "../.."
}
