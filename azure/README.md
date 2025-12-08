# 🚀 Integração SQL Azure - EMATER-RO

Sistema completo de sincronização com SQL Azure para o formulário de extensionistas.

## 📋 Índice

1. [Arquitetura](#arquitetura)
2. [Pré-requisitos](#pré-requisitos)
3. [Configuração do Banco de Dados](#configuração-do-banco-de-dados)
4. [Deploy das Azure Functions](#deploy-das-azure-functions)
5. [Configuração do Frontend](#configuração-do-frontend)
6. [Testes](#testes)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Arquitetura

```
Frontend (Netlify)
    ↓↑ (HTTPS)
Azure Functions
    ↓↑ (SQL)
SQL Azure Database
```

**Modo Híbrido:**
- Salva localmente no IndexedDB
- Sincroniza automaticamente quando online
- Funciona 100% offline

---

## ✅ Pré-requisitos

- [ ] Conta Azure ativa
- [ ] Node.js 18+ instalado
- [ ] Azure CLI instalado
- [ ] VS Code com extensão Azure Functions
- [ ] SQL Server Management Studio (opcional)

---

## 🗄️ Configuração do Banco de Dados

### 1. Executar Script SQL

Conecte ao seu SQL Azure e execute:

```bash
# Usando Azure Data Studio ou SSMS
Servidor: srv-db-cxtce.database.windows.net
Database: db-ematech
Usuário: admin.dba
Senha: A57458974x23*
```

Execute o arquivo: `azure/schema.sql`

### 2. Verificar Tabelas Criadas

```sql
-- Ver tabelas
SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';

-- Ver views
SELECT * FROM INFORMATION_SCHEMA.VIEWS;

-- Testar inserção
SELECT * FROM vw_estatisticas;
```

---

## ☁️ Deploy das Azure Functions

### Opção 1: Via Azure Portal (Recomendado)

1. **Criar Function App:**
   ```
   Portal Azure → Create Resource → Function App
   
   Nome: formema-functions
   Região: Brazil South
   Runtime: Node.js 18
   OS: Linux
   ```

2. **Configurar Variável de Ambiente:**
   ```
   Settings → Configuration → New Application Setting
   
   Nome: SQL_PASSWORD
   Valor: A57458974x23*
   ```

3. **Deploy via VS Code:**
   - Instalar extensão Azure Functions
   - Abrir pasta `azure/`
   - Clicar com botão direito → Deploy to Function App
   - Selecionar `formema-functions`

### Opção 2: Via Azure CLI

```bash
# Login no Azure
az login

# Criar Resource Group (se não existir)
az group create --name cx-tce --location brazilsouth

# Criar Storage Account
az storage account create \
  --name formemast \
  --resource-group cx-tce \
  --location brazilsouth \
  --sku Standard_LRS

# Criar Function App
az functionapp create \
  --resource-group cx-tce \
  --consumption-plan-location brazilsouth \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name formema-functions \
  --storage-account formemast

# Configurar senha SQL
az functionapp config appsettings set \
  --name formema-functions \
  --resource-group cx-tce \
  --settings SQL_PASSWORD=A57458974x23*

# Instalar dependências e fazer deploy
cd azure
npm install
func azure functionapp publish formema-functions
```

### 3. Obter URL da Function

```bash
# Listar functions
az functionapp function list \
  --name formema-functions \
  --resource-group cx-tce

# A URL será algo como:
https://formema-functions.azurewebsites.net/api/formularios
```

---

## 🌐 Configuração do Frontend

### 1. Atualizar config.js

Edite `config.js` com a URL da sua Function:

```javascript
const CONFIG = {
    API_URL: 'https://formema-functions.azurewebsites.net/api',
    // ... resto da config
};
```

### 2. Adicionar Scripts ao HTML

No `index.html`, adicione antes de `db-extensionistas.js`:

```html
<script src="config.js"></script>
<script src="db-extensionistas.js"></script>
```

### 3. Atualizar admin.html

Substitua a função `sincronizarTodos()`:

```javascript
window.sincronizarTodos = async function() {
    const resultado = await sincronizarTodosComAzure();
    if (resultado.success) {
        alert(`✅ ${resultado.sincronizados} formulário(s) sincronizado(s)!`);
        location.reload();
    } else {
        alert(`❌ Erro: ${resultado.error}`);
    }
};
```

### 4. Sincronização Automática

Adicione ao final do `index.html`:

```javascript
// Sincronizar automaticamente após salvar
async function salvarFormularioCompleto(dados) {
    // Salvar localmente
    const resultado = await salvarFormulario(dados);
    
    // Tentar sincronizar se online
    if (navigator.onLine && CONFIG.SYNC.AUTO) {
        await sincronizarFormularioComAzure(resultado);
    }
    
    return resultado;
}

// Sincronizar periodicamente
if (CONFIG.SYNC.AUTO) {
    setInterval(async () => {
        if (navigator.onLine) {
            await sincronizarTodosComAzure();
        }
    }, CONFIG.SYNC.INTERVAL);
}
```

---

## 🧪 Testes

### 1. Testar Conexão com Banco

```bash
# Via PowerShell
cd azure
npm install
node -e "
const sql = require('mssql');
const config = {
    server: 'srv-db-cxtce.database.windows.net',
    database: 'db-ematech',
    user: 'admin.dba',
    password: 'A57458974x23*',
    options: { encrypt: true }
};
sql.connect(config).then(() => {
    console.log('✅ Conectado ao SQL Azure!');
    process.exit(0);
}).catch(err => {
    console.error('❌ Erro:', err);
    process.exit(1);
});
"
```

### 2. Testar Azure Functions Localmente

```bash
cd azure
npm install
func start

# Em outro terminal
curl -X POST http://localhost:7071/api/formularios \
  -H "Content-Type: application/json" \
  -d '{"protocolo":"TEST-001","status":"teste"}'

curl http://localhost:7071/api/formularios
```

### 3. Testar Frontend

1. Preencha um formulário no `index.html`
2. Abra o Console (F12)
3. Verifique logs:
   ```
   ✅ Formulário salvo no IndexedDB: FORM-2024-...
   🔄 Sincronizando formulário...
   ✅ Formulário sincronizado com Azure
   ```
4. Abra `admin.html` e veja se o formulário aparece

---

## 🔧 Troubleshooting

### ❌ Erro: "Connection failed"

**Causa:** Firewall do SQL Azure bloqueando IP

**Solução:**
```
Portal Azure → SQL Server → Firewalls and virtual networks
→ Add client IP → Save
```

### ❌ Erro: "CORS policy"

**Causa:** CORS não configurado na Function

**Solução:** Já configurado nos arquivos! Se persistir:
```bash
az functionapp cors add \
  --name formema-functions \
  --resource-group cx-tce \
  --allowed-origins https://formextensionista.netlify.app
```

### ❌ Erro: "mssql module not found"

**Causa:** Dependências não instaladas

**Solução:**
```bash
cd azure
npm install
```

### ⚠️ Formulários não sincronizam

1. Verifique conexão: Console → `navigator.onLine`
2. Verifique config: Console → `CONFIG.API_URL`
3. Teste manualmente: Console → `sincronizarTodosComAzure()`
4. Veja erros: Console → Network tab

---

## 📊 Monitoramento

### Ver Logs das Functions

```bash
# Via CLI
az functionapp log tail \
  --name formema-functions \
  --resource-group cx-tce

# Via Portal
Portal Azure → Function App → Monitoring → Log stream
```

### Queries Úteis

```sql
-- Total de formulários
SELECT COUNT(*) FROM formularios;

-- Formulários por município
SELECT municipio, COUNT(*) as total 
FROM formularios 
GROUP BY municipio 
ORDER BY total DESC;

-- Últimas submissões
SELECT TOP 10 protocolo, municipio, timestamp_fim 
FROM formularios 
ORDER BY timestamp_fim DESC;

-- Estatísticas gerais
SELECT * FROM vw_estatisticas;

-- Cobertura por unidade
SELECT * FROM vw_cobertura_unidades 
ORDER BY total_visitas DESC;
```

---

## 🎯 Próximos Passos

- [ ] Executar `schema.sql` no SQL Azure
- [ ] Deploy das Azure Functions
- [ ] Atualizar `config.js` com URL da Function
- [ ] Testar sincronização
- [ ] Commit e push para GitHub
- [ ] Deploy automático no Netlify
- [ ] Configurar CORS se necessário
- [ ] Monitorar logs por 24h

---

## 📞 Suporte

Dúvidas? Verifique:
1. Logs do Console do navegador
2. Logs da Azure Function
3. Firewall do SQL Azure
4. CORS configurado
5. Variável SQL_PASSWORD definida

---

**✅ Sistema pronto para sincronização com SQL Azure!**
