# infra/variables.tf

variable "meu_ip_acesso" {
  description = "O IP público da minha máquina para liberar o acesso ao cluster EKS"
  type        = string
}