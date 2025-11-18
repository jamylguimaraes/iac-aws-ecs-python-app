variable "name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "engine_version" {
  type    = string
  default = "14.4"
}
variable "instance_class" {
  type    = string
  default = "db.t3.medium"
}
variable "allocated_storage" {
  type    = number
  default = 20
}
variable "database_name" {
  type    = string
  default = "appdb"
}
variable "username" {
  type    = string
  default = "appuser"
}
variable "password" { type = string }
variable "multi_az" {
  type    = bool
  default = false
}