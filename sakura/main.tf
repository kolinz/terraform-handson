terraform {
  required_providers {
    sakuracloud = {
      source  = "sacloud/sakuracloud"
      version = "2.26"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
  required_version = ">= 1.3.0"
}

# ─────────────────────────────────────────
# Provider
# ─────────────────────────────────────────
provider "sakuracloud" {
  zone = var.zone
}

# ─────────────────────────────────────────
# SSHキーペア
# tls_private_key でローカル生成 → さくらに公開鍵を登録
# ─────────────────────────────────────────
resource "tls_private_key" "web" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 秘密鍵をローカルに保存
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.web.private_key_pem
  filename        = "${path.module}/${var.server_name}.pem"
  file_permission = "0600"
}

# さくらのクラウドに公開鍵を登録
resource "sakuracloud_ssh_key" "web" {
  name       = "${var.server_name}-key"
  public_key = tls_private_key.web.public_key_openssh
}

# ─────────────────────────────────────────
# ディスク（Ubuntu 22.04）
# ─────────────────────────────────────────
data "sakuracloud_archive" "ubuntu" {
  os_type = "ubuntu2204"
}

resource "sakuracloud_disk" "web" {
  name              = "${var.server_name}-disk"
  source_archive_id = data.sakuracloud_archive.ubuntu.id
  plan              = "ssd"
  size              = 20   # GB
  zone              = var.zone

  tags = var.tags
}

# ─────────────────────────────────────────
# パケットフィルタ（ファイアウォール）
# デフォルト動作: どのルールにもマッチしない場合は allow
# ─────────────────────────────────────────
resource "sakuracloud_packet_filter" "web" {
  name        = "${var.server_name}-filter"
  description = "Allow SSH / HTTP / HTTPS"
  zone        = var.zone

  # SSH
  expression {
    protocol         = "tcp"
    destination_port = "22"
    allow            = true
    description      = "SSH"
  }

  # HTTP
  expression {
    protocol         = "tcp"
    destination_port = "80"
    allow            = true
    description      = "HTTP"
  }

  # HTTPS
  expression {
    protocol         = "tcp"
    destination_port = "443"
    allow            = true
    description      = "HTTPS"
  }

  # ICMP（ping等）
  expression {
    protocol    = "icmp"
    allow       = true
    description = "ICMP"
  }
}

# ─────────────────────────────────────────
# サーバ（1コア / 1GB）
# ─────────────────────────────────────────
resource "sakuracloud_server" "web" {
  name   = var.server_name
  core   = 1
  memory = 1
  zone   = var.zone

  disks = [sakuracloud_disk.web.id]

  # ディスクの修正（初回起動時に適用）
  disk_edit_parameter {
    hostname        = var.server_name
    password        = var.server_password
    ssh_key_ids     = [sakuracloud_ssh_key.web.id]
    disable_pw_auth = true   # 鍵認証のみ許可

    note_ids = [sakuracloud_note.init.id]
  }

  # パケットフィルタはnetwork_interface内で紐付け
  network_interface {
    upstream         = "shared"   # 共有グローバルIP
    packet_filter_id = sakuracloud_packet_filter.web.id
  }

  tags        = var.tags
  description = "Webサーバ (Terraform管理)"
}

# ─────────────────────────────────────────
# スタートアップスクリプト（Nginx導入）
# ─────────────────────────────────────────
resource "sakuracloud_note" "init" {
  name    = "${var.server_name}-init"
  class   = "shell"
  content = <<-EOF
    #!/bin/bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive

    # ネットワーク・DNS が使えるようになるまで待機（最大60秒）
    echo "Waiting for network..." >> /var/log/terraform-init.log
    for i in $(seq 1 12); do
      if curl -sf --max-time 5 http://security.ubuntu.com > /dev/null 2>&1; then
        echo "Network ready." >> /var/log/terraform-init.log
        break
      fi
      echo "Retry $i/12..." >> /var/log/terraform-init.log
      sleep 5
    done

    # IPv6無効化（さくらのクラウド共有IPはIPv4のみ）
    echo 'Acquire::ForceIPv4 "true";' > /etc/apt/apt.conf.d/99force-ipv4

    apt-get update -y
    apt-get install -y nginx ufw

    # UFW: SSH + HTTP + HTTPS のみ許可
    ufw --force enable
    ufw allow OpenSSH
    ufw allow 'Nginx Full'

    # Nginx 自動起動
    systemctl enable nginx
    systemctl start nginx

    echo "Setup complete: $(date)" >> /var/log/terraform-init.log
  EOF

  tags = var.tags
}
