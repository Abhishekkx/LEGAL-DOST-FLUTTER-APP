plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Required imports for Properties and file handling
import java.util.Properties
        import java.io.FileInputStream

        android {
            namespace = "com.example.legal_dost" // Update to "legal_dost" if intended
            compileSdk = 35
            ndkVersion = "27.0.12077973"

            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_11
                targetCompatibility = JavaVersion.VERSION_11
            }

            kotlinOptions {
                jvmTarget = JavaVersion.VERSION_11.toString()
            }

            defaultConfig {
                applicationId = "com.example.legal_dost" // Update to "legal_dost" if intended
                minSdk = 23
                targetSdk = 35
                versionCode = flutter.versionCode
                versionName = flutter.versionName
            }

            // Load keystore properties from key.properties
            val keystorePropertiesFile = rootProject.file("key.properties")
            val keystoreProperties = Properties().apply {
                if (keystorePropertiesFile.exists()) {
                    load(FileInputStream(keystorePropertiesFile))
                }
            }

            signingConfigs {
                create("release") {
                    keyAlias = keystoreProperties["keyAlias"] as String?
                    keyPassword = keystoreProperties["keyPassword"] as String?
                    storeFile = keystoreProperties["storeFile"]?.let { rootProject.file(it) }
                    storePassword = keystoreProperties["storePassword"] as String?
                }
            }

            buildTypes {
                getByName("release") {
                    signingConfig = signingConfigs.getByName("release")
                }
            }
        }

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    implementation("com.google.firebase:firebase-analytics")
}