plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.user_login" // Ensure this matches your package name
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        // CRITICAL FIX 1: Set source/target to Java 17 for stability with modern libraries
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.example.user_login"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // CRITICAL FIX 2: Enable MultiDex for apps with many dependencies (Bloc, Map, etc.)
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            // 🟢 CRITICAL FIX: Removed the line below.
            // DO NOT use debug signing in a release build. 
            // You must now configure a proper release signing key separately 
            // (typically via `key.properties` and the `signingConfigs` block)
        }
    }
}

flutter {
    source = "../.."
}

// CRITICAL FIX 3: Add the MultiDex dependency
dependencies {
    // This library is required to enable multidex support
    implementation("androidx.multidex:multidex:2.0.1") 
}
