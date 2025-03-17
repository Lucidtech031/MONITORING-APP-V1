#!/bin/bash
set -e

# This script deploys the monitoring stack to the EC2 instance
EC2_IP=$(terraform -chdir=./terraform output -raw monitoring_server_public_ip)

echo "Deploying monitoring stack to $EC2_IP..."

# Create directories for configuration files
ssh ec2-user@$EC2_IP "mkdir -p /opt/monitoring/{prometheis,alertmanager,grafana,loki,promtail}"

# Copy configuration files
scp -r ./prometheus/* ec2-user@$EC2_IP:/opt/monitoring/prometheus/
scp -r ./alertmanager/* ec2-user@$EC2_IP:/opt/monitoring/alertmanager/
scp -r ./grafana/* ec2-user@$EC2_IP:/opt/monitoring/grafana/
scp -r ./loki/* ec2-user@$EC2_IP:/opt/monitoring/loki/
scp -r ./promtail/* ec2-user@$EC2_IP:/opt/monitoring/promtail/
scp ./docker-compose/docker-compose.yml ec2-user@$EC2_IP:/opt/monitoring/

# Start the monitoring stack
ssh ec2-user@$EC2_IP "cd /opt/monitoring && docker-compose up -d"

echo "Monitoring stack depolyed successfully!"
echo "Grafana UI: https://$EC2_IP:3000"
echo "Prometheus UI: http://$EC2_IP:9090"
echo "Login to Grafana with username 'admin' and the password stroed in AWS Secrets Manager"

