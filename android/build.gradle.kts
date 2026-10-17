import com.android.build.gradle.BaseExtension
import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    val projectRoot = project.projectDir.absoluteFile.toPath().root
    val buildRoot = newSubprojectBuildDir.asFile.absoluteFile.toPath().root
    // Plugin no cache do Pub em outro disco fica no build local. O AGP
    // relativiza o caminho do projeto e do build e falha entre raízes diferentes.
    if (projectRoot == buildRoot) {
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }

    afterEvaluate {
        // Plugins ainda declaram Java 8. O afterEvaluate alinha o bytecode com o Java 17 do app.
        extensions.findByType<BaseExtension>()?.apply {
            compileOptions {
                sourceCompatibility = JavaVersion.VERSION_17
                targetCompatibility = JavaVersion.VERSION_17
            }
        }

        tasks.withType<KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(JvmTarget.JVM_17)
            }
        }

        // O lint do AGP 9.1 nao carrega classes do compilador Kotlin.
        // assembleRelease depende de lintVitalAnalyzeRelease e para nesse ponto.
        tasks.configureEach {
            if (name.contains("lintVital") || name.contains("lintAnalyze")) {
                enabled = false
            }
        }
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
