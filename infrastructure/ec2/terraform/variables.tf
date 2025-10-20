variable "aws_region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "python-flask"
}

variable "app_port" {
  description = "Application port"
  type        = number
  default     = 5000
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "image_name" {
  description = "Docker image name (will be combined with ECR registry)"
  type        = string
}

variable "ecr_account_id" {
  description = "AWS account ID for ECR registry"
  type        = string
  default     = ""
}

variable "ecr_region" {
  description = "AWS region for ECR registry"
  type        = string
  default     = ""
}

# Computed image URI
locals {
  account_id = var.ecr_account_id != "" ? var.ecr_account_id : data.aws_caller_identity.current.account_id
  ecr_region = var.ecr_region != "" ? var.ecr_region : var.aws_region
  image_uri  = "${local.account_id}.dkr.ecr.${local.ecr_region}.amazonaws.com/${var.image_name}:latest"
}

data "aws_caller_identity" "current" {}
