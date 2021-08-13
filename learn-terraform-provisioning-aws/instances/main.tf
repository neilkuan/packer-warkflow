terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.26.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "vpc" {
  default = true
}

data "aws_subnet_ids" "example" {
  vpc_id = data.aws_vpc.vpc.id
}

variable image_id {
  type    = string
}

resource "aws_security_group" "sg_22_80" {
  name   = "sg_22"
  vpc_id = data.aws_vpc.vpc.id

  # SSH access from the VPC
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "web" {
  ami                         = var.image_id
  instance_type               = "t2.micro"
  subnet_id                   = tolist(data.aws_subnet_ids.example.ids).0
  vpc_security_group_ids      = [aws_security_group.sg_22_80.id]
  associate_public_ip_address = true
  user_data                   = "#!/bin/bash\nsudo su - terraform -c 'cd /home/terraform/go/src/github.com/hashicorp/learn-go-webapp-demo/ && go run webapp.go & '"
  tags = {
    Name = "Learn-Packer"
  }
}

output "public_ip" {
  value = "http://${aws_instance.web.public_ip}:8080"
}
