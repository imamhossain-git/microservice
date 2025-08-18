# Production-Grade Microservices Architecture

A comprehensive microservices application demonstrating real-world DevOps practices, inter-service communication, and production deployment strategies.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   API Gateway   │    │   Monitoring    │    │    Logging      │
│   (Nginx)       │    │  (Prometheus)   │    │     (ELK)       │
│   Port 80/443   │    │   Port 9090     │    │   Port 5601     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Network                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │User Service │  │Order Service│  │ Notification Service    │  │
│  │Port 8081    │  │Port 8082    │  │ Port 8083               │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│         │                 │                      │              │
│         ▼                 ▼                      ▼              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐  │
│  │PostgreSQL   │  │PostgreSQL   │  │      RabbitMQ           │  │
│  │(User DB)    │  │(Order DB)   │  │   Message Queue         │  │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘  │
│         │                                      │              │
│         ▼                                      ▼              │
│  ┌─────────────┐                    ┌─────────────────────────┐  │
│  │   Redis     │                    │       Grafana           │  │
│  │  (Cache)    │                    │    (Visualization)      │  │
│  └─────────────┘                    └─────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## 🚀 Services Overview

### 1. User Service (Port 8081)
- **Purpose**: User management, authentication, and authorization
- **Database**: PostgreSQL with Redis caching
- **Features**:
  - JWT-based authentication
  - User CRUD operations
  - Password encryption
  - Session management with Redis
  - Rate limiting and security headers

### 2. Order Service (Port 8082)
- **Purpose**: Order management and business logic
- **Database**: PostgreSQL
- **Communication**: 
  - HTTP calls to User Service for user validation
  - RabbitMQ messages to Notification Service
- **Features**:
  - Circuit breaker pattern (Resilience4j)
  - Async messaging
  - Order lifecycle management
  - Integration with external services

### 3. Notification Service (Port 8083)
- **Purpose**: Handle all notifications (email, SMS, push)
- **Communication**: RabbitMQ message consumer
- **Features**:
  - Email notifications via SMTP
  - Message queue processing
  - Template-based notifications
  - Delivery status tracking

## 🔄 Inter-Service Communication

### Synchronous Communication (HTTP/REST)
```
Order Service → User Service
GET /api/users/{userId}
```
- Used for real-time data validation
- Circuit breaker pattern for fault tolerance
- Timeout and retry mechanisms

### Asynchronous Communication (Message Queue)
```
Order Service → RabbitMQ → Notification Service
```
- Event-driven architecture
- Decoupled services
- Guaranteed message delivery
- Dead letter queues for failed messages

### Communication Flow Example:
1. **User places an order** → Order Service
2. **Order Service validates user** → User Service (HTTP)
3. **Order Service creates order** → Database
4. **Order Service publishes event** → RabbitMQ
5. **Notification Service consumes event** → Sends email

## 🐳 Docker Deployment Strategy

### Development Environment
```bash
# Quick start for development
docker-compose up --build
```

### Staging Environment
```bash
# Deploy to staging with monitoring
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
```

### Production Environment
```bash
# Production deployment with all monitoring
./scripts/deploy.sh production v1.0.0
```

## 📊 Production-Grade Features

### 1. Monitoring & Observability
- **Prometheus**: Metrics collection
- **Grafana**: Visualization dashboards
- **ELK Stack**: Centralized logging
- **Health checks**: Service health monitoring
- **Custom metrics**: Business metrics tracking

### 2. Security
- **JWT Authentication**: Secure token-based auth
- **Rate Limiting**: API protection
- **CORS Configuration**: Cross-origin security
- **Security Headers**: XSS, CSRF protection
- **Database Security**: Connection encryption

### 3. Scalability & Reliability
- **Load Balancing**: Nginx upstream configuration
- **Circuit Breakers**: Fault tolerance
- **Database Connection Pooling**: Resource optimization
- **Caching**: Redis for performance
- **Message Queues**: Async processing

### 4. DevOps Best Practices
- **Multi-stage Docker builds**: Optimized images
- **Health checks**: Container orchestration
- **Environment-specific configs**: Dev/Staging/Prod
- **Automated deployments**: CI/CD ready
- **Infrastructure as Code**: Docker Compose

## 🚀 Quick Start Guide

### Prerequisites
- Docker & Docker Compose
- 8GB+ RAM recommended
- Ports 80, 3000, 5601, 9090, 15672 available

### 1. Clone and Setup
```bash
git clone <repository>
cd microservices-app
chmod +x scripts/*.sh
```

### 2. Environment Configuration
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

### 3. Deploy Application
```bash
# Development deployment
docker-compose up --build -d

# Or use deployment script
./scripts/deploy.sh local
```

### 4. Verify Deployment
```bash
# Check service health
curl http://localhost/health

# Check individual services
curl http://localhost/health/user
curl http://localhost/health/order
curl http://localhost/health/notification
```

## 📋 API Documentation

### User Service Endpoints
```
POST   /api/auth/login          # User authentication
POST   /api/auth/register       # User registration
GET    /api/users               # List users (paginated)
GET    /api/users/{id}          # Get user by ID
PUT    /api/users/{id}          # Update user
DELETE /api/users/{id}          # Delete user
```

### Order Service Endpoints
```
GET    /api/orders              # List orders
POST   /api/orders              # Create order
GET    /api/orders/{id}         # Get order details
PUT    /api/orders/{id}/status  # Update order status
DELETE /api/orders/{id}         # Cancel order
```

### Notification Service Endpoints
```
GET    /api/notifications       # List notifications
POST   /api/notifications/send  # Send notification
GET    /api/notifications/{id}  # Get notification status
```

## 🔧 Configuration Management

### Environment Variables
```bash
# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=microservices
DB_USERNAME=postgres
DB_PASSWORD=secure_password

# Redis Configuration
REDIS_HOST=localhost
REDIS_PORT=6379

# RabbitMQ Configuration
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
RABBITMQ_USERNAME=admin
RABBITMQ_PASSWORD=admin123

# JWT Configuration
JWT_SECRET=your-super-secret-key
JWT_EXPIRATION=86400000

# SMTP Configuration
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
```

### Service Discovery
Services communicate using Docker's internal DNS:
- `user-service:8080`
- `order-service:8080`
- `notification-service:8080`

## 📈 Monitoring & Alerting

### Access Monitoring Tools
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Kibana**: http://localhost:5601
- **RabbitMQ Management**: http://localhost:15672 (admin/admin123)

### Key Metrics to Monitor
- **Service Health**: Up/Down status
- **Request Rate**: Requests per second
- **Response Time**: 95th percentile latency
- **Error Rate**: 4xx/5xx responses
- **Database Connections**: Pool utilization
- **Queue Depth**: Message backlog

### Alerting Rules (Prometheus)
```yaml
groups:
  - name: microservices
    rules:
      - alert: ServiceDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Service {{ $labels.job }} is down"
      
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 2m
        labels:
          severity: warning
        annotations:
          summary: "High error rate on {{ $labels.job }}"
```

## 🧪 Testing Strategy

### Unit Tests
```bash
# Run tests for each service
cd user-service && mvn test
cd order-service && mvn test
cd notification-service && mvn test
```

### Integration Tests
```bash
# Test service communication
./scripts/integration-tests.sh
```

### Load Testing
```bash
# Use Apache Bench for load testing
ab -n 1000 -c 10 http://localhost/api/users
```

## 🔄 CI/CD Pipeline

### GitHub Actions Example
```yaml
name: Deploy Microservices
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build and Deploy
        run: |
          ./scripts/deploy.sh production ${{ github.sha }}
```

### Jenkins Pipeline
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh './scripts/build.sh'
            }
        }
        stage('Test') {
            steps {
                sh './scripts/test.sh'
            }
        }
        stage('Deploy') {
            steps {
                sh './scripts/deploy.sh production'
            }
        }
    }
}
```

## 🛠️ Troubleshooting

### Common Issues

1. **Services not starting**
   ```bash
   # Check logs
   docker-compose logs user-service
   
   # Check resource usage
   docker stats
   ```

2. **Database connection issues**
   ```bash
   # Check database health
   docker-compose exec user-db pg_isready
   
   # Check connection from service
   docker-compose exec user-service curl user-db:5432
   ```

3. **Message queue issues**
   ```bash
   # Check RabbitMQ status
   docker-compose exec rabbitmq rabbitmq-diagnostics ping
   
   # Check queue depth
   curl -u admin:admin123 http://localhost:15672/api/queues
   ```

### Performance Tuning

1. **JVM Optimization**
   ```bash
   # Adjust heap size based on container memory
   JAVA_OPTS="-Xmx1g -Xms512m -XX:+UseG1GC"
   ```

2. **Database Optimization**
   ```sql
   -- Add indexes for frequently queried columns
   CREATE INDEX idx_user_email ON users(email);
   CREATE INDEX idx_order_user_id ON orders(user_id);
   ```

3. **Nginx Optimization**
   ```nginx
   # Increase worker connections
   worker_connections 2048;
   
   # Enable caching
   proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=api_cache:10m;
   ```

## 📚 Learning Resources

### DevOps Concepts Demonstrated
- **Containerization**: Docker multi-stage builds
- **Orchestration**: Docker Compose
- **Service Mesh**: Inter-service communication
- **Monitoring**: Observability stack
- **Security**: Authentication, authorization, secrets
- **Scalability**: Load balancing, caching
- **Reliability**: Circuit breakers, health checks

### Next Steps for Production
1. **Kubernetes Migration**: Container orchestration
2. **Service Mesh**: Istio for advanced traffic management
3. **GitOps**: ArgoCD for deployment automation
4. **Security Scanning**: Container and dependency scanning
5. **Backup Strategy**: Database and configuration backups

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**This is a production-grade example designed for learning DevOps practices. Each component demonstrates real-world patterns and can be adapted for actual production use.**