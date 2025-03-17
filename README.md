# DevOps Monitoring and Alerting System

A comprehensive cloud-native monitoring and alerting solution built on AWS using industry-standard open-source tools: Prometheus, Grafana, Alertmanager, and Loki.

## Overview

This project implements a production-ready monitoring infrastructure that provides:

- Metrics collection and storage (Prometheus)
- Data visualization and dashboards (Grafana)
- Intelligent alerting and notifications (Alertmanager)
- Log aggregation and analysis (Loki/Promtail)

The entire infrastructure is provisioned using Infrastructure as Code (Terraform) for repeatability and consistency across environments.

## Architecture

![Monitoring System Architecture](docs/architecture.png)

### Components

- **AWS Infrastructure**: VPC with public/private subnets, security groups, EC2 instances
- **Prometheus**: Time-series database for metrics collection and storage
- **Grafana**: Visualization platform for metrics and logs with customizable dashboards
- **Alertmanager**: Alert routing, grouping, and notification delivery system
- **Loki**: Log aggregation system designed to be cost-effective and highly available
- **Promtail**: Log collection agent that ships logs to Loki

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform v1.0 or later
- Git
- Docker and Docker Compose (for local testing)

## Deployment

### 1. Clone this repository

```bash
git clone https://github.com/your-username/monitoring-alerting-system.git
cd monitoring-alerting-system
```

### 2. Initialize Terraform

```bash
cd terraform
terraform init
```

### 3. Review and apply the Terraform plan

```bash
terraform plan
terraform apply
```

### 4. Deploy the monitoring stack

```bash
cd ..
./deploy-monitoring.sh
```

### 5. Access the monitoring interfaces

- **Grafana**: http://[EC2-IP]:3000
- **Prometheus**: http://[EC2-IP]:9090
- **Alertmanager**: http://[EC2-IP]:9093

Default login for Grafana:
- Username: admin
- Password: Retrieved from AWS Secrets Manager (see below)

```bash
aws secretsmanager get-secret-value --region [your-region] --secret-id monitoring/grafana/admin-password --query SecretString --output text | jq -r '.password'
```

## Features

### Metrics Collection

- System metrics (CPU, memory, disk, network)
- Application metrics (via Prometheus exporters)
- Custom metrics (via client libraries)

### Visualization

- Pre-configured dashboards for system monitoring
- Application-specific dashboards
- SLO/SLI tracking dashboards

### Alerting

- Pre-defined alert rules for common failure scenarios
- Multiple notification channels (email, Slack, PagerDuty)
- Alert grouping and routing

### Log Management

- Centralized log collection
- Log querying and visualization in Grafana
- Log-based alerting

## Security Considerations

- All sensitive credentials stored in AWS Secrets Manager
- Proper IAM roles and policies for least privilege access
- VPC with private subnets for monitoring components
- Security groups with fine-grained access control

## Maintenance

### Backup and Recovery

- Prometheus data retention configured to 15 days by default
- Grafana configurations for dashboards stored in version control

### Scaling

- Instructions for scaling horizontally in the docs/scaling.md file
- Guidance for handling increased metric volume

## Customization

- Adding new data sources: docs/adding-data-sources.md
- Creating custom dashboards: docs/custom-dashboards.md
- Configuring alerts: docs/alert-configuration.md

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- The Prometheus, Grafana, and Loki teams for their excellent open-source tools
- The DevOps community for best practices and inspiration
