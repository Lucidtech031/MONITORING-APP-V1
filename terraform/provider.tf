terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }
        random = {
            source = "hashicorp/random"
            version = "~> 3.0"
        }
    }

    backend "s3" {
        bucket = "monitoring-alerts-storage"
        key = "monitoring-system/terraform.tfstate"
        region = "us-east-2"
    }
}
provider "aws" {
    region = var.aws_region

    default_tags {
        tags = {
            Project = "Monitoring System"
            Environment = var.environment
            ManagedBy = "Terraform"
        }
    }
}

provider "random" {}
  
