output "vpc_id" {
    description = "ID of the VPC"
    value = aws_vpc.monitoring_vpc.id
}

output "monitoring_server_public_ip" {
    description = "Public IP address of the monitoring server"
    value = aws_eip.monitoring_eip.public_ip
}

output "monitoring_server_id" {
    description = "Instance ID of the monitoring server"
    value = aws_instance.monitoring_server.id
}

output "ssh_connection_string" {
    description = "SSH connection string for the monitoring server"
    value = "ssh ec2-user@${aws_eip.monitoring_eip.public_ip}"
}

output "grafana_url" {
    description = "URL to access Grafana"
    value = "http://${aws_eip.monitoring_eip.public_ip}:3000"
}

output "prometheus_url" {
    description = "URL to access Prometheus"
    value = "http://${aws_eip.monitoring_eip.public_ip}:9090"
}