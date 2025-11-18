output "alb_dns" {
  description = "ALB DNS name"
  value = module.ecs.alb_dns
}

output "ecr_repo" {
  description = "ECR repo URL"
  value = module.ecr_app.repository_url
}
