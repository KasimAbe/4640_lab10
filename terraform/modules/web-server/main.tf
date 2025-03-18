# specify a project name# specify a project name
locals {
  project_name = var.project_name
}

# get the most recent ami for your packer ansible build
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
data "aws_ami" "ansible-nginx" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["packer-ansible-nginx"]
  }
}

# Create a VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "web" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name    = "project_vpc"
    Project = local.project_name
  }
}

# Create a public subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
# To use the free tier t2.micro ec2 instance you have to declare an AZ
# Some AZs do not support this instance type
resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.web.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2"
  map_public_ip_on_launch = true

  tags = {
    Name = "Web"
  }
}

# Create internet gateway for VPC
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "web-gw" {
  vpc_id = aws_vpc.web.id

  tags = {
    Name = "Web"
  }
}

# create route table for web VPC 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "web" {
  vpc_id = aws_vpc.web.id

  tags = {
    Name = "web-route"
  }
}

# add route to to route table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.web.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web-gw.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.web.id
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "web" {
  name        = "allow_ssh"
  description = "allow ssh from home and work"
  vpc_id      = aws_vpc.web.id

  tags = {
    Name = "Web"
  }
}
# Allow ssh
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "web-ssh" {
  security_group_id = aws_security_group.web.id
  count = length(var.ingress_rules)

  cidr_ipv4   = var.ingress_rules[count.index].cidr_ipv4
  from_port   = var.ingress_rules[count.index].from_port
  ip_protocol = var.ingress_rules[count.index].ip_protocol
  to_port     = var.ingress_rules[count.index].to_port
}

# allow http
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule
resource "aws_vpc_security_group_ingress_rule" "web-http" {
  security_group_id = aws_security_group.web.id
  count = length(var.ingress_rules)

  cidr_ipv4   = var.ingress_rules[count.index].cidr_ipv4
  from_port   = var.ingress_rules[count.index].from_port
  ip_protocol = var.ingress_rules[count.index].ip_protocol
  to_port     = var.ingress_rules[count.index].to_port
}

# allow all out
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule
resource "aws_vpc_security_group_egress_rule" "web-egress" {
  security_group_id = aws_security_group.web.id
  count = length(var.egress_rules)

  cidr_ipv4   = var.egress_rules[count.index].cidr_ipv4
  from_port   = var.egress_rules[count.index].from_port
  ip_protocol = var.egress_rules[count.index].ip_protocol
  to_port     = var.egress_rules[count.index].to_port
}


# create the ec2 instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]
  subnet_id              = aws_subnet.web.id

  tags = {
    Name = "Web"
  }
}

