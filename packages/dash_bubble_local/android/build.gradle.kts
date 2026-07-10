group = "dev.moaz.dash_bubble"  
version = "2.0.0"  
  
plugins {  
    id("com.android.library")  
    id("kotlin-android")  
}  
  
android {  
    namespace = "dev.moaz.dash_bubble"  
    compileSdk = 34  
      
    compileOptions {  
        sourceCompatibility = JavaVersion.VERSION_17  
        targetCompatibility = JavaVersion.VERSION_17  
    }  
      
    buildFeatures {  
        buildConfig = false  
    }  
      
    defaultConfig {  
        minSdk = 21  
    }  
      
    sourceSets {  
        named("main") {  
            kotlin.srcDirs("src/main/kotlin")  
        }  
    }  
      
    lint {  
        abortOnError = false  
        checkReleaseBuilds = false  
    }  
}  
  
kotlin {  
    jvmToolchain(17)  
}  
  
dependencies {  
    implementation("androidx.core:core:1.10.1")  
    implementation("androidx.appcompat:appcompat:1.6.1")  
}  
