import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
}
val ciKeystoreFile = System.getenv("ANDROID_KEYSTORE_FILE")?.takeIf { it.isNotBlank() }

fun requiredSigningEnv(name: String): String =
    System.getenv(name)?.takeIf { it.isNotEmpty() }
        ?: error("Missing $name for Android release signing")

android {
    namespace = "com.oleksii_lemeshinskyi.url_launcher"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.oleksii_lemeshinskyi.url_launcher"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (ciKeystoreFile != null || keystorePropertiesFile.exists()) {
            create("release") {
                keyAlias = if (ciKeystoreFile != null) {
                    requiredSigningEnv("ANDROID_KEY_ALIAS")
                } else {
                    keystoreProperties["keyAlias"] as String
                }
                keyPassword = if (ciKeystoreFile != null) {
                    requiredSigningEnv("ANDROID_KEY_PASSWORD")
                } else {
                    keystoreProperties["keyPassword"] as String
                }
                storeFile = if (ciKeystoreFile != null) {
                    file(ciKeystoreFile)
                } else {
                    keystoreProperties["storeFile"]?.let { file(it as String) }
                }
                storePassword = if (ciKeystoreFile != null) {
                    requiredSigningEnv("ANDROID_STORE_PASSWORD")
                } else {
                    keystoreProperties["storePassword"] as String
                }
            }
        }
    }

    buildTypes {
        release {
            // Sign with key.properties when present, otherwise fall back to the
            // debug keys so `flutter run --release` keeps working.
            signingConfig = if (ciKeystoreFile != null || keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
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
