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
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    tasks.withType<JavaCompile>().configureEach {
        // Flutter plugins still target Java 8. Keep their bytecode contract while
        // suppressing only javac's obsolete source/target option warnings.
        doFirst {
            if (JavaVersion.toVersion(sourceCompatibility) == JavaVersion.VERSION_1_8 &&
                JavaVersion.toVersion(targetCompatibility) == JavaVersion.VERSION_1_8
            ) {
                options.compilerArgs.add("-Xlint:-options")
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
