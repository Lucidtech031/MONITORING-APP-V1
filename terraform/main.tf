# Create a VPC for our monitoring infrastructure
resource "aws_vpc" "monitoring_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true
    
    tags = {
        Name = "${var.environment}-monitoring-vpc"
    }
}

# Create public subnets for load balancers and bastion hosts
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.monitoring_vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# Create private subnets for monitoring servers
resource "aws_subnet" "private_subnets" {
    count = length(var.availability_zones)
    vpc_id = aws_vpc.monitoring_vpc.id
    cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availability_zones))
    availability_zone = var.availability_zones[count.index]

    tags = {
        Name = "${var.environment}-private-subnet-${count.index + 1}"
    }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.monitoring_vpc.id

    tags = {
        Name = "${var.environment}-monitoring-igw"
    }
}

# Create a route table for public subnets
resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.monitoring_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
        Name = "${var.environment}-public-route-table"
    }
}

# Associate public subnets with the route table
resource "aws_route_table_association" "public_rta" {
    count = length(aws_subnet.public_subnets)
    subnet_id = aws_subnet.public_subnets[count.index].id
    route_table_id = aws_route_table.public_rt.id
}

# Create a security group for monitoring servers
resource "aws_security_group" "monitoring_sg" {
    name = "${var.environment}-monitoring-sg"
    description = "Security group for monitoring servers"
    vpc_id = aws_vpc.monitoring_vpc.id

    # SSH access
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["174.51.119.253/32"]
    }
    # Prometheus access
    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    # Grafana access
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = ["10.0.0.24/32"]
    }

    # Alertmanager access
    ingress {
        from_port = 9093
        to_port = 9093
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    # Loki access
    ingress {
        from_port = 3100
        to_port = 3100
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    # Allow all outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-monitoring-sg"
    }
}
resource "aws_eip" "monitoring_eip" {
    instance = aws_instance.monitoring_server.id
    domain = "vpc"

    tags = {
        Name = "${var.environment}-monitoring-eip"
    }
}

# Create an EC2 instance for monitoring infrastructure
resource "aws_instance" "monitoring_server" {
    ami = "ami-0d0f28110d16ee7d6"
    instance_type = var.instance_type
    key_name = var.key_name
    subnet_id = aws_subnet.public_subnets[0].id
    vpc_security_group_ids = [aws_security_group.monitoring_sg.id]
    iam_instance_profile = aws_iam_instance_profile.monitoring_server_profile.name

    root_block_device {
        volume_size =50 # GB, increased for storing metrics and logs
        volume_type = "gp3"
    }

    user_data = <<-EOF
        #!/bin/bash
        # Update sytem
        dnf update -y

        # Install Docker
        dnf install -y docker
        systemctl enable docker
        systemctl start docker

        # Install Docker Compose
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose"
        chmod +x /usr/local/bin/docker-compose

        # Install git and AWS CLI
        dnf install -y git
        dnf install -y aws-cli

        # Create directory for monitoring
        mkdir -p /opt/monitoring

        # Retrieve Grafana password from AWS Secrets Manager and create .env file
        aws secretsmanager get-secret-value --region ${var.aws_region} --secret-id ${var.secrets_manager_grafana_password_name} --query SecretString --output text | jq -r '.password' > /opt/montoring/grafana_password.txt}

        # Create .env file with the password
        echo "GRAFANA_ADMIN_PASSWORD=$(cat /opt/monitoring/grafana_password.txt)" > /opt/monitoring/.env
        echo "PROMETHEUS_RETENTION_DAYS=${var.prometheus_retention_days}" >> /opt/monitoring/.env

        # Secure the password file
        chmod 600 /opt/monitoring/grafana_password.txt
        chmod 600 /opt/monitoring/.env

        echo "Setup complete! You can now deploy the monitoring stack."
    EOF

    tags = {
        Name = "${var.environment}-monitoring-server"
    }

    depends_on = [ aws_secretsmanager_secret_version.grafana_admin_password ]
}

