output "public_ip_access" {
  description = "IP público da aplicação"

  value = aws_instance.ec2-web.public_ip
}

output "private_ip_database" {
  description = "IP privado do banco"

  value = aws_instance.ec2-database.private_ip
}

output "private_ip_backend" {
  description = "IP privado do backend"

  value = aws_instance.ec2-backend.private_ip
}




output "url_app" {
  description = "URL pública para acessar o Smart Construction"

  value = "http://${aws_instance.ec2-web.public_ip}/"
}
