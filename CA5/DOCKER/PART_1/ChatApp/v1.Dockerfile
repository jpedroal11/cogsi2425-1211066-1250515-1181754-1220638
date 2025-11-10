FROM eclipse-temurin:17-jdk AS builder

RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/jpedroal11/cogsi2425-1211066-1250515-1181754-1220638.git .

WORKDIR /app/CA2/PART_1/gradle_basic_demo-main

RUN chmod +x ./gradlew

RUN ./gradlew clean build -x test

FROM eclipse-temurin:17-jdk

WORKDIR /app

COPY --from=builder /app/CA2/PART_1/gradle_basic_demo-main /app

EXPOSE 59001

CMD ["./gradlew", "runServer"]
