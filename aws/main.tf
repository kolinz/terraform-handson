terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.aws_region
}

# キーペア（SSH接続用）
resource "aws_lightsail_key_pair" "main" {
  name = "${var.instance_name}-keypair"
}

# ローカルにSSH秘密鍵を保存
resource "local_file" "private_key" {
  content         = aws_lightsail_key_pair.main.private_key
  filename        = "${path.module}/${var.instance_name}-key.pem"
  file_permission = "0600"
}

# Lightsailインスタンス
resource "aws_lightsail_instance" "main" {
  name              = var.instance_name
  availability_zone = "${var.aws_region}a"
  blueprint_id      = var.blueprint_id   # OS
  bundle_id         = var.bundle_id      # インスタンスサイズ
  key_pair_name     = aws_lightsail_key_pair.main.name

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# ファイアウォール：SSH (22)
resource "aws_lightsail_instance_public_ports" "main" {
  instance_name = aws_lightsail_instance.main.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }
}

# 静的IP（オプション）
resource "aws_lightsail_static_ip" "main" {
  name = "${var.instance_name}-static-ip"
}

resource "aws_lightsail_static_ip_attachment" "main" {
  static_ip_name = aws_lightsail_static_ip.main.name
  instance_name  = aws_lightsail_instance.main.name
}