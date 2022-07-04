output "public_ip_address" {
  value = aws_instance.instance.public_ip
}