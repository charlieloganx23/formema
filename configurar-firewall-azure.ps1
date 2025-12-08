# Script para configurar firewall do Azure SQL Database
# Executar após fazer login: az login

# Variáveis
$resourceGroup = "rg-ematech"  # Ajuste se necessário
$serverName = "srv-db-cxtce"
$databaseName = "db-ematech"

Write-Host "🔥 Configurando Firewall do Azure SQL..." -ForegroundColor Cyan

# Permitir serviços do Azure
Write-Host "1. Permitindo serviços do Azure..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "AllowAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0

# Adicionar range do Netlify (AWS US-EAST-2)
Write-Host "2. Adicionando range do Netlify..." -ForegroundColor Yellow
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "Netlify-Functions" `
    --start-ip-address 52.0.0.0 `
    --end-ip-address 52.255.255.255

# Adicionar range adicional
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "Netlify-Functions-2" `
    --start-ip-address 44.192.0.0 `
    --end-ip-address 44.255.255.255

Write-Host "✅ Firewall configurado com sucesso!" -ForegroundColor Green
Write-Host "⏳ Aguarde até 5 minutos para as regras entrarem em vigor." -ForegroundColor Cyan

# Listar regras de firewall
Write-Host "`n📋 Regras de firewall atuais:" -ForegroundColor Cyan
az sql server firewall-rule list `
    --resource-group $resourceGroup `
    --server $serverName `
    --output table
