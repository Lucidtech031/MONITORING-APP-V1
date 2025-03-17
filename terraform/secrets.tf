# Creates a random passford for Grafana if one is not provided
resource "random_password" "grafana_password" {
    length = 16
    special = true
    override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Create an AWS Secrets Manager secret for Grafana admin password
resource "aws_secretsmanager_secret" "grafana_admin_password" {
    name = var.secrets_manager_grafana_password_name
    description = "Grafana admin password for ${var.environment} environment"

    tags = {
        Environment = var.environment
        Service = "Grafana"
    }
}

# Store the password in AWS Secrets Manager
resource "aws_secretsmanager_secret_version" "grafana_admin_password" {
    secret_id = aws_secretsmanager_secret.grafana_admin_password.id
    secret_string = jsonencode ({
        username = "admin"
        password = var.grafana_admin_password != null ? var.grafana_admin_password : random_password.grafana_password.result
    })
}

# Grant permissions for EC2 instance to access the secret
resource "aws_iam_role" "monitoring_server_role" {
    name = "${var.environment}-monitoring-server-role"

    assume_role_policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
            }
        ]
    })

    tags = {
        Name = "${var.environment}-monitoring-server-role"
    }
}

resource "aws_iam_instance_profile" "monitoring_server_profile" {
    name = "${var.environment}-monitoring-server-profile"
    role = aws_iam_role.monitoring_server_role.name
}
resource "aws_iam_policy" "secrets_access_policy" {
    name = "secrets-access-policy"
    policy = jsonencode ({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret"
                ]
                Effect = "Allow"
                Resource = aws_secretsmanager_secret.grafana_admin_password.arn
            }
        ]
    })
}

# Output the secret ARN
output "grafana_admin_password_secret_arn" {
    description = "ARN of the  Grafana admin password secret"
    value = aws_secretsmanager_secret.grafana_admin_password.arn
    sensitive = true
}

# Generate a password policy reminder output
output "password_policy_reminder" {
    description = "Reminder to rotate the Grafana admin password periodically"
    value = "Remember to rotate the Grafana admin password every 90 days for security best practices"
}
