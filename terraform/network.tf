
resource "aws_vpc" "vpc-smart-construction" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
      Name = "vpc-smart-construction"
    }
  
}

resource "aws_subnet" "subnet-pub" {
  vpc_id                  = aws_vpc.vpc_miguel_aluguel.id
  cidr_block              = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true


  tags = {
      Name = "subnet-public-1a"
    }
  
}

resource "aws_subnet" "subnet-priv-1" {
  vpc_id            = aws_vpc.vpc_miguel_aluguel.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-private-1a"
  }
}

resource "aws_subnet" "subnet-priv-2" {
  vpc_id            = aws_vpc.vpc_miguel_aluguel.id
  cidr_block        = "10.20.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-private-1b"
  }
}