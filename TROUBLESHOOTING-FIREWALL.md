# 🔧 Troubleshooting: Firewall Azure SQL

## 🔍 Diagnóstico do Problema

### IPs Netlify Detectados:
- `52.14.69.28` - AWS us-east-2 (Ohio)
- `18.219.75.230` - AWS us-east-2 (Ohio)

**Padrão identificado**: Netlify Functions usa IPs dinâmicos da AWS região us-east-2.

---

## ✅ Checklist de Verificação

Execute este checklist ANTES de tentar qualquer solução:

### 1. Verificar se a regra existe
```bash
az sql server firewall-rule list \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --output table
```

**O que procurar**:
- [ ] Regra com nome "AllowAllAzureServices" ou similar
- [ ] Start IP: 0.0.0.0
- [ ] End IP: 0.0.0.0

### 2. Verificar no Portal Azure
1. Portal → SQL servers → srv-db-cxtce → Networking
2. Verificar se está marcado: ☑️ "Allow Azure services..."
3. Se NÃO estiver marcado → MARCAR e SALVAR

### 3. Verificar tempo de propagação
- [ ] Esperou pelo menos 5 minutos após salvar?
- [ ] Limpou cache do navegador?
- [ ] Testou em aba anônima?

---

## 🔥 Soluções por Ordem de Efetividade

### **Solução 1: Permitir Serviços Azure (99% efetivo)**

**Portal Azure Manual**:
1. https://portal.azure.com
2. SQL servers → srv-db-cxtce
3. Security → Networking
4. ☑️ "Allow Azure services and resources to access this server"
5. **Save**
6. Aguardar 5 minutos

**PowerShell Automático**:
```powershell
az login
.\configurar-firewall-azure.ps1
```

**Azure CLI Direto**:
```bash
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AllowAllAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

---

### **Solução 2: Adicionar Ranges Completos da AWS (90% efetivo)**

Se a Solução 1 não funcionar, adicione os ranges completos:

```bash
# Range 1: AWS us-east-2 primário
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AWS-US-EAST-2-Primary \
  --start-ip-address 18.216.0.0 \
  --end-ip-address 18.223.255.255

# Range 2: AWS us-east-2 secundário
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AWS-US-EAST-2-Secondary \
  --start-ip-address 52.14.0.0 \
  --end-ip-address 52.15.255.255

# Range 3: AWS us-east-1 (Netlify também usa)
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AWS-US-EAST-1 \
  --start-ip-address 44.192.0.0 \
  --end-ip-address 44.255.255.255
```

---

### **Solução 3: Adicionar IP Específico (temporário)**

Se nenhuma funcionar, adicione o IP atual que está falhando:

```bash
# Substitua X.X.X.X pelo IP que aparece no erro
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name Netlify-Specific-IP \
  --start-ip-address X.X.X.X \
  --end-ip-address X.X.X.X
```

⚠️ **Problema**: Isso funcionará apenas até o próximo deploy do Netlify.

---

## 🐛 Erros Comuns

### Erro 1: "Rule already exists"
**Solução**: A regra já existe. Verifique se está correta:
```bash
az sql server firewall-rule show \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AllowAllAzureServices
```

Se estiver errada, delete e recrie:
```bash
az sql server firewall-rule delete \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AllowAllAzureServices

# Depois recrie com comandos da Solução 1
```

---

### Erro 2: "Resource group not found"
**Solução**: Descubra o nome correto do resource group:
```bash
az sql server list --output table
```

Procure por `srv-db-cxtce` na lista e veja o ResourceGroup correto.

---

### Erro 3: "Ainda dá erro após 10 minutos"
**Possíveis causas**:

1. **Regra não foi salva**
   - Volte ao Portal Azure e verifique
   - Regra deve estar visível na lista

2. **Resource Group errado**
   - Liste todos os servers: `az sql server list`
   - Confirme o nome exato

3. **Problema nas credenciais do banco**
   - Verifique variáveis de ambiente no Netlify
   - Vá em: Netlify Dashboard → Site → Environment variables
   - Confirme: DB_SERVER, DB_NAME, DB_USER, DB_PASSWORD

4. **Firewall do Azure ativo em outro nível**
   - Verifique se há firewall na subscription level
   - Portal → Subscriptions → sua subscription → Settings

---

## 📊 Teste de Conectividade

### Método 1: Via Browser Console
```javascript
// Cole no console do navegador em formextensionista.netlify.app
fetch('/.netlify/functions/salvar-formulario', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({test: true})
})
.then(r => r.json())
.then(console.log)
.catch(console.error)
```

**Resultado esperado**:
- ✅ Status 200 ou 400 (mas NÃO 500)
- ❌ Status 500 = firewall ainda bloqueando

---

### Método 2: Via Netlify Functions Logs
1. Netlify Dashboard → Site → Functions
2. Clique em `salvar-formulario`
3. Veja os logs de execução
4. Procure por mensagens de erro SQL

---

## 🔄 Última Tentativa: Recreate Firewall Rules

Se NADA funcionar, delete TODAS as regras e comece do zero:

```powershell
# Listar todas as regras
az sql server firewall-rule list \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --query "[].name" -o tsv

# Deletar todas (cuidado!)
az sql server firewall-rule list \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --query "[].name" -o tsv | ForEach-Object {
    az sql server firewall-rule delete `
      --resource-group rg-ematech `
      --server srv-db-cxtce `
      --name $_
}

# Recriar apenas a regra essencial
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AllowAllAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

---

## 🆘 Suporte

Se nenhuma solução funcionar:

1. **Verificar logs do Netlify Functions**
   - Netlify Dashboard → Functions → salvar-formulario
   - Ver stack trace completo

2. **Testar conexão SQL diretamente**
   ```bash
   sqlcmd -S srv-db-cxtce.database.windows.net -d db-ematech -U <user> -P <pass>
   ```

3. **Verificar se o servidor Azure SQL está online**
   - Portal → SQL servers → srv-db-cxtce
   - Status deve ser "Online"

4. **Última opção: Migrar para outro serviço**
   - Considerar: Azure Functions (mesma região do banco)
   - Ou: Adicionar camada de API intermediária

---

## ✅ Confirmação de Sucesso

Você saberá que funcionou quando:
- ✅ Formulário envia sem erro 500
- ✅ Console mostra: "✅ Sincronizado com sucesso!"
- ✅ Admin panel mostra formulário novo
- ✅ Logs do Netlify não têm erro de SQL

---

**Documentação Oficial Azure**:
- [Configurar Firewall SQL Database](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure)
- [Allow Azure Services](https://learn.microsoft.com/azure/azure-sql/database/network-access-controls-overview)
