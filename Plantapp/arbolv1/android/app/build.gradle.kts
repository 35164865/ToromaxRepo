plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.arbolv1"
    compileSdk = 34  // Actualizado a la versión más reciente
    
    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // Solución clave
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.arbolv1"
        minSdk = 21
        targetSdk = 34  // Actualizado
        versionCode = flutter.versionCode?.toInt() ?: 1
        versionName = flutter.versionName ?: "1.0"
        multiDexEnabled = true
    }

    buildTypes {
    getByName("release") {
        // Desactiva ambas opciones
        isMinifyEnabled = false
        isShrinkResources = false
        signingConfig = signingConfigs.getByName("debug") // Usa la configuración de debug
    }
    getByName("debug") {
        isMinifyEnabled = false
        isShrinkResources = false
    }
}
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")  // Versión actualizada
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.9.22")  // Versión actualizada
}

flutter {
    source = "../.."
}