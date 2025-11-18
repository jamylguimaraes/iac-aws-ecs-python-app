variable "name" { type = string }
variable "subnet_ids" { type = list(string) }
variable "security_group_id" { type = string }
variable "node_type" {
  type    = string
  default = "cache.t3.small"
}
variable "num_cache_nodes" {
  type    = number
  default = 1
} # single node, para produção avaliar replication
