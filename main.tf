locals {
  # Prefix for resource names in AWS: <project>-<environment>
  name_prefix = "${var.project}-${var.environment}"

  # Names of the resources created by this module
  names = {
    nginx_server_sg              = "${local.name_prefix}-nginx-server-sg"
    nginx_server_sg_ingress_ssh  = "${local.name_prefix}-nginx-server-sg-ingress-ssh"
    nginx_server_sg_ingress_http = "${local.name_prefix}-nginx-server-sg-ingress-http"
    nginx_server_sg_egress_all   = "${local.name_prefix}-nginx-server-sg-egress-all"
    nginx_server                 = "${local.name_prefix}-nginx-server"
    nginx_server_root_volume     = "${local.name_prefix}-nginx-server-root-volume"
    nginx_server_ssh_key         = "${local.name_prefix}-nginx-server-ssh-key"
  }
}

# ---------------------------------------------------------------------------
# AMI: latest Amazon Linux 2023 published by Amazon (free tier eligible).
# Never hardcode an ami-xxxx: IDs differ per region and get outdated.
# ---------------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

# ---------------------------------------------------------------------------
# Security group + rules (each rule as a separate resource)
# ---------------------------------------------------------------------------
resource "aws_security_group" "nginx_server_sg" {
  name        = local.names.nginx_server_sg
  description = "SSH and HTTP for the nginx server"

  tags = {
    Name = local.names.nginx_server_sg
  }
}

resource "aws_vpc_security_group_ingress_rule" "nginx_server_sg_ingress_ssh" {
  security_group_id = aws_security_group.nginx_server_sg.id
  description       = "SSH"
  cidr_ipv4         = var.allowed_ssh_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"

  tags = {
    Name = local.names.nginx_server_sg_ingress_ssh
  }
}

resource "aws_vpc_security_group_ingress_rule" "nginx_server_sg_ingress_http" {
  security_group_id = aws_security_group.nginx_server_sg.id
  description       = "HTTP"
  cidr_ipv4         = var.allowed_http_cidr
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  tags = {
    Name = local.names.nginx_server_sg_ingress_http
  }
}

# Without this rule the instance cannot reach the internet to download nginx
resource "aws_vpc_security_group_egress_rule" "nginx_server_sg_egress_all" {
  security_group_id = aws_security_group.nginx_server_sg.id
  description       = "All outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  tags = {
    Name = local.names.nginx_server_sg_egress_all
  }
}

# ---------------------------------------------------------------------------
# SSH key pair (only the public key is uploaded)
# ---------------------------------------------------------------------------
resource "aws_key_pair" "nginx_server_ssh_key" {
  key_name   = local.names.nginx_server_ssh_key
  public_key = file(var.ssh_public_key_path)

  tags = {
    Name = local.names.nginx_server_ssh_key
  }
}

# ---------------------------------------------------------------------------
# EC2 instance running nginx
# ---------------------------------------------------------------------------
resource "aws_instance" "nginx_server" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.nginx_server_ssh_key.key_name
  vpc_security_group_ids = [aws_security_group.nginx_server_sg.id]

  user_data                   = file("${path.module}/user_data.sh")
  user_data_replace_on_change = true

  # Security: enforce IMDSv2
  metadata_options {
    http_tokens = "required"
  }

  # Encrypted root volume
  root_block_device {
    volume_type = "gp3"
    encrypted   = true

    tags = {
      Name = local.names.nginx_server_root_volume
    }
  }

  tags = {
    Name = local.names.nginx_server
  }

  lifecycle {
    # Do not recreate the instance automatically when Amazon publishes a new AMI
    ignore_changes = [ami]
  }
}
