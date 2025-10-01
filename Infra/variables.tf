# infra/variables.tf

variable "meu_ip_acesso" {
  description = "O IP público da minha máquina para liberar o acesso ao cluster EKS"
  type        = string
}

# Provider e região
variable "aws_region" {
  description = "Região onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}