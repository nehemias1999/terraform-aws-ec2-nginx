variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-2"
}

variable "aws_profile" {
  description = "AWS CLI profile to use. null = default credential chain"
  type        = string
  default     = null
}

variable "owner" {
  description = "Owner of the resources (person or email), applied as the Owner tag"
  type        = string

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty."
  }
}

variable "team" {
  description = "Team responsible for the resources, applied as the Team tag"
  type        = string

  validation {
    condition     = length(trimspace(var.team)) > 0
    error_message = "team cannot be empty."
  }
}

variable "environment" {
  description = "Environment: dev or prod"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be \"dev\" or \"prod\"."
  }
}

variable "project" {
  description = "Short project name, used as a prefix for AWS resource names"
  type        = string
  default     = "tfproject"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project))
    error_message = "Only lowercase letters, numbers and hyphens are allowed (it is used in AWS resource names)."
  }
}

variable "instance_type" {
  description = "EC2 instance type (free tier, x86)"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small"], var.instance_type)
    error_message = "Use t3.micro or t3.small (free tier, x86). t4g.* types require an ARM AMI."
  }
}

variable "ssh_public_key_path" {
  description = "Path to the SSH public key uploaded to AWS (the private key must NEVER be committed)"
  type        = string
  default     = "nginx-server.key.pub"
}

variable "allowed_ssh_cidr" {
  description = "CIDR allowed to connect via SSH (22). No default on purpose: set your public IP with /32"
  type        = string

  validation {
    condition     = can(cidrhost(var.allowed_ssh_cidr, 0))
    error_message = "Must be a valid CIDR, e.g. 181.10.20.30/32."
  }

  validation {
    condition     = var.allowed_ssh_cidr != "0.0.0.0/0"
    error_message = "Do not open SSH to the whole internet. Use your public IP with /32 (curl https://checkip.amazonaws.com)."
  }
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to connect via HTTP (80). 0.0.0.0/0 = the whole internet"
  type        = string
  default     = "0.0.0.0/0"
}
