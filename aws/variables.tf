variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "instance_name" {
  description = "Lightsailインスタンス名"
  type        = string
  default     = "my-lightsail-vm"
}

variable "blueprint_id" {
  description = "OS/アプリのブループリントID"
  type        = string
  default     = "ubuntu_24_04"
}

variable "bundle_id" {
  description = "インスタンスサイズ（バンドルID）"
  type        = string
  default     = "nano_3_0"  # 最小: $5.00/月
}

variable "environment" {
  description = "環境タグ"
  type        = string
  default     = "dev"
}