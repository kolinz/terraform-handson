variable "zone" {
  description = "さくらのクラウド ゾーン"
  type        = string
  default     = "is1b"
}

variable "server_name" {
  description = "サーバ・リソースの名前プレフィックス"
  type        = string
  default     = "web-server"
}

variable "server_password" {
  description = "サーバのrootパスワード（鍵認証が主、緊急用）"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "全リソースに付与するタグ"
  type        = list(string)
  default     = ["web", "terraform"]
}
