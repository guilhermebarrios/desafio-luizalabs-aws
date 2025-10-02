# conectar.ps1 - scrip para conectar ao cluster EKS usando powershell

Write-Host "Configurando kubectl para o cluster-desafio-luizalabs-v2..." -ForegroundColor Green
aws eks update-kubeconfig --region us-east-1 --name cluster-desafio-luizalabs-v2

Write-Host "Pronto! Testando a conexão:" -ForegroundColor Green
kubectl get nodes