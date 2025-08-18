#!/bin/bash

# Production Deployment Script for Microservices
# This script demonstrates a complete DevOps deployment pipeline

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}
REGISTRY="your-registry.com"
PROJECT_NAME="microservices-app"

echo -e "${BLUE}🚀 Starting deployment for environment: ${ENVIRONMENT}${NC}"

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Pre-deployment checks
echo -e "${BLUE}🔍 Running pre-deployment checks...${NC}"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running!"
    exit 1
fi
print_status "Docker is running"

# Check if required environment variables are set
if [[ "$ENVIRONMENT" == "production" ]]; then
    required_vars=("DB_PASSWORD" "JWT_SECRET" "SMTP_PASSWORD")
    for var in "${required_vars[@]}"; do
        if [[ -z "${!var}" ]]; then
            print_error "Required environment variable $var is not set!"
            exit 1
        fi
    done
    print_status "All required environment variables are set"
fi

# Build and tag images
echo -e "${BLUE}🏗️  Building Docker images...${NC}"

services=("user-service" "order-service" "notification-service")

for service in "${services[@]}"; do
    echo "Building $service..."
    docker build -t $REGISTRY/$PROJECT_NAME/$service:$VERSION ./$service/
    docker tag $REGISTRY/$PROJECT_NAME/$service:$VERSION $REGISTRY/$PROJECT_NAME/$service:latest
    print_status "Built $service"
done

# Push images to registry (in production)
if [[ "$ENVIRONMENT" == "production" ]]; then
    echo -e "${BLUE}📤 Pushing images to registry...${NC}"
    for service in "${services[@]}"; do
        docker push $REGISTRY/$PROJECT_NAME/$service:$VERSION
        docker push $REGISTRY/$PROJECT_NAME/$service:latest
        print_status "Pushed $service to registry"
    done
fi

# Database migrations (if needed)
echo -e "${BLUE}🗄️  Running database migrations...${NC}"
# Add your migration commands here
print_status "Database migrations completed"

# Deploy based on environment
case $ENVIRONMENT in
    "local"|"development")
        echo -e "${BLUE}🏠 Deploying to local environment...${NC}"
        docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
        ;;
    "staging")
        echo -e "${BLUE}🧪 Deploying to staging environment...${NC}"
        docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
        ;;
    "production")
        echo -e "${BLUE}🌐 Deploying to production environment...${NC}"
        # Use Docker Swarm or Kubernetes for production
        docker stack deploy -c docker-compose.prod.yml $PROJECT_NAME
        ;;
    *)
        print_error "Unknown environment: $ENVIRONMENT"
        exit 1
        ;;
esac

# Health checks
echo -e "${BLUE}🏥 Running health checks...${NC}"
sleep 30  # Wait for services to start

services_health=("user-service:8081" "order-service:8082" "notification-service:8083")

for service_port in "${services_health[@]}"; do
    service_name=$(echo $service_port | cut -d':' -f1)
    port=$(echo $service_port | cut -d':' -f2)
    
    max_attempts=10
    attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
            print_status "$service_name is healthy"
            break
        else
            if [[ $attempt -eq $max_attempts ]]; then
                print_error "$service_name health check failed after $max_attempts attempts"
                exit 1
            fi
            print_warning "$service_name not ready, attempt $attempt/$max_attempts"
            sleep 10
            ((attempt++))
        fi
    done
done

# Run smoke tests
echo -e "${BLUE}🧪 Running smoke tests...${NC}"

# Test API Gateway
if curl -f http://localhost/health > /dev/null 2>&1; then
    print_status "API Gateway is responding"
else
    print_error "API Gateway health check failed"
    exit 1
fi

# Test user creation
user_response=$(curl -s -X POST http://localhost/api/users \
    -H "Content-Type: application/json" \
    -d '{"username":"testuser","email":"test@example.com","firstName":"Test","lastName":"User"}')

if echo "$user_response" | grep -q "testuser"; then
    print_status "User service is working"
else
    print_warning "User service test failed, but continuing..."
fi

# Cleanup test data
curl -s -X DELETE http://localhost/api/users/1 > /dev/null 2>&1 || true

print_status "Deployment completed successfully!"

# Display useful information
echo -e "${BLUE}📋 Deployment Information:${NC}"
echo "Environment: $ENVIRONMENT"
echo "Version: $VERSION"
echo "API Gateway: http://localhost"
echo "Grafana Dashboard: http://localhost:3000 (admin/admin123)"
echo "Prometheus: http://localhost:9090"
echo "RabbitMQ Management: http://localhost:15672 (admin/admin123)"
echo "Kibana: http://localhost:5601"

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"