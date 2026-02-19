# 🔧 RESOLVER ERRO 503 - Netlify não conecta ao Azure SQL

## ❌ Problema
```
POST /.netlify/functions/login 503 (Service Unavailable)
❌ Erro ao conectar com o banco de dados.
```

---

## ✅ SOLUÇÃO COMPLETA

### **1️⃣ Configurar Variáveis de Ambiente no Netlify**

1. **Acesse**: https://app.netlify.com
2. **Selecione** seu site (formextensionista)
3. **Site configuration** → **Environment variables**
4. **Adicione estas 4 variáveis** (clique em "Add a variable" para cada):

| Key | Value | Scopes |
|-----|-------|--------|
| `AZURE_SQL_SERVER` | `srv-db-cxtce.database.windows.net` | All scopes |
| `AZURE_SQL_DATABASE` | `db-ematech` | All scopes |
| `AZURE_SQL_USER` | `admin.dba` | All scopes |
| `AZURE_SQL_PASSWORD` | `A57458974x23*` | All scopes |

**⚠️ IMPORTANTE:**
- NÃO use aspas nos valores
- A senha tem maiúscula: `A57458974x23*`
- Certifique-se de não ter espaços extras

5. **Salve** todas as variáveis

---

### **2️⃣ Configurar Firewall do Azure SQL**

O Netlify usa IPs dinâmicos, então precisa permitir **serviços do Azure**:

1. **Portal Azure**: https://portal.azure.com
2. Navegue: **SQL databases** → `db-ematech`
3. Menu lateral: **Networking** (ou **Firewalls and virtual networks**)
4. **Marque a opção**:
   - ✅ **"Allow Azure services and resources to access this server"**
   - Ou: **"Permitir que os serviços e recursos do Azure acessem este servidor"**
5. **Salve** as alterações
6. Aguarde 30 segundos

**Alternativamente**, adicione os IPs do Netlify:
- Adicione uma regra com:
  - Nome: `Netlify`
  - Start IP: `0.0.0.0`
  - End IP: `0.0.0.0`
- Isso permite conexões de qualquer origem (use apenas para teste)

---

### **3️⃣ Forçar Redeploy no Netlify**

1. No Netlify: **Deploys** → **Trigger deploy** → **Clear cache and deploy site**
2. Aguarde 2-3 minutos
3. Verifique os logs do deploy para ver se há erros

---

### **4️⃣ Testar Novamente**

Após configurar tudo:

1. **Limpe o cache** do navegador (Ctrl+Shift+R)
2. Acesse: https://formextensionista.netlify.app/login.html?tipo=extensionista
3. **Login**:
   - Usuário: `extensionista`
   - Senha: `ext123`
4. Deve funcionar! ✅

---

## 🔍 Verificar Logs de Erro

Se ainda não funcionar:

1. **Netlify**: Site → **Functions** → **login** → **Function log**
2. Procure por mensagens de erro detalhadas
3. Me envie o log completo

---

## 🧪 Teste Local (Opcional)

Para testar se as credenciais do banco estão corretas:

1. Abra o **Azure Data Studio** ou **SQL Server Management Studio**
2. Conecte com:
   - Server: `srv-db-cxtce.database.windows.net`
   - Database: `db-ematech`
   - Username: `admin.dba`
   - Password: `A57458974x23*`
3. Se conectar, as credenciais estão corretas
4. Execute: `SELECT @@VERSION;`
5. Deve retornar a versão do SQL Server

---

## 📊 Checklist

- [ ] Variáveis de ambiente configuradas no Netlify (4 variáveis)
- [ ] Firewall do Azure permite serviços Azure
- [ ] Redeploy forçado no Netlify
- [ ] Cache do navegador limpo
- [ ] Testado login com `extensionista / ext123`

---

**Faça os passos 1 e 2 acima e me confirme quando terminar!** 🚀
