output "aws_instance_ip" {
  value = aws_instance.restaurant_app_server.*.public_ip
}

