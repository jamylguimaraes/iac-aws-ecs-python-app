resource "aws_elasticache_subnet_group" "this" {
  name       = "${var.name}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_elasticache_cluster" "this" {
  cluster_id           = "${var.name}-redis"
  engine               = "redis"
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  subnet_group_name    = aws_elasticache_subnet_group.this.name
  security_group_ids   = [var.security_group_id]
  parameter_group_name = "default.redis6.x"
  tags = { Name = "${var.name}-redis" }
}

output "cache_nodes" {
  value = aws_elasticache_cluster.this.cache_nodes
}

output "configuration_endpoint" {
  value = aws_elasticache_cluster.this.cache_nodes[0].address
}
