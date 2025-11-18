resource "aws_mq_broker" "this" {
  broker_name = "${var.name}-rabbitmq"
  engine_type = "RabbitMQ"
  engine_version = var.engine_version
  host_instance_type = var.instance_type
  publicly_accessible = false
  auto_minor_version_upgrade = true

  maintenance_window_start_time {
    day_of_week = "SUN"
    time_of_day = "03:00"
    time_zone = "UTC"
  }

  user {
    username = var.username
    password = var.password
  }

  logs {
    general = true
  }

  configuration {
    id = var.config_id != "" ? var.config_id : null
  }

  subnet_ids = var.subnet_ids
  security_groups = var.security_groups

  tags = { Name = "${var.name}-mq" }
}

output "broker_id" {
  value = aws_mq_broker.this.id
}

output "broker_arn" {
  value = aws_mq_broker.this.arn
}
