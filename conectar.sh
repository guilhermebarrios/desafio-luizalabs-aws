#!/bin/bash
echo "Configurando kubectl para o cluster desafio-luizalabs..."
aws eks update-kubeconfig --region us-east-1 --name challenge-cluster
echo "Pronto! Testando a conexão:"
kubectl get nodes