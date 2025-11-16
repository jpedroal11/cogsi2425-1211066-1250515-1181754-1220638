FROM eclipse-temurin:17-jre-alpine

ENV H2_VERSION=2.2.224

RUN apk add --no-cache netcat-openbsd

RUN wget https://repo1.maven.org/maven2/com/h2database/h2/${H2_VERSION}/h2-${H2_VERSION}.jar -O /opt/h2.jar

RUN mkdir -p /opt/h2-data

EXPOSE 8082 9092

WORKDIR /opt


CMD ["java", "-cp", "/opt/h2.jar", "org.h2.tools.Server", \
     "-tcp", "-tcpAllowOthers", "-tcpPort", "9092", \
     "-web", "-webAllowOthers", "-webPort", "8082", \
     "-baseDir", "/opt/h2-data", \
     "-ifNotExists"]