Desafio Técnico iPET - Luiza Labs
Autor: Guilherme Barrios

Status do Projeto: **Concluído.**

---------------------------------------------------------------------------
**1. Objetivo**
Este repositório contém a solução completa para o desafio técnico da vaga de Analista de Infraestrutura Pleno (iPET). O objetivo foi provisionar um cluster Kubernetes na AWS de forma automatizada e segura, e realizar o deploy de uma aplicação "HelloWorld", abordando os pilares de SRE, DevOps e Engenharia de Infraestrutura.

**2. Arquitetura da Solução**
A arquitetura foi projetada para ser resiliente, segura e otimizada em custos, utilizando os serviços gerenciados da **AWS** para garantir a estabilidade.

![Diagrama-Infra](https://github.com/user-attachments/assets/87159383-290f-45ec-824a-6d3fb6f163ae)

---------------------------------------------------------------------------

Fluxo de Dados Principais:

**Tráfego do Usuário (Entrada):** O tráfego da internet passa pelo Internet Gateway, é recebido por um Application Load Balancer (ALB) nas sub-redes públicas, e distribuído de forma segura para as instâncias EC2 (Nós do EKS) que rodam a aplicação nas sub-redes privadas.

**Tráfego da Aplicação (Saída):** Para comunicação com a internet (como o download de imagens do ECR), os nós na sub-rede privada utilizam um NAT Gateway posicionado na sub-rede pública.

---------------------------------------------------------------------------

**Tecnologias Utilizadas:**
IaC (Infraestrutura como Código):
- [Terraform](https://www.terraform.io/) – Infraestrutura como código

Cloud (AWS):
- [AWS EKS](https://aws.amazon.com/eks/) – Cluster Kubernetes gerenciado
- [AWS EC2](https://aws.amazon.com/ec2/) – Instâncias de nó
- [AWS VPC](https://aws.amazon.com/vpc/) – Rede privada e pública
- [AWS ECR](https://aws.amazon.com/ecr/) – Repositório de container images

Kubernetes:
- [kubectl](https://kubernetes.io/docs/tasks/tools/) – CLI Kubernetes
- [Helm](https://helm.sh/) – Gerenciamento de charts Kubernetes

Containerização:
- [Docker](https://www.docker.com/) – Containerização de aplicações

Aplicação:
- [Python](https://www.python.org/) – Linguagem da aplicação

CI/CD (Automação) - CI/CD – Integração e entrega contínua:
- [Git](https://git-scm.com/) – Controle de versão

---------------------------------------------------------------------------

**Principais Decisões de Engenharia:**
Este projeto não foi apenas sobre criar os recursos, mas sobre tomar decisões de arquitetura. As principais foram:

1. Segurança em Camadas: A arquitetura foi pensada com segurança em mente:

2. Rede: Os nós de trabalho rodam em sub-redes privadas, sem exposição direta à internet.

3. Acesso: A API do EKS é restrita por IP (public_access_cidrs) e a autenticação da pipeline usa OIDC, sem chaves de acesso de longa duração.

4. Contêiner: A imagem Docker rodando com um usuário não-root.

---------------------------------------------------------------------------

**Arquitetura Híbrida de Nós (Custo vs. Confiabilidade):**
Para garantir uma demonstração 100% estável e previsível, optei por um único grupo de nós com instâncias On-Demand. Essa abordagem elimina os riscos de interrupção associados às instâncias Spot, garantindo que tanto a aplicação quanto os serviços críticos do Kubernetes tivessem uma base resiliente para a apresentação. Em um cenário de produção real, eu evoluiria esta arquitetura para um modelo híbrido (com nós Spot para a aplicação) para otimizar os custos, como explorei durante o desenvolvimento.


**Infraestrutura Imutável e Automação:**
O deploy da aplicação é 100% automatizado via CI/CD. A cada push, uma nova imagem Docker é criada e o Kubernetes substitui os pods antigos pelos novos. Nenhum servidor é alterado manualmente, seguindo o paradigma de infraestrutura imutável.


**Observabilidade desde o Início:**
A aplicação Python já foi desenvolvida com um endpoint **/metrics** no formato Prometheus. Isso mostra um pensamento de SRE, onde a monitoria não é uma etapa final, mas parte do design da aplicação.

---------------------------------------------------------------------------

**Como Executar o Projeto**
Pré-requisitos:

-- Terraform instalado.

-- AWS CLI instalado e configurado (aws configure).

-- kubectl instalado.


**Provisionar a Infraestrutura:**

# Navegue até a pasta de infra
cd infra

# Inicialize o Terraform
terraform init

# Crie a infraestrutura (pode levar ~20 minutos)
terraform apply

Configurar Acesso kubectl:
# Configure o kubectl para o novo cluster
aws eks update-kubeconfig --region us-east-1 --name cluster-desafio-luizalabs-v2

---------------------------------------------------------------------------

**Deploy da Aplicação:**
Faça um push de qualquer alteração na branch main do repositório. A pipeline do GitHub Actions será acionada e fará o deploy automaticamente.


**Desafios e Aprendizados:**
Durante o desenvolvimento, enfrentei desafios reais que foram grandes oportunidades de aprendizado, como depurar erros de NodeCreationFailure no EKS (resolvido com o ajuste de tags na VPC), ImagePullBackOff (resolvido com a correção de permissões IAM nos nós) e conflitos de dependência no Python (resolvido travando as versões no requirements.txt).

---------------------------------------------------------------------------

Autor:
**Guilherme Barrios**
