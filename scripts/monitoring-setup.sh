#!/bin/bash

# Monitoring Setup Script
# Sets up comprehensive monitoring for the microservices

set -e

echo "🔧 Setting up monitoring infrastructure..."

# Create monitoring directories
mkdir -p monitoring/grafana/dashboards
mkdir -p monitoring/grafana/datasources
mkdir -p monitoring/logstash/config
mkdir -p nginx/logs

# Set permissions
chmod +x scripts/*.sh

# Create Grafana dashboard for microservices
cat > monitoring/grafana/dashboards/microservices-dashboard.json << 'EOF'
{
  "dashboard": {
    "id": null,
    "title": "Microservices Dashboard",
    "tags": ["microservices"],
    "timezone": "browser",
    "panels": [
      {
        "title": "Service Health",
        "type": "stat",
        "targets": [
          {
            "expr": "up{job=~\"user-service|order-service|notification-service\"}",
            "legendFormat": "{{job}}"
          }
        ]
      },
      {
        "title": "Request Rate",
        "type": "graph",
        "targets": [
          {
            "expr": "rate(http_requests_total[5m])",
            "legendFormat": "{{job}} - {{method}}"
          }
        ]
      },
      {
        "title": "Response Time",
        "type": "graph",
        "targets": [
          {
            "expr": "histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))",
            "legendFormat": "95th percentile"
          }
        ]
      }
    ],
    "time": {
      "from": "now-1h",
      "to": "now"
    },
    "refresh": "5s"
  }
}
EOF

echo "✅ Monitoring setup completed!"
echo "📊 Access Grafana at: http://localhost:3000"
echo "📈 Access Prometheus at: http://localhost:9090"
echo "🔍 Access Kibana at: http://localhost:5601"