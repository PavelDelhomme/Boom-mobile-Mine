plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

dependencies {
    implementation("androidx.window:window-java:1.2.0")
    implementation("androidx.window:window:1.2.0")
    implementation("androidx.core:core-ktx:1.12.0")
}

android {
    namespace = "com.example.boom_mobile"
    //compileSdk = 34 // Pour déploieemt sur blackview
    //compileSdk = 35 // Pour déploieemt sur plus receent (supérieur à 35)
    compileSdk = 36
    //compileSdk = flutter.compileSdkVersion
    //ndkVersion = "25.2.9519653" // Version compatible
    ndkVersion = "27.0.12077973" // Version compatible pour Sdk supérieur à 35
    //ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.boom_mobile"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        //minSdk = flutter.minSdkVersion
        minSdk = 28 // Définition pour déploiement sur blackview
        //targetSdk = flutter.targetSdkVersion
        //targetSdk = 34 // Définition pour déploiement sur backview
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Ajout pour éviter les conflits de permissions
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")

            // Optimisations pour release
            isMinifyEnabled = false
            isShrinkResources = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            //isDebuggable = false
        }
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }

    // Configuration pour éviter les warnings
    lint {
        disable += "InvalidPackage"
        checkReleaseBuilds = false
    }
}

flutter {
    source = "../.."
}