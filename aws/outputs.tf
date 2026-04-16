output "instance_name" {
  value = aws_lightsail_instance.main.name
}

output "public_ip" {
  value = aws_lightsail_static_ip.main.ip_address
}

output "ssh_command" {
  value = "ssh -i ${var.instance_name}-key.pem ubuntu@${aws_lightsail_static_ip.main.ip_address}"
}

output "private_key_path" {
  value = local_file.private_key.filename
}