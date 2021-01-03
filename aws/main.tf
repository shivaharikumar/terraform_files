terraform {
 required_version = ">= 0.13"
 required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.22.0"
    }
  }
}

provider "aws" {
  region                  = "ap-south-1"
  shared_credentials_file = "/home/ubuntu/.aws/credentials"
  profile                 = "dev"
}

# Create a VPC to launch our instances into
resource "aws_vpc" "dev_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "dev_ig" {
  vpc_id = aws_vpc.dev_vpc.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.dev_vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dev_ig.id
}

# Create a subnet to launch our instances into
resource "aws_subnet" "dev_subnet" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = var.aws_zone
}

# Our security group to access the instances via SSH and HTTP
resource "aws_security_group" "dev_ssh" {
  name        = "SSH SG"
  description = "SSH connector"
  vpc_id      = aws_vpc.dev_vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "web" {
  connection {
    type = "ssh"
    private_key = file(var.secret_key)
    user = "ubuntu"
    host = self.public_ip
  }

  instance_type = "t2.micro"
  ami = var.aws_amis
  key_name = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.dev_ssh.id]
  subnet_id = aws_subnet.dev_subnet.id
  availability_zone = var.aws_zone
  #This should verify if the user will be able to connect to instance
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
  }
}
