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


