#Security Groups

resource "aws_security_group" "ssh" {
  name        = "sec-ssh"
  description = "Libera SSH"
  vpc_id      = aws_vpc.vpc-smart-construction.id

  ingress {
    description = "SSH do meu IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Permite trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "libera-ssh"
  }
}

#EC2 COM O APP TODO
resource "aws_security_group" "sec-app" {
  name        = "sec-app"
  description = "Permite acesso a aplicacao pelo nginx"
  vpc_id      = aws_vpc.vpc-smart-construction.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}


#EC2 COM O POSTGRESQL
resource "aws_security_group" "sec-database" {
  name        = "security-database"
  description = "Libera o banco apenas para o grupo do app"
  vpc_id      = aws_vpc.vpc-smart-construction.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.sec-app.id]
  }

  ingress {
    description     = "SSH via a ec2 do app"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sec-app.id]
  }

  egress {
    description = "Liberando trafego aos repositorios para baixar pacotes na internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Liberando trafego aos repositorios para baixar pacotes na internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
