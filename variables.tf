variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  type    = string
  default = "ecs-python-app"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "rds_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "mq_password" {
  description = "Password for the Amazon MQ broker"
  type        = string
  sensitive   = true
}