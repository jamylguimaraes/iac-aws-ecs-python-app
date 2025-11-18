variable "name" { type = string }
variable "public_subnets" { type = list(string) }
variable "private_subnets" { type = list(string) }
variable "vpc_id" { type = string }
variable "alb_security_group_id" { type = string }
variable "task_security_group_id" { type = string }
variable "container_name" { type = string }
variable "container_image" { type = string }
variable "container_port" {
  type    = number
  default = 8000
}
variable "environment_vars" { 
  type = map(string) 
  default = {} 
}
variable "cpu" {
  type    = string
  default = "512"
}
variable "memory" {
  type    = string
  default = "1024"
}
variable "desired_count" { 
  type    = number 
  default = 2 
}
variable "aws_region" {
  type = string 
  default = "us-east-1"
}
