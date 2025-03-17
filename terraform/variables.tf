variable "aws_region" {
    description = "AWS region to deploy resources"
    type = string
    default = "us-east-2"
}

variable "environment" {
    description = "Environment name"
    type = string
    default = "dev"
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type = string
    default = "10.80.0.0/16"
}

variable "availability_zones" {
    description = "List of availability zones"
    type = list(string)
    default = ["us-east-2a", "us-east-2b"]
}

variable "instance_type" {
    description = "EC2 instance type for monitoring servers"
    type = string
    default = "t3.medium"
}

variable "key_name" {
    description = "SSH key name"
    type = string
    default = "MONITORING-ALERTING-SYSTEM-KEY"
}

variable "prometheus_retention_days" {
    description = "Prometheus data rention period in days"
    type = number
    default = 15
}

variable "grafana_admin_password" {
    description = "Grafana admin password (only used if not retrieved from SSM)"
    type = string
    default = "null"
    sensitive = true
}

variable "secrets_manager_grafana_password_name" {
    description = "Name of the AWS Secrets Manager secret for Grafana admin password"
    type = string
    default = "grafana-admin-password"
}