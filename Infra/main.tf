# infra/providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.45.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# CORREÇÃO: Busca os dados do cluster usando a referência do recurso direto
data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.this.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.this.name
}

# Configura o provedor do Kubernetes com os dados corretos
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# infra/main.tf

# 1. REDE (VPC)
resource "aws_vpc" "desafio_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "desafio-vpc" }
}

resource "aws_subnet" "desafio_subnet_a" {
  vpc_id                  = aws_vpc.desafio_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "desafio-subnet-a" }
}

resource "aws_subnet" "desafio_subnet_b" {
  vpc_id                  = aws_vpc.desafio_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "desafio-subnet-b" }
}

resource "aws_internet_gateway" "desafio_igw" {
  vpc_id = aws_vpc.desafio_vpc.id
  tags   = { Name = "desafio-igw" }
}

resource "aws_route_table" "desafio_rt" {
  vpc_id = aws_vpc.desafio_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.desafio_igw.id
  }
  tags = { Name = "desafio-rt" }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.desafio_subnet_a.id
  route_table_id = aws_route_table.desafio_rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.desafio_subnet_b.id
  route_table_id = aws_route_table.desafio_rt.id
}

# 2. PERMISSÕES (IAM ROLES)
resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role-desafio"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_role" {
  name = "eks-node-role-desafio"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_node_role.name
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_node_role.name
}

# 3. CLUSTER EKS E NÓS
resource "aws_eks_cluster" "this" {
  name     = "desafio-cluster" # Nome do cluster
  version  = "1.28"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    # CORREÇÃO: subnets
    subnet_ids             = [aws_subnet.desafio_subnet_a.id, aws_subnet.desafio_subnet_b.id]
    endpoint_public_access = true
    public_access_cidrs    = [var.meu_ip_acesso]  # Meu IP
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "worker-nodes-desafio" # Nome do cluster
  node_role_arn   = aws_iam_role.eks_node_role.arn

  # CORREÇÃO: Nomes das subnets
  subnet_ids     = [aws_subnet.desafio_subnet_a.id, aws_subnet.desafio_subnet_b.id]
  instance_types = ["t3.small"]
  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }
  depends_on = [aws_iam_role_policy_attachment.eks_worker_node_policy]
}

# 4. REPOSITÓRIO DE IMAGENS (ECR)
resource "aws_ecr_repository" "app_ecr_repo" {
  name                 = "hello"
  image_tag_mutability = "MUTABLE"
  force_delete         = true
}

# 5. CONFIGURAÇÃO AUTOMÁTICA DO AWS-AUTH
resource "kubernetes_config_map_v1_data" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode([
      {
        groups   = ["system:bootstrappers", "system:nodes"]
        rolearn  = aws_iam_role.eks_node_role.arn
        username = "system:node:{{EC2PrivateDNSName}}"
      },
      {
        groups   = ["system:masters"]
        rolearn  = "arn:aws:iam::288761731142:role/github-desafio-role"
        username = "github-actions"
      },
    ])
  }

  depends_on = [aws_eks_node_group.nodes]
}