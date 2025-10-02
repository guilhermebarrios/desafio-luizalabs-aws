Desafio Técnico iPET - Luiza Labs
Autor: Guilherme Barrios

Status do Projeto: **Concluído.**

**1.** Objetivo
Este repositório contém a solução completa para o desafio técnico da vaga de Analista de Infraestrutura Pleno (iPET). O objetivo foi provisionar um cluster Kubernetes na AWS de forma automatizada e segura, e realizar o deploy de uma aplicação "HelloWorld", abordando os pilares de SRE, DevOps e Engenharia de Infraestrutura.

**2.** Arquitetura da Solução
A arquitetura foi projetada para ser resiliente, segura e otimizada em custos, utilizando os serviços gerenciados da AWS para garantir a estabilidade.

Diagrama da Infraestrutura:
![Diagrama-Infra](https://github.com/user-attachments/assets/df07b075-817b-48ae-b376-32086982750f)

Fluxo de Dados Principais:
Tráfego do Usuário (Entrada): O tráfego da internet passa pelo Internet Gateway, é recebido por um Application Load Balancer (ALB) nas sub-redes públicas, e distribuído de forma segura para as instâncias EC2 (Nós do EKS) que rodam a aplicação nas sub-redes privadas.

Tráfego da Aplicação (Saída): 
Para comunicação com a internet (como o download de imagens do ECR), os nós na sub-rede privada utilizam um NAT Gateway posicionado na sub-rede pública.


**3.** Principais Decisões de Engenharia
Este projeto não foi apenas sobre criar os recursos, mas sobre tomar decisões de arquitetura. As principais foram:

**Segurança em Camadas:** A arquitetura foi pensada com segurança em mente:

**Rede:** Os nós de trabalho rodam em sub-redes privadas, sem exposição direta à internet.
Acesso: A API do EKS é restrita por IP (public_access_cidrs) e a autenticação da pipeline usa OIDC, sem chaves de acesso de longa duração.

**Contêiner:** A imagem Docker foi "endurecida" (hardening), rodando com um usuário não-root.

**Arquitetura Híbrida de Nós (Custo vs. Confiabilidade):**
A arquitetura consiste em um cluster EKS com um grupo de nós On-Demand, distribuídos em múltiplas Zonas de Disponibilidade para garantir a alta disponibilidade. Esta base estável serve para rodar tanto os componentes de sistema do Kubernetes quanto a aplicação "HelloWorld".

**Infraestrutura Imutável e Automação:**
O deploy da aplicação é 100% automatizado via CI/CD. A cada push, uma nova imagem Docker é criada e o Kubernetes substitui os pods antigos pelos novos. Nenhum servidor é alterado manualmente, seguindo o paradigma de infraestrutura imutável.

**Observabilidade desde o Início:**
A aplicação Python já foi desenvolvida com um endpoint /metrics no formato Prometheus. Isso mostra um pensamento de SRE, onde a monitoria não é uma etapa final, mas parte do design da aplicação.

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


| Área                           | Implementação                                                       |
| ------------------------------ | ------------------------------------------------------------------- |
| **Segurança**                  | Subnets privadas, princípio do menor privilégio, IAM roles mínimos. |
| **Alta disponibilidade**       | Cluster EKS distribuído em 3 AZs.                                   |
| **Eficiência de custo**        | Possibilidade de usar EC2 Spot Instances para Node Groups.          |
| **Monitoria e desempenho**     | HPA + Load Generator.                                               |
| **Infraestrutura como código** | Terraform totalmente reprodutível.                                  |
| **CI/CD**                      | GitHub Actions com validações, build e deploy automatizado.         |


Autor:
Guilherme Barrios
