output "public_ip_access" {
  description = "IP público da aplicação"

  value = aws_instance.ec2-web.public_ip
}



output "url_app" {
  description = "URL pública para acessar o Smart Construction"

  value = "http://${aws_instance.ec2-web.public_ip}/"
}
