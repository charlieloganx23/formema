# 🔥 Guia de Configuração: Firewall Azure SQL Database

## ❌ Erro Atual
```
Cannot open server 'srv-db-cxtce' requested by the login. 
Client with IP address '52.14.69.28' is not allowed to access the server.
```

**Causa**: O firewall do Azure SQL está bloqueando conexões do Netlify Functions.

---

## ✅ Solução 1: Portal Azure (Mais Fácil)

### Passo a Passo:

1. **Acesse o Portal Azure**
   - URL: https://portal.azure.com
   - Faça login com sua conta

2. **Navegue até o SQL Server**
   - Procure por "SQL servers" na barra de pesquisa
   - Clique em `srv-db-cxtce`

3. **Configure o Firewall**
   - No menu lateral esquerdo, vá em **Segurança** → **Networking**
   - Na seção "Firewall rules", ative:
     ☑️ **"Allow Azure services and resources to access this server"**
   - Clique em **Save** (Salvar)

4. **Aguarde**
   - As mudanças podem levar até 5 minutos para entrar em vigor

---

## ✅ Solução 2: Adicionar Regras Específicas

Se preferir adicionar apenas os IPs do Netlify:

### No Portal Azure:

1. Vá em **SQL servers** → `srv-db-cxtce` → **Networking**
2. Clique em **+ Add a firewall rule**
3. Adicione estas regras:

**Regra 1:**
- Nome: `Netlify-Functions`
- Start IP: `52.0.0.0`
- End IP: `52.255.255.255`

**Regra 2:**
- Nome: `Netlify-Functions-2`
- Start IP: `44.192.0.0`
- End IP: `44.255.255.255`

**Regra 3:**
- Nome: `Netlify-East-2`
- Start IP: `18.216.0.0`
- End IP: `18.223.255.255`

4. Clique em **Save**

---

## ✅ Solução 3: Via PowerShell (Automático)

### Pré-requisitos:
- Azure CLI instalado ([Download](https://aka.ms/installazurecliwindows))

### Executar:

```powershell
# 1. Fazer login no Azure
az login

# 2. Executar script de configuração
.\configurar-firewall-azure.ps1
```

---

## ✅ Solução 4: Via Azure Cloud Shell

1. Acesse: https://shell.azure.com
2. Escolha **PowerShell** ou **Bash**
3. Execute os comandos:

```bash
# Permitir serviços do Azure
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Adicionar IPs do Netlify
az sql server firewall-rule create \
  --resource-group rg-ematech \
  --server srv-db-cxtce \
  --name Netlify-Functions \
  --start-ip-address 52.0.0.0 \
  --end-ip-address 52.255.255.255
```

---

## 🔍 Verificar se Funcionou

Após configurar o firewall:

1. **Aguarde 5 minutos**
2. **Teste o formulário**:
   - Acesse: https://formextensionista.netlify.app
   - Preencha e envie um formulário
   - Vá em "Gerenciar Formulários" para verificar sincronização

3. **Verificar logs** (F12 → Console):
   - ✅ `✅ Sincronizado com sucesso!`
   - ❌ Se ainda der erro, adicione mais regras de IP

---

## 📋 Informações Técnicas

**Servidor Azure SQL:**
- Nome: `srv-db-cxtce.database.windows.net`
- Database: `db-ematech`
- Região: (verificar no portal)

**IPs do Netlify Functions:**
- Range principal: `52.0.0.0/8` (AWS us-east-2)
- Range secundário: `44.192.0.0/10` (AWS us-east-1)
- IP específico detectado: `52.14.69.28`

**Documentação Azure:**
- [Configurar Firewall SQL Database](https://learn.microsoft.com/azure/azure-sql/database/firewall-configure)

---

## 🆘 Solução de Problemas

### Se ainda não funcionar após 5 minutos:

1. **Verifique o Resource Group correto**:
   ```powershell
   az sql server list --output table
   ```

2. **Liste as regras de firewall**:
   ```powershell
   az sql server firewall-rule list \
     --resource-group rg-ematech \
     --server srv-db-cxtce \
     --output table
   ```

3. **Adicione o IP específico**:
   ```powershell
   az sql server firewall-rule create \
     --resource-group rg-ematech \
     --server srv-db-cxtce \
     --name Netlify-Specific \
     --start-ip-address 52.14.69.28 \
     --end-ip-address 52.14.69.28
   ```

---

## ✅ Após Configurar

Uma vez configurado o firewall:
- ✅ Formulários sincronizarão automaticamente com Azure SQL
- ✅ Admin panel mostrará todos os formulários
- ✅ Relatórios terão dados em tempo real
- ✅ Backup automático em nuvem funcionando

**Importante**: Esta configuração é **permanente** e só precisa ser feita uma vez.
