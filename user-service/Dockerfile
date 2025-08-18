# Multi-stage build for User Service
FROM openjdk:17-jdk-slim as build

WORKDIR /app
COPY pom.xml .
COPY src src

# Install Maven
RUN apt-get update && apt-get install -y maven curl

# Build the application
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:17-jre-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create app user for security
RUN addgroup --system spring && adduser --system spring --ingroup spring

WORKDIR /app

# Copy the built JAR
COPY --from=build /app/target/*.jar app.jar

# Change ownership
RUN chown -R spring:spring /app
USER spring:spring

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8080/actuator/health || exit 1

EXPOSE 8080

# JVM optimization for containers
ENV JAVA_OPTS="-Xmx512m -Xms256m -XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]