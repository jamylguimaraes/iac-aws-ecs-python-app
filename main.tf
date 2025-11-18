locals {
  name = "${var.project_name}-${var.environment}"
  azs  = ["${var.aws_region}a", "${var.aws_region}b"]
}

module "vpc" {
  source         = "./modules/vpc"
  name           = local.name
  vpc_cidr       = "10.0.0.0/16"
  public_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets= ["10.0.11.0/24", "10.0.12.0/24"]
  azs            = local.azs
  eip_allocation_ids = [] 
}

# Security groups
resource "aws_security_group" "alb_sg" {
  name   = "${local.name}-alb-sg"
  vpc_id = module.vpc.vpc_id
  description = "ALB SG"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name   = "${local.name}-tasks-sg"
  vpc_id = module.vpc.vpc_id
  description = "ECS tasks SG"
  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "From ALB"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${local.name}-rds-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "${local.name}-redis-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECR 
module "ecr_app" {
  source    = "./modules/ecr"
  repo_name = "${local.name}-app"
}

# RDS
module "rds" {
  source = "./modules/rds"
  name = local.name
  subnet_ids = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.rds_sg.id
  username = "appuser"
  password = var.rds_password
  database_name = "appdb"
  multi_az = false
}

# ElastiCache
module "redis" {
  source = "./modules/elasticache"
  name = local.name
  subnet_ids = module.vpc.private_subnet_ids
  security_group_id = aws_security_group.redis_sg.id
  node_type = "cache.t3.small"
  num_cache_nodes = 1
}

# Amazon MQ
module "mq" {
  source = "./modules/mq"
  name = local.name
  username = "mquser"
  password = var.mq_password
  subnet_ids = module.vpc.private_subnet_ids
  security_groups = [aws_security_group.ecs_tasks_sg.id]
}

# ECS cluster + service
module "ecs" {
  source = "./modules/ecs"
  name = local.name
  public_subnets = module.vpc.public_subnet_ids
  private_subnets = module.vpc.private_subnet_ids
  vpc_id = module.vpc.vpc_id
  alb_security_group_id = aws_security_group.alb_sg.id
  task_security_group_id = aws_security_group.ecs_tasks_sg.id
  container_name = "app"
  container_image = "${module.ecr_app.repository_url}:latest" # ajuste conforme tag publicada pelo CI
  container_port = 8000
  environment_vars = {
    DATABASE_HOST = module.rds.address
    DATABASE_PORT = tostring(module.rds.port)
    REDIS_HOST    = module.redis.configuration_endpoint
    RABBITMQ_USER = "mquser"
    # TODO Secrets Manager
  }
  desired_count = 2
  aws_region = var.aws_region
}

# Outputs
output "alb_dns" {
  value = module.ecs.alb_dns
}
output "ecr_repo" {
  value = module.ecr_app.repository_url
}
output "rds_address" { value = module.rds.address }
output "redis_endpoint" { value = module.redis.configuration_endpoint }
output "mq_broker" { value = module.mq.broker_arn }


