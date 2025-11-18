variable "name" { type = string }
variable "engine_version" {
  type = string
  default = "3.8.26"
}
variable "instance_type" {
  type = string
  default = "mq.t3.micro"
}
variable "username" { type = string }
variable "password" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_groups" { type = list(string) }
variable "config_id" {
  type = string
  default = ""
}
