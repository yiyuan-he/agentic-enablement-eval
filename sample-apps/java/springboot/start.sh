#!/bin/bash
set -e

# Set default environment variables
export PORT=${PORT:-8080}
export SERVICE_NAME=${SERVICE_NAME:-java-springboot-app}

# Build the application
mvn clean package -DskipTests

# Run the Spring Boot application
java -jar target/springboot-app-1.0.0.jar
