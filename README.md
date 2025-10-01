Desafio técnico para Luizalabs - iPET

## Tecnologias utilizadas

- [Terraform](https://www.terraform.io/) – Infraestrutura como código
- [AWS EKS](https://aws.amazon.com/eks/) – Cluster Kubernetes gerenciado
- [AWS EC2](https://aws.amazon.com/ec2/) – Instâncias de nó
- [AWS VPC](https://aws.amazon.com/vpc/) – Rede privada e pública
- [AWS ECR](https://aws.amazon.com/ecr/) – Repositório de container images
- [kubectl](https://kubernetes.io/docs/tasks/tools/) – CLI Kubernetes
- [Helm](https://helm.sh/) – Gerenciamento de charts Kubernetes
- [Docker](https://www.docker.com/) – Containerização de aplicações
- [Python](https://www.python.org/) – Linguagem da aplicação
- [Git](https://git-scm.com/) – Controle de versão
- CI/CD –  Integração e entrega contínua (GitHub Actions, GitLab CI, Jenkins, etc.) Status: [![CD - Deploy da Aplicação HelloWorld no EKS](https://github.com/guilhermebarrios/desafio-luizalabs-aws/actions/workflows/cd.yaml/badge.svg)](https://github.com/guilhermebarrios/desafio-luizalabs-aws/actions/workflows/cd.yaml)


Descrição

Projeto de deploy automatizado em EKS na AWS utilizando boas práticas de DevOps, CI/CD e Infraestrutura como Código (IaC).

Inclui:
Cluster EKS com alta disponibilidade (3 AZs).
Deploy automatizado via GitHub Actions.
Load balancer público e subnets privadas.
Horizontal Pod Autoscaler (HPA).
Load generator para testes de performance.
Repositório ECR para imagens Docker.

Diagrama da Arquitetura:
Desafio_luizalabs-aws/
├─ k8s/
│  ├─ deployment.yaml
│  ├─ hpa.yaml
│  └─ load-generator-deployment.yaml
├─ terraform/
│  ├─ main.tf
│  └─ variables.tf
├─ .github/workflows/
│  └─ ci-cd.yaml
│  └─ infra.yaml
├─ Dockerfile
└─ README.md


| Área                           | Implementação                                                       |
| ------------------------------ | ------------------------------------------------------------------- |
| **Segurança**                  | Subnets privadas, princípio do menor privilégio, IAM roles mínimos. |
| **Alta disponibilidade**       | Cluster EKS distribuído em 3 AZs.                                   |
| **Eficiência de custo**        | Possibilidade de usar EC2 Spot Instances para Node Groups.          |
| **Monitoria e desempenho**     | HPA + Load Generator.                                               |
| **Infraestrutura como código** | Terraform totalmente reprodutível.                                  |
| **CI/CD**                      | GitHub Actions com validações, build e deploy automatizado.         |


Autor

Guilherme Barrios



