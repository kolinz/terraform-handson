output "server_ip" {
  description = "サーバのグローバルIPアドレス"
  value       = sakuracloud_server.web.ip_address
}

output "ssh_command" {
  description = "SSH接続コマンド"
  value       = "ssh -i ${var.server_name}.pem ubuntu@${sakuracloud_server.web.ip_address}"
}

output "http_url" {
  description = "WebサーバURL"
  value       = "http://${sakuracloud_server.web.ip_address}"
}

output "ssh_key_name" {
  description = "生成されたSSH秘密鍵ファイル"
  value       = local_sensitive_file.private_key.filename
  sensitive   = true
}
