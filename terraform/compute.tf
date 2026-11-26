# Role que pemite à EC2 acessar os serviços da AWS
resource "aws_iam_role" "backup_role" {
  name = "smart-construction-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Regra de acesso ao S3
resource "aws_iam_policy" "policy_backup_s3" {
  name = "smart-construction-backup"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ListBackups"
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = "arn:aws:s3:::smart-construction-backup"
        Condition = {
          StringLike = {
            "s3:prefix" = ["database/*", "seaweedfs/*"]
          }
        }
      },
      {
        Sid      = "ReadWriteBackups"
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "arn:aws:s3:::smart-construction-backup/*"
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "smart_construction_backup_s3" {
  role       = aws_iam_role.backup_role.name
  policy_arn = aws_iam_policy.policy_backup_s3.arn
}

resource "aws_iam_instance_profile" "backup_profile" {
  name = "smart-construction-database-profile"
  role = aws_iam_role.backup_role.name
}
#buscando imagem recente do ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

#EC2 com o app
resource "aws_instance" "ec2-app" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.small"
  subnet_id     = aws_subnet.subnet-pub.id

  iam_instance_profile = aws_iam_instance_profile.backup_profile.name

  associate_public_ip_address = true
  #criei no console da aws
  key_name = "smart-construction-key"

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  vpc_security_group_ids = [
    aws_security_group.sec-app.id,
    aws_security_group.ssh.id
  ]

  tags = {
    Name = "ec2-smart-construction-web"
  }

}




#EC2 com postgresql 
resource "aws_instance" "ec2-database" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = "t3.small"
  subnet_id            = aws_subnet.subnet-priv.id
  key_name             = "smart-construction-key"
  iam_instance_profile = aws_iam_instance_profile.backup_profile.name

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }


  vpc_security_group_ids = [
    aws_security_group.sec-database.id
  ]

  tags = {
    Name = "ec2-smart-construction-database"
  }

}
