variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Public subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private subnet CIDR"
  type        = string
  default     = "10.0.2.0/24"
}

variable "eks_public_subnet_cidr" {
  description = "EKS second public subnet CIDR"
  type        = string
  default     = "10.0.3.0/24"
}

variable "availability_zone" {
  description = "Primary AWS availability zone"
  type        = string
  default     = "eu-north-1a"
}

variable "eks_availability_zone" {
  description = "Second AWS availability zone for EKS"
  type        = string
  default     = "eu-north-1b"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu 24.04 AMI for Stockholm"
  type        = string
}