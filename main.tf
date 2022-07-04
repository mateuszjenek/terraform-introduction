terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}

resource "aws_subnet" "public_subnet" {
  availability_zone       = "us-west-2a"
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  vpc_id                  = aws_vpc.vpc.id

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}

resource "aws_default_route_table" "route_table" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}

resource "aws_security_group" "security_group" {
  name   = "${var.name}-instance-sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_key_pair" "key" {
  key_name   = var.owner
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDR5BDeSq7smw1Jp7ia+281VjOXbDZhY5CHF6fUPg9PzNhvoI0nLf/hoY6ipiF85sxjL/igoPhw7kYoYX28q9cySIn9dsT64dlnlyHd1L4KStxbrE5s0YAx/P5w5PQndxarLmVxYeWH3R+IzPAyLIR6ENU4dPh7qUQfUoioJAG14AaqR7iX8eL0O5TRz5oPb8Ce2YtRAWxIKvuGEQYh3lTbhNJtQA2Z0fRIFFR1xdCeMZsXhDpfUZ2HrFzRJwVpbX074XVJ03Lubl7oFb7x7NHxiYD28i4NuY4aqXa8KWQ4ihzAhj2bSB9Vt9OqgEgg5lMdLl796h5AGvWJcPlBpXYHbVq04/OTxNTwpd3EOXpF1WSA8QWNuAWn5hm4Bb/lgOePL3Kd98r/v0NyTeGlRJVYsvL8EaPvHyoNdnnX/SapFrk9E0UbNzeEJr8OLQOnF3dSep8aTNSGM0f88tKzoJ+EIIYEm72oAzmBLpe/FYF9NikU+SQ8G05MGN0hycT+Xgc= mjenek@mjenek-MOBL"
}

resource "aws_instance" "instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.key.key_name
  subnet_id       = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.security_group.id]

  tags = tomap({
    Name  = var.name
    Owner = var.owner
  })
}
