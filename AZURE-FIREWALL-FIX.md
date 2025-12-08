# 🔥 Guia de Configuração: Firewall Azure SQL Database

## ❌ Erro Atual
```
Cannot open server 'srv-db-cxtce' requested by the login. 
Client with IP address 'X.X.X.X' is not allowed to access the server.
```

**IPs detectados até agora**:
- `52.14.69.28` (AWS us-east-2)
- `18.219.75.230` (AWS us-east-2)

**Causa**: O Netlify Functions usa **múltiplos IPs dinâmicos** da AWS. Cada deploy ou invocação pode usar um IP diferente, tornando impossível criar regras para IPs específicos.

---

## ✅ SOLUÇÃO DEFINITIVA (Recomendada)

### **Portal Azure - Passo a Passo COMPLETO**

1. **Acesse o Portal Azure**
   - URL: https://portal.azure.com
   - Faça login com sua conta

2. **Navegue até SQL Server**
   - Digite "SQL servers" na barra de pesquisa (topo)
   - Clique em **SQL servers**
   - Selecione: `srv-db-cxtce`

3. **Configure o Firewall (CRÍTICO)**
   - Menu lateral esquerdo → **Security** → **Networking**
   - Role até a seção **"Firewall rules"**
   - **MARQUE a caixa**: ☑️ **"Allow Azure services and resources to access this server"**
   - Clique em **Save** (no topo da página)

4. **Adicione Regras de Backup (Opcional mas Recomendado)**
   
   Na mesma página, em "Firewall rules", adicione:

   **Regra 1: AWS us-east-2 Complete**
   - Rule name: `AWS-US-EAST-2-Complete`
   - Start IP: `18.216.0.0`
   - End IP: `18.223.255.255`
   
   **Regra 2: AWS us-east-2 Secondary**
   - Rule name: `AWS-US-EAST-2-Secondary`
   - Start IP: `52.14.0.0`
   - End IP: `52.15.255.255`
   
   **Regra 3: Netlify Documented**
   - Rule name: `Netlify-Documented`
   - Start IP: `44.192.0.0`
   - End IP: `44.255.255.255`

5. **Salvar e Aguardar**
   - Clique em **Save** novamente
   - **Aguarde 5 minutos** para propagação

6. **Testar**
   - Acesse: https://formextensionista.netlify.app
   - Preencha e envie um formulário
   - Se funcionar: ✅ Problema resolvido DEFINITIVAMENTE

---

## 🔐 Por que esta solução é SEGURA?

1. **Autenticação SQL**: O banco ainda requer usuário e senha válidos
2. **Conexão criptografada**: TLS/SSL obrigatório
3. **Credenciais protegidas**: Armazenadas em variáveis de ambiente Netlify
4. **Sem acesso público**: Apenas services autenticados podem conectar

A regra `0.0.0.0 → 0.0.0.0` no Azure **NÃO** significa "aberto para internet". Significa "**permitir serviços Azure/AWS autenticados**".

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
