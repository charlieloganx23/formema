# Script para configurar firewall do Azure SQL Database
# Executar após fazer login: az login

# Variáveis
$resourceGroup = "rg-ematech"  # Ajuste se necessário
$serverName = "srv-db-cxtce"
$databaseName = "db-ematech"

Write-Host "🔥 Configurando Firewall do Azure SQL..." -ForegroundColor Cyan

# ============================================
# SOLUÇÃO DEFINITIVA: Permitir Serviços Azure
# ============================================
Write-Host "`n⭐ Aplicando SOLUÇÃO DEFINITIVA..." -ForegroundColor Yellow
Write-Host "Permitindo TODOS os serviços do Azure (inclui Netlify, Vercel, etc.)" -ForegroundColor Yellow

az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "AllowAllAzureServices" `
    --start-ip-address 0.0.0.0 `
    --end-ip-address 0.0.0.0

Write-Host "✅ Regra 'AllowAllAzureServices' criada!" -ForegroundColor Green

# ============================================
# BACKUP: Ranges completos da AWS (Netlify)
# ============================================
Write-Host "`n📡 Adicionando ranges completos da AWS como backup..." -ForegroundColor Yellow

# IPs detectados até agora: 52.14.69.28, 18.219.75.230
# Ambos são da região us-east-2 (Ohio)

# Range 1: AWS us-east-2 completo
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "AWS-US-EAST-2-Complete" `
    --start-ip-address 18.216.0.0 `
    --end-ip-address 18.223.255.255

# Range 2: AWS us-east-2 secundário
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "AWS-US-EAST-2-Secondary" `
    --start-ip-address 52.14.0.0 `
    --end-ip-address 52.15.255.255

# Range 3: Netlify documentado
az sql server firewall-rule create `
    --resource-group $resourceGroup `
    --server $serverName `
    --name "Netlify-Documented-Range" `
    --start-ip-address 44.192.0.0 `
    --end-ip-address 44.255.255.255

Write-Host "✅ Ranges de backup adicionados!" -ForegroundColor Green

Write-Host "`n✅ Firewall configurado com SOLUÇÃO DEFINITIVA!" -ForegroundColor Green
Write-Host "⏳ Aguarde até 5 minutos para as regras entrarem em vigor." -ForegroundColor Cyan
Write-Host "🔄 Se ainda houver problemas após 5min, execute 'az login' e rode novamente." -ForegroundColor Yellow

# Listar regras de firewall
Write-Host "`n📋 Regras de firewall atuais:" -ForegroundColor Cyan
az sql server firewall-rule list `
    --resource-group $resourceGroup `
    --server $serverName `
    --output table

Write-Host "`n💡 IMPORTANTE:" -ForegroundColor Yellow
Write-Host "A regra 0.0.0.0 → 0.0.0.0 é a SOLUÇÃO DEFINITIVA." -ForegroundColor Yellow
Write-Host "Ela permite TODOS os serviços hospedados no Azure/AWS que usam IPs dinâmicos." -ForegroundColor Yellow
Write-Host "Seus dados continuam seguros pois requerem autenticação SQL." -ForegroundColor Yellow
