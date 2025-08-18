# Multi-stage Docker build for Spring Boot application
FROM openjdk:17-jdk-slim as build

# Set working directory
WORKDIR /app

# Copy Maven files
COPY pom.xml .
COPY src src

# Install Maven
RUN apt-get update && apt-get install -y maven

# Build the application
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:17-jre-slim

# Create app user
RUN addgroup --system spring && adduser --system spring --ingroup spring

# Set working directory
WORKDIR /app

# Copy the built JAR file
COPY --from=build /app/target/*.jar app.jar

# Change ownership
RUN chown -R spring:spring /app
USER spring:spring

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/api/users/health || exit 1

# Expose port
EXPOSE 8080

# Set JVM options
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Run the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar app.jar"]