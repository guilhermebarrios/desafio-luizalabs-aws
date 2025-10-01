output "eks_cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_arn" {
  description = "ARN do cluster EKS"
  value       = module.eks.cluster_arn
}



output "ecr_repository_url" {
  description = "URL do repositório ECR"
  value       = aws_ecr_repository.app_ecr_repo.repository_url
}
