terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  region = var.aws_region
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "cloudops_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "cloudops-vpc"
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "cloudops_igw" {
  vpc_id = aws_vpc.cloudops_vpc.id

  tags = {
    Name = "cloudops-internet-gateway"
  }
}

# -------------------------
# Public Subnet
# -------------------------

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cloudops_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name = "cloudops-public-subnet"
  }
}

# -------------------------
# Private Subnet
# -------------------------

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.cloudops_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = {
    Name = "cloudops-private-subnet"
  }
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cloudops_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudops_igw.id
  }

  tags = {
    Name = "cloudops-public-route-table"
  }
}

resource "aws_route_table_association" "public_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# -------------------------
# Security Group
# -------------------------

resource "aws_security_group" "cloudops_sg" {
  name        = "cloudops-security-group"
  description = "Security group for CloudOps application"
  vpc_id      = aws_vpc.cloudops_vpc.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Application port
  ingress {
    description = "Application"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloudops-security-group"
  }
}

# -------------------------
# IAM Role for EC2 / SSM
# -------------------------

resource "aws_iam_role" "cloudops_ssm_role" {
  name = "cloudops-ec2-ssm-role"

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

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Attach SSM Policy
# -------------------------

resource "aws_iam_role_policy_attachment" "cloudops_ssm_policy" {
  role       = aws_iam_role.cloudops_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# -------------------------
# EC2 Instance Profile
# -------------------------

resource "aws_iam_instance_profile" "cloudops_ssm_profile" {
  name = "cloudops-ec2-ssm-profile"
  role = aws_iam_role.cloudops_ssm_role.name
}

# -------------------------
# EC2 Instance
# -------------------------

resource "aws_instance" "cloudops_server" {
  ami           = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile        = aws_iam_instance_profile.cloudops_ssm_profile.name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.cloudops_sg.id]
  associate_public_ip_address = true
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y
              apt-get install -y docker.io nginx amazon-ssm-agent

              systemctl enable docker
              systemctl start docker

              systemctl enable nginx
              systemctl start nginx

              systemctl enable amazon-ssm-agent
              systemctl start amazon-ssm-agent

              usermod -aG docker ubuntu

              echo "<h1>CloudOps Enterprise Platform Server</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name    = "cloudops-server"
    Project = "CloudOps Enterprise Platform"
  }
}
# -------------------------
# IAM Role for Lambda
# -------------------------

resource "aws_iam_role" "cloudops_lambda_role" {
  name = "cloudops-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# Lambda Logging Policy
# -------------------------

resource "aws_iam_role_policy" "cloudops_lambda_logging" {
  name = "cloudops-lambda-logging"
  role = aws_iam_role.cloudops_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]

        Resource = "*"
      }
    ]
  })
}

# -------------------------
# Lambda Function
# -------------------------

resource "aws_lambda_function" "cloudops_lambda" {
  function_name = "cloudops-enterprise-lambda"

  role = aws_iam_role.cloudops_lambda_role.arn

  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"

  filename = "${path.module}/../lambda/lambda_function.zip"

  source_code_hash = filebase64sha256(
    "${path.module}/../lambda/lambda_function.zip"
  )

  timeout     = 10
  memory_size = 128

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# ECR Repository
# -------------------------

resource "aws_ecr_repository" "cloudops_app" {
  name                 = "cloudops-enterprise-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project = "CloudOps Enterprise Platform"
  }
}

# -------------------------
# EC2 ECR Pull Permissions
# -------------------------

resource "aws_iam_role_policy" "cloudops_ec2_ecr_pull" {
  name = "cloudops-ec2-ecr-pull"
  role = aws_iam_role.cloudops_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.cloudops_app.arn
      }
    ]
  })
}