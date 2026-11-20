resource "aws_vpc" "vpc-smart-construction" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-smart-construction"
  }

}

resource "aws_subnet" "subnet-pub" {
  vpc_id            = aws_vpc.vpc-smart-construction.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true


  tags = {
    Name = "subnet-public-1a"
  }
}

resource "aws_subnet" "subnet-priv" {
  vpc_id            = aws_vpc.vpc-smart-construction.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-private-1a"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc-smart-construction.id

  tags = {
    Name = "internetzona-gateway-smart-construction"
  }
}


resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]

  tags = {
    Name = "elastic-ip-smart-construction"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet-pub.id

  tags = {
    Name = "natzao-gateway-smart-construction"
  }
}


resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc-smart-construction.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "rt_private" {
  vpc_id = aws_vpc.vpc-smart-construction.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id  = aws_nat_gateway.nat.id
  }
}

resource "aws_route_table_association" "assoc-pb" {
  subnet_id      = aws_subnet.subnet-pub.id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "assoc-priv" {
  subnet_id      = aws_subnet.subnet-priv.id
  route_table_id = aws_route_table.rt_private.id
}

