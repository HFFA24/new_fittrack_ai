import org.gradle.api.tasks.Delete
import java.util.Locale

// ✅ Unified plugin versions – ensure consistency
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
}

// ✅ Repositories for all modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom build directory for the whole project
val newRootBuildDir = layout.buildDirectory.dir("../../build").get()
layout.buildDirectory.set(newRootBuildDir)

// ✅ Custom build directories per subproject
subprojects {
    val newSubprojectBuildDir = rootProject.layout.buildDirectory.dir(name).get()
    layout.buildDirectory.set(newSubprojectBuildDir)

    evaluationDependsOn(":app")

    // Optional namespace setup (commented out unless needed)
    /*
    afterEvaluate {
        plugins.configureEach {
            val pluginName = javaClass.name
            if (pluginName.startsWith("com.android.build.gradle.")) {
                val androidExt = extensions.findByName("android")
                if (androidExt is com.android.build.gradle.BaseExtension) {
                    if (androidExt.namespace == null) {
                        val safeName = name.lowercase(Locale.getDefault()).replace("-", "_")
                        androidExt.namespace = "com.example.$safeName"
                        println("✅ Assigned namespace to $name: ${androidExt.namespace}")
                    }
                }
            }
        }
    }
    */
}

// ✅ Clean task to delete all build output
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
