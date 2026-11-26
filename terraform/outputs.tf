output "public_ip_access" {
  description = "IP público da aplicação"

  value = aws_instance.ec2-app.public_ip
}

output "private_ip_database" {
  description = "IP privado do banco"

  value = aws_instance.ec2-database.private_ip
}

output "private_ip_app" {
  description = "IP privado do app"

  value = aws_instance.ec2-app.private_ip
}

output "ssh_command_app" {
  description = "Comando ssh pra entrar na maquina do app"
  value       = "ssh -i ~/.ssh/smart-construction-key.pem ubuntu@${aws_instance.ec2-app.public_ip}"
}

output "ssh_command_database" {
  description = "Comando ssh pra entrar na máquina do banco"
  value       = "ssh -i ~/.ssh/smart-construction-key.pem -o IdentitiesOnly=yes -o 'ProxyCommand=ssh -i ~/.ssh/smart-construction-key.pem -o IdentitiesOnly=yes -W %h:%p ubuntu@${aws_instance.ec2-app.public_ip}' ubuntu@${aws_instance.ec2-database.private_ip}"
}


output "url_app" {
  description = "URL pública para acessar o Smart Construction"
  value       = "https://${replace(aws_instance.ec2-app.public_ip, ".", "-")}.sslip.io/"
}
