resource "aws_ecr_repository" "this" {
  name                 = var.repo_name
  image_tag_mutability = "MUTABLE"
  tags = { Name = var.repo_name }
}

output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "repository_id" {
  value = aws_ecr_repository.this.id
}
