# AWS ECS Python App com Terraform

## Arquitetura na AWS

![AWS](https://github.com/jamylguimaraes/iac-aws-ecs-python-app/blob/main/doc/screenshots/app-ecs-rds-mq.png)

## Pré-requisitos
- Terraform >= 1.2
- AWS CLI com credenciais configuradas
- Docker (para build/push de imagens ao ECR)

## Passos rápidos
1. Ajuste `environments/prod/terraform.tfvars` com senhas e dados.
2. (Opcional) configure backend S3 em `backend.tf`.
3. Inicialize Terraform:

```bash
terraform init
```

4. Verifique o plano:

```bash
terraform plan -var-file=environments/prod/terraform.tfvars
```

5. Aplique:

```bash
terraform apply -var-file=environments/prod/terraform.tfvars
```

## Publicar imagem no ECR

1. Faça login no ECR:

```bash
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com
```

2. Build e push:

```bash
docker build -t <repo>:latest .
docker tag <repo>:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/<repo>:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/<repo>:latest
```

3. Atualize `module.ecs.container_image` se necessário e faça `terraform apply` (ou use CodePipeline/CodeBuild para atualizar automaticamente).

## Notas de segurança / melhorias
- Não coloque senhas em plain-text em repositório. Use AWS Secrets Manager/Parameter Store e integre via task definition `secrets`.
- Em produção, considere RDS Multi-AZ, ElastiCache replication, backups e métricas.
- Configure auto-scaling para ECS (aws_appautoscaling_target + aws_appautoscaling_policy).