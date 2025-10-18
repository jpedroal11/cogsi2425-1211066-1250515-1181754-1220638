1. This part will be done the analysis of aa Spring-boot project, that uses Maven as build tool, and convert it to a Gradle project.

````
git clone https://github.com/spring-guides/tut-rest.git
````

- Run the project with maven:

````

cd tut-rest-main
./mvnw spring-boot:run
````

2. Create a new directory called ca2-part2 and copy the files from tut-rest-main into it, except the .mvn directory and the mvnw and mvnw.cmd files.

````
mkdir ca2-part2
gradle init --type java-application
````
3. Copied the source files from tut-rest-main/links/src/ to ca2-part2/app/src/

```` 
rm -rf app/src
cp -r ../tut-rest-main/links/src app/src
````
3. Create a build.gradle file in the ca2-part2 directory with the following content:

````gradle
plugins {
    id 'org.springframework.boot' version '3.3.0'
    id 'io.spring.dependency-management' version '1.1.5'
    id 'java'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    // Spring Web (REST API)
    implementation 'org.springframework.boot:spring-boot-starter-web'

    // Spring Data JPA for repository support
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'

    // H2 in-memory database
    runtimeOnly 'com.h2database:h2'

    // Spring HATEOAS for hypermedia links
    implementation 'org.springframework.boot:spring-boot-starter-hateoas'

    // Spring Boot Test
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
````
 - The build script applies the necessary plugins for Spring Boot and Java, sets the Java toolchain to version 17, and includes dependencies for Spring Web, Spring Data JPA, H2 database, Spring HATEOAS, and Spring Boot Test.
 - The repositories block specifies Maven Central as the source for dependencies.
 - The test block configures the test task to use JUnit Platform.
 - The group and version properties define the project's group ID and version.

4. To build the project, open a terminal in the ca2-part2 directory and run:

````
./gradlew build
````
![img.png](img/gradle_spring_boot_build.png)

## Create a custom task named **deployToDev**

1. Create a directory called gradle and inside it create a file named deploy.gradle with the following content:

```gradle

def deployDir = "$buildDir/deployment/dev"
def libDir = "$deployDir/lib"
def jarFile = layout.buildDirectory.file("libs/${project.name}-${project.version}.jar")

tasks.register("cleanDevDeployment", Delete) {
    delete deployDir
}

tasks.register("copyAppJar", Copy) {
    dependsOn "jar"
    from jarFile
    into deployDir
    rename { "application.jar" }
}

tasks.register("copyRuntimeDeps", Copy) {
    dependsOn "jar"
    from configurations.runtimeClasspath
    into libDir
    exclude { it.file.name.contains(project.name) }
}

tasks.register("copyConfigFiles", Copy) {
    from("src/main/resources") {
        include "*.properties"
        expand([
                projectVersion: project.version,
                buildTimestamp: new Date().format("yyyy-MM-dd HH:mm:ss"),
                deploymentEnv: "dev"
        ])
    }
    into deployDir
}

tasks.register("deployToDev") {
    dependsOn "cleanDevDeployment", "copyAppJar", "copyRuntimeDeps", "copyConfigFiles"
    doLast {
        println "✅ Deployment completed to: $deployDir"
    }
}
```


The deployToDev task successfully automates the deployment process by executing four sequential steps:

#### Step 1: Clean Deployment Directory

- Action: Deletes the existing build/deployment/dev directory

- Purpose: Ensures a clean deployment environment

- Gradle Task Type: Built-in Delete functionality

```gradle
tasks.register("cleanDevDeployment", Delete) {
delete deployDir
}
```

#### Step 2: Copy Main Application Artifact

- Action: Copies the built JAR file to deployment directory

- Result: application.jar created in deployment folder

- Note: File is renamed from app-0.0.1-SNAPSHOT.jar to application.jar for standardization

```gradle
tasks.register("copyAppJar", Copy) {
    dependsOn "jar"
    from jarFile
    into deployDir
    rename { "application.jar" }
}

```


#### Step 3: Copy Runtime Dependencies

- Action: Copies all runtime dependencies to lib/ subdirectory

- Result: 58 dependency JARs copied (Spring Boot, Hibernate, H2 database, etc.)

- Configuration: Uses configurations.runtimeClasspath to get correct dependencies

- Exclusion: Filters out the main application JAR to avoid duplication

```gradle
tasks.register("copyRuntimeDeps", Copy) {
    dependsOn "jar"
    from configurations.runtimeClasspath
    into libDir
    exclude { it.file.name.contains(project.name) }
}
```

#### Step 4: Copy Configuration Files

- Result: "No properties files found to copy" - This is expected since the application uses Spring Boot's auto-configuration and doesn't have custom .properties files

```gradle
tasks.register("copyConfigFiles", Copy) {
    from("src/main/resources") {
        include "*.properties"
        expand([
                projectVersion: project.version,
                buildTimestamp: new Date().format("yyyy-MM-dd HH:mm:ss"),
                deploymentEnv: "dev"
        ])
    }
    into deployDir
}
```

#### Step 5: Final Deployment Task
- Action: Defines the main deployToDev task that depends on all previous steps
- Completion Message: Prints a success message with deployment path

```gradle
tasks.register("deployToDev") {
    dependsOn "cleanDevDeployment", "copyAppJar", "copyRuntimeDeps", "copyConfigFiles"
    doLast {
        println "✅ Deployment completed to: $deployDir"
    }
}
```

#### Step 6: Add the following line to the build.gradle file to apply the deploy.gradle script:

```gradle
apply from: 'gradle/deploy.gradle'
```

#### Step 7: Run the deployToDev task from the terminal:

```bash
./gradlew deployToDev
```
#### Output

    ```pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> ./gradlew deployToDev

    > Task :app:deployToDev
    Starting deployment to: /Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/app/build/deployment/dev
    Copied application JAR
    Copied runtime dependencies
    No properties files found to copy
    Deployment completed successfully to: /Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/app/build/deployment/dev

    Deployment Summary:
        /application.jar
        /lib/spring-tx-6.1.8.jar
        /lib/spring-jdbc-6.1.8.jar
        /lib/spring-plugin-core-3.0.0.jar
        /lib/spring-aspects-6.1.8.jar
        /lib/spring-boot-starter-jdbc-3.3.0.jar
        /lib/jakarta.persistence-api-3.1.0.jar
        /lib/txw2-4.0.5.jar
        /lib/logback-classic-1.5.6.jar
        /lib/snakeyaml-2.2.jar
        /lib/jul-to-slf4j-2.0.13.jar
        /lib/spring-boot-starter-3.3.0.jar
        /lib/jakarta.inject-api-2.0.1.jar
        /lib/spring-boot-starter-tomcat-3.3.0.jar
        /lib/tomcat-embed-el-10.1.24.jar
        /lib/spring-boot-starter-web-3.3.0.jar
        /lib/jackson-core-2.17.1.jar
        /lib/spring-boot-starter-hateoas-3.3.0.jar
        /lib/h2-2.2.224.jar
        /lib/asm-9.6.jar
        /lib/spring-boot-starter-aop-3.3.0.jar
        /lib/spring-data-commons-3.3.0.jar
        /lib/spring-webmvc-6.1.8.jar
        /lib/micrometer-observation-1.13.0.jar
        /lib/spring-aop-6.1.8.jar
        /lib/byte-buddy-1.14.16.jar
        /lib/spring-hateoas-2.3.0.jar
        /lib/jandex-3.1.2.jar
        /lib/classmate-1.7.0.jar
        /lib/hibernate-core-6.5.2.Final.jar
        /lib/jakarta.transaction-api-2.0.1.jar
        /lib/spring-web-6.1.8.jar
        /lib/spring-boot-starter-logging-3.3.0.jar
        /lib/spring-boot-starter-json-3.3.0.jar
        /lib/jackson-databind-2.17.1.jar
        /lib/jackson-annotations-2.17.1.jar
        /lib/jakarta.activation-api-2.1.3.jar
        /lib/spring-boot-starter-data-jpa-3.3.0.jar
        /lib/spring-context-6.1.8.jar
        /lib/spring-orm-6.1.8.jar
        /lib/slf4j-api-2.0.13.jar
        /lib/micrometer-commons-1.13.0.jar
        /lib/tomcat-embed-websocket-10.1.24.jar
        /lib/HikariCP-5.1.0.jar
        /lib/spring-core-6.1.8.jar
        /lib/json-smart-2.5.1.jar
        /lib/jboss-logging-3.5.3.Final.jar
        /lib/spring-jcl-6.1.8.jar
        /lib/json-path-2.9.0.jar
        /lib/log4j-api-2.23.1.jar
        /lib/jackson-datatype-jsr310-2.17.1.jar
        /lib/log4j-to-slf4j-2.23.1.jar
        /lib/jaxb-runtime-4.0.5.jar
        /lib/jakarta.annotation-api-2.1.1.jar
        /lib/accessors-smart-2.5.1.jar
        /lib/spring-beans-6.1.8.jar
        /lib/aspectjweaver-1.9.22.jar
        /lib/jackson-datatype-jdk8-2.17.1.jar
        /lib/tomcat-embed-core-10.1.24.jar
        /lib/istack-commons-runtime-4.1.2.jar
        /lib/jakarta.xml.bind-api-4.0.2.jar
        /lib/antlr4-runtime-4.13.0.jar
        /lib/hibernate-commons-annotations-6.0.6.Final.jar
        /lib/jaxb-core-4.0.5.jar
        /lib/jackson-module-parameter-names-2.17.1.jar
        /lib/spring-boot-3.3.0.jar
        /lib/spring-expression-6.1.8.jar
        /lib/logback-core-1.5.6.jar
        /lib/spring-boot-autoconfigure-3.3.0.jar
        /lib/spring-data-jpa-3.3.0.jar
        /lib/angus-activation-2.0.2.jar

    [Incubating] Problems report is available at: file:///Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/build/reports/problems/problems-report.html

    Deprecated Gradle features were used in this build, making it incompatible with Gradle 10.

    You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

    For more on this, please refer to https://docs.gradle.org/9.1.0/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

    BUILD SUCCESSFUL in 461ms
    3 actionable tasks: 1 executed, 2 up-to-date
    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> ```


2. Create a custom task that depends on the javadoc task


The task successfully starts the Spring Boot application using the generated distribution scripts, demonstrating a production-like deployment approach. 
#### Step 1: Create a seperated file named run-dist.gradle inside the gradle directory with the following content:

```gradle
tasks.register("runFromDist") {
    dependsOn 'installDist'
    group = "application"
    description = "Runs the app using generated distribution scripts"

    doLast {
        def isWindows = System.getProperty("os.name").toLowerCase().contains("windows")
        def scriptDir = file("build/install/${project.name}/bin")
        def scriptFile = isWindows ?
                file("$scriptDir/${project.name}.bat") :
                file("$scriptDir/${project.name}")

        if (!scriptFile.exists()) {
            throw new RuntimeException("Distribution script not found at: $scriptFile")
        }

        println "Starting application from distribution..."
        println "Script: $scriptFile"
        println "=" * 50

        def command = isWindows ?
                ["cmd", "/c", scriptFile.absolutePath] :
                [scriptFile.absolutePath]

        def processBuilder = new ProcessBuilder(command)
        processBuilder.directory(scriptDir)
        processBuilder.inheritIO()

        def process = processBuilder.start()
        println "Application started with PID: ${process.pid()}"
        println "Access the app at http://localhost:8080/employees"

        // Keep it running until the process is terminated
        Thread.start {
            while (process.isAlive()) {
                Thread.sleep(1000)
            }
        }.join()
    }
}
```

#### Step 2: Add the following line to the build.gradle file to apply the run-dist.gradle script:

```gradle
apply from: 'gradle/run-dist.gradle'
```

```bash
./gradlew runFromDist
```

On the left terminal the **runFromDist** task is run and then to verify its actually running properly, I request to the API via curl is done.

![img.png](img/gradle_runFromDist_task.png)
*Left: Task execution showing successful startup with PID 63680*  
*Right: API verification returning employee data*

3. Create a custom task that depends on the javadoc task

#### Step 1: Create a seperated file named docs.gradle inside the gradle directory with the following content:

```gradle
tasks.register("packageJavadoc", Zip) {
    group = "documentation"
    description = "Generates and packages project Javadoc into a zip file."
    dependsOn "javadoc"
    from javadoc.destinationDir
    destinationDirectory = layout.buildDirectory.dir("docs")
    archiveFileName = "${project.name}-${project.version}-javadoc.zip"
    doLast {
        println "Javadoc packaged successfully at: ${destinationDirectory.get().asFile.absolutePath}"
    }
}
```

#### Step 2: Add the following line to the build.gradle file to apply the docs.gradle script and run it:

```gradle
apply from: 'gradle/docs.gradle'
```


```bash
./gradlew packageJavadoc
```


A custom Gradle task was created to automate the generation and packaging of project documentation. The task seamlessly integrates Javadoc generation with archival packaging, producing a distributable documentation ZIP file.

    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> ./gradlew packageJavadoc

    > Task :app:javadoc
    /Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/app/src/main/java/payroll/PayrollApplication.java:7: warning: no comment
    public class PayrollApplication {
        ^
    /Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/app/src/main/java/payroll/PayrollApplication.java:9: warning: no comment
            public static void main(String... args) {
                            ^
    2 warnings

    > Task :app:packageJavadoc
    Javadoc packaged: /Users/pedroleal/Desktop/ISEP/1semestre/COGSI/sprint1-git/cogsi2425-1211066-1250515-1181754/CA2/PART_2/ca2-part2/app/build/docs/app-0.0.1-SNAPSHOT-javadoc.zip

    BUILD SUCCESSFUL in 956ms
    3 actionable tasks: 2 executed, 1 up-to-date
*Note: The warnings are standard Javadoc reminders about missing code comments and do not affect the functionality of the generated documentation package.*

In order to check that it actually ran successfully:

    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> ls -la app/build/docs/app-0.0.1-SNAPSHOT-javadoc.zip
    -rw-r--r--  1 pedroleal  staff  79368 Oct 17 19:13 app/build/docs/app-0.0.1-SNAPSHOT-javadoc.zip
    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> 


4. Create a new source set for integration tests

#### Step 1: Add the folwing file  integration-tests.gradle inside the gradle directory with the following content:


```gradle
sourceSets {
    integrationTest {
        java.srcDir "src/integrationTest/java"
        resources.srcDir "src/integrationTest/resources"
        compileClasspath += sourceSets.main.output + sourceSets.test.output
        runtimeClasspath += sourceSets.main.output + sourceSets.test.output
    }
}

configurations {
    integrationTestImplementation.extendsFrom testImplementation
    integrationTestRuntimeOnly.extendsFrom testRuntimeOnly
}

dependencies {
    integrationTestImplementation 'org.junit.platform:junit-platform-launcher'
    integrationTestImplementation 'org.junit.jupiter:junit-jupiter-engine'
    integrationTestImplementation 'org.junit.jupiter:junit-jupiter-api'
}

tasks.register("integrationTest", Test) {
    description = "Runs integration tests."
    group = "verification"
    testClassesDirs = sourceSets.integrationTest.output.classesDirs
    classpath = sourceSets.integrationTest.runtimeClasspath
    shouldRunAfter test
    useJUnitPlatform()
    testLogging { events "passed", "failed" }
}

check.dependsOn integrationTest

```

#### Step 2: Add the following line to the build.gradle file to apply the integration-tests.gradle script and run it:

```gradle
apply from: 'gradle/integration-tests.gradle'
```

```bash
./gradlew integrationTest
```

A dedicated source set for integration tests was created to separate unit tests from broader integration tests. This configuration allows for comprehensive testing of Spring Boot components working together while maintaining clean test organization.

### **Integrantion tests**

    @SpringBootTest
    public class EmployeeIntegrationTest {
        
        @Autowired
        private ApplicationContext applicationContext;

        @Test
        public void contextLoads() {
            // Verify Spring context loads
            assertNotNull(applicationContext);
        }

        @Test
        public void mainApplicationBeanExists() {
            // Verify the main application class is in the context
            PayrollApplication mainApp = applicationContext.getBean(PayrollApplication.class);
            assertNotNull(mainApp);
        }
    }

#### **Test Summary**

 #### contextLoads() Test:

    Purpose: Verifies the complete Spring Boot application context initializes successfully

    What it validates: All Spring beans are properly configured, dependency injection works, no missing dependencies or configuration errors

    Importance: Ensures the application can start up without runtime failures

 #### mainApplicationBeanExists() Test:

    Purpose: Confirms the main application class is properly registered as a Spring bean

    What it validates: Spring Boot auto-configuration correctly detects and wires the main application class

    Importance: Verifies the core application component is available in the context

### Output

    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)> ./gradlew integrationTest

    > Task :app:integrationTest

    EmployeeIntegrationTest > contextLoads() PASSED

    EmployeeIntegrationTest > mainApplicationBeanExists() PASSED

    BUILD SUCCESSFUL in 2s
    3 actionable tasks: 1 executed, 2 up-to-date
    pedroleal@Pedros-MBP ~/D/I/1/C/s/c/C/P/ca2-part2 (ca2-part2)>
*Note: Note: The complete output includes detailed Spring Boot startup logs showing full application context initialization, JPA repository configuration, H2 database setup, and sample data loading. These details have been omitted for brevity.*

5. Update the Gradle build script to include code quality checks using Checkstyle

```gradle
plugins {
    id 'org.springframework.boot' version '3.3.0'
    id 'io.spring.dependency-management' version '1.1.5'
    id 'java'
    id 'application'
}

group = 'com.example'
version = '0.0.1-SNAPSHOT'

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.springframework.boot:spring-boot-starter-web'
    implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
    implementation 'org.springframework.boot:spring-boot-starter-hateoas'

    runtimeOnly 'com.h2database:h2'

    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

application {
    mainClass = 'payroll.PayrollApplication'
}

apply from: "gradle/deployment.gradle"
apply from: "gradle/run-dist.gradle"
apply from: "gradle/docs.gradle"
apply from: "gradle/integration-test.gradle"
// Default test configuration
test {
    useJUnitPlatform()
}

```

6. Tag the final commit with CA2_PART2_COMPLETED

```bash
git tag ca2-part2
git push origin ca2-part2
```
