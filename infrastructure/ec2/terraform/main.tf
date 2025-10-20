terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# IAM role for EC2 instance
resource "aws_iam_role" "app_role" {
  name = "${var.app_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach managed policies to the role
resource "aws_iam_role_policy_attachment" "s3_readonly" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_managed_instance" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# IAM instance profile
resource "aws_iam_instance_profile" "app_profile" {
  name = "${var.app_name}-profile"
  role = aws_iam_role.app_role.name
}

# Security group
resource "aws_security_group" "app_sg" {
  name        = "${var.app_name}-sg"
  description = "Security group for ${var.app_name}"
  vpc_id      = data.aws_vpc.default.id

  # Allow inbound traffic on application port
  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.app_name}-sg"
  }
}

# Use default VPC
data "aws_vpc" "default" {
  default = true
}

# EC2 instance
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.app_profile.name
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = templatefile("${path.module}/user_data.sh", {
    app_name   = var.app_name
    app_port   = var.app_port
    image_uri  = local.image_uri
    aws_region = var.aws_region
  })

  tags = {
    Name = var.app_name
  }
}
