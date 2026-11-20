# EC2 NGINX (PROXY REVERSO)

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

#EC2 com nginx e frontend
resource "aws_instance" "ec2-app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet-pub.id

  associate_public_ip_address = true
  #criei no console da aws
  key_name = "smart-construction-key"

  vpc_security_group_ids = [
    aws_security_group.sec-app.id,
    aws_security_group.ssh.id

  ]

  tags = {
    Name = "ec2-smart-construction-web"
  }

}


#EC2 com backend e seaweed
resource "aws_instance" "ec2-backend" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet-priv.id

  key_name = "smart-construction-key"

  vpc_security_group_ids = [
    aws_security_group.sec-backend.id
  ]

  tags = {
    Name = "ec2-smart-construction-backend"
  }
}

#EC2 com postgresql 
resource "aws_instance" "ec2-database" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet-priv-2.id
  key_name      = "smart-construction-key"


  vpc_security_group_ids = [
    aws_security_group.sec-database.id
  ]

  tags = {
    Name = "ec2-smart-construction-database"
  }

}
