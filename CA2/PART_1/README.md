# Graddle

Gradle is a build automation tool used to compile, test, and package software projects, especially for Java, Kotlin, and other JVM-based languages.

It helps developers automate repetitive tasks like:

- Compiling source code

- Running tests

- Building executable files (like JARs)

- Managing dependencies (libraries your project needs)


## Overview Exercise


Build a multithreaded chat server in Java using Gradle.

- Server handles multiple clients, requiring unique screen names.

- Clients can send messages that are broadcast to all connected users.

- Use Gradle tasks to compile, run, and package the app:
- runClient → starts a client

Practice Gradle build automation, networking, and multithreading.


1. Read the README.md and replicate the steps

````
./gradlew build 
````

![img.png](img/gradle_build.png)

````

java -cp build/libs/basic_demo-0.1.0.jar basic_demo.ChatServerApp 59001

````


![img.png](img/gradle_running_server.png)

````
./gradlew runClient
````

![img.png](img/gradle_run_client.png)


The gradle client name

![img.png](img/gradle_client_name.png)


And two clients running:

![img.png](img/gradle_run_two_clients.png)


2. Add a runServer task











