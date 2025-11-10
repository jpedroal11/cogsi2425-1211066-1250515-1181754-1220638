FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY gradle_basic_demo-main/build/libs/basic_demo-0.1.0.jar app.jar

EXPOSE 59001

CMD ["java", "-cp", "app.jar", "basic_demo.ChatServerApp", "59001"]
