plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.iwms_citizen_app" // Using your new namespace
    compileSdk = 34 // Use a modern compile SDK
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // --- FIX: Set to Java 1.8 for compatibility ---
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8" // --- FIX ---
    }

    defaultConfig {
        applicationId = "com.example.iwms_citizen_app"
        minSdk = 21 // <-- CRITICAL FIX for older packages
        targetSdk = 34 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true // <-- CRITICAL FIX
    }

    buildTypes {
        release {
            // Configure your signing configs here
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
     implementation("androidx.multidex:multidex:2.0.1") // <-- CRITICAL FIX
}

