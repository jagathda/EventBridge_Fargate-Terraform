# Configure provider
provider "aws" {
    region = "eu-north-1"
}

#####################################################

# Create VPC
resource "aws_vpc" "fargate_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "FargateVPC"
  }
}

# Created public subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.fargate_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-north-1a"
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.fargate_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-north-1b"
}

# Create internet gateway
resource "aws_internet_gateway" "fargate_igw" {
  vpc_id = aws_vpc.fargate_vpc.id
}

# Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.fargate_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fargate_igw.id
  }
}

# Associate route table with subnets
resource "aws_route_table_association" "public_subnet_1_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_association" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

# Create a security group for ECS fargate
resource "aws_security_group" "fargate_sg" {
  vpc_id = aws_vpc.fargate_vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "FargateSecurityGroup"
  }
}

#####################################################

# Create ECS cluster
resource "aws_ecs_cluster" "fargate_cluster" {
  name = "fargate-cluster"
}