# Stage 1: Build
FROM eclipse-temurin:17-jdk AS builder

WORKDIR /app

# Copy project source into the container
COPY gradle_basic_demo-main /app

# Make Gradle wrapper executable
RUN chmod +x ./gradlew

# Build the project
RUN ./gradlew clean build -x test

# Stage 2: Runtime
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copy only the built JAR from the builder stage
COPY --from=builder /app/build/libs/basic_demo-0.1.0.jar app.jar

EXPOSE 59001

# Run the server
CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
