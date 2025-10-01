# Bloco de configuração do Terraform
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.45.0"
    }
  }
}



# Configuração do provider 
provider "aws" {
  region = "us-east-1"
}

# Módulo para criar a VPC (Rede)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.8.0"

  name = "desafio-vpc-luizalabs"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"] # Zonas de disponibilidade (3 AZs), (Alta disponibilidade)
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  # Dentro do module "vpc"
  public_subnet_tags = {
    "kubernetes.io/cluster/cluster-desafio-luizalabs-v2" = "shared" # <--- Importante para o EKS reconhecer as subnets
    "kubernetes.io/role/elb"                             = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/cluster/cluster-desafio-luizalabs-v2" = "shared" # <--- Importante para o EKS reconhecer as subnets
    "kubernetes.io/role/internal-elb"                    = "1"
  }

  tags = {
    Terraform   = "true"
    Environment = "desafio-luizalabs"
  }
}

# Módulo para criar o Cluster EKS ---
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.4" # Travando em uma versão estável

  cluster_name    = "cluster-desafio-luizalabs-v2"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # Nós apenas em subnets privadas

  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = ["0.0.0.0/0"] # Altere aqui!

  enable_cluster_creator_admin_permissions = true

  iam_role_additional_policies = {
    # Anexando a política que permite puxar imagens do ECR
    ECRReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  # Grupo de nós gerenciados (Managed Node Group)

  eks_managed_node_groups = {
    spot_nodes = {
      instance_types = ["t3.small", "t3.medium"] # Instâncias Spot (baratas), se precisar de mais, adicione mais tipos
      capacity_type  = "SPOT"
      min_size       = 1
      max_size       = 3
      desired_size   = 3
      labels = {
        type = "spot"
      }
    }

    on_demand_nodes = {
      instance_types = ["t3.micro"] # Free Tier
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 2
      desired_size   = 1
      labels = {
        type = "on-demand"
      }
    }



  }

  tags = {
    Environment = "Desafio iPET"
    Terraform   = "true"
  }
}


# REPOSITÓRIO DE IMAGENS (ECR)
resource "aws_ecr_repository" "app_ecr_repo" {
  # cd.yml
  name = "hello"

  # As tags podem ser sobrescritas (ex: a tag :latest)
  image_tag_mutability = "MUTABLE"

  # Força a deleção do repositório mesmo que ele tenha imagens dentro. (destruir tudo facilmente)
  force_delete = true

  tags = {
    Environment = "desafio-devops"
    Terraform   = "true"
  }
}