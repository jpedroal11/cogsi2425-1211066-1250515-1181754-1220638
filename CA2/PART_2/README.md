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

