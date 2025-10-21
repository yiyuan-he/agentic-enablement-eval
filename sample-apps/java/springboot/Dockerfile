FROM maven:3.9-amazoncorretto-17 AS build

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

FROM amazoncorretto:17

WORKDIR /app

# Install curl for traffic generation
RUN yum install -y curl && yum clean all

COPY --from=build /app/target/springboot-app-1.0.0.jar app.jar
COPY generate-traffic.sh .

ENV PORT=8080
ENV SERVICE_NAME=java-springboot-app

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]
