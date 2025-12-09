# 🚀 Deploy Backend - Formulário GERENTES

## 📋 Visão Geral

Este guia documenta o processo de deploy do backend para o formulário de Gerentes Locais Emater-RO.

**Arquivos Criados:**
- `database/schema-gerentes.sql` - Schema SQL Azure
- `netlify/functions/salvar-gerentes.js` - Function para salvar
- `netlify/functions/buscar-gerentes.js` - Function para buscar
- `db-gerentes.js` - IndexedDB (já existente)
- `gerentes.html` - Formulário frontend (já existente)

---

## 🗄️ PASSO 1: Criar Tabela no Azure SQL

### 1.1 Conectar ao Banco

**Opção A: Azure Data Studio**
```
Servidor: srv-db-cxtce.database.windows.net
Database: db-ematech
Usuário: admin.dba
Senha: A57458974x23*
```

**Opção B: Azure Portal Query Editor**
1. Acesse https://portal.azure.com
2. SQL databases → db-ematech
3. Query editor (preview)
4. Login com admin.dba

### 1.2 Executar Script

Abra e execute o arquivo:
```
database/schema-gerentes.sql
```

**O que será criado:**
- ✅ Tabela `formulario_gerentes` (26 questões)
- ✅ Trigger de atualização de timestamp
- ✅ 6 views de análise:
  - `vw_estatisticas_gerentes`
  - `vw_cobertura_municipios_gerentes`
  - `vw_ranking_desafios_gerentes`
  - `vw_analise_planejamento_gerentes`
  - `vw_engajamento_foruns_gerentes`

### 1.3 Verificar Criação

```sql
-- Verificar tabela
SELECT * FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'formulario_gerentes';

-- Verificar views
SELECT * FROM INFORMATION_SCHEMA.VIEWS 
WHERE TABLE_NAME LIKE '%gerentes%';

-- Testar inserção
SELECT COUNT(*) FROM formulario_gerentes;
```

---

## ☁️ PASSO 2: Deploy Netlify Functions

### 2.1 Estrutura de Pastas

Certifique-se que a estrutura está correta:

```
formema/
├── netlify/
│   └── functions/
│       ├── salvar-gerentes.js  ✅ NOVO
│       ├── buscar-gerentes.js  ✅ NOVO
│       ├── SaveFormulario/     (extensionistas - já existe)
│       └── GetFormularios/     (extensionistas - já existe)
├── gerentes.html               ✅ ATUALIZADO
└── db-gerentes.js              ✅ JÁ EXISTE
```

### 2.2 Instalar Dependências

```powershell
cd netlify\functions
npm install mssql
```

### 2.3 Commit e Push

```powershell
git add .
git commit -m "feat(gerentes): adicionar backend Azure SQL

- Criar tabela formulario_gerentes no Azure SQL
- Adicionar Netlify Function salvar-gerentes
- Adicionar Netlify Function buscar-gerentes
- 6 views de análise criadas
- Suporte para 26 questões completas"

git push origin feature/formulario-gerentes
```

### 2.4 Deploy Automático

O Netlify detectará as novas functions automaticamente após o push.

**Aguarde 2-3 minutos** para o build completar.

### 2.5 Verificar Deploy

Acesse: https://app.netlify.com/sites/formextensionista/deploys

**URLs das Functions:**
- `https://formextensionista.netlify.app/.netlify/functions/salvar-gerentes`
- `https://formextensionista.netlify.app/.netlify/functions/buscar-gerentes`

---

## 🔐 PASSO 3: Configurar Variáveis de Ambiente

### 3.1 No Netlify Dashboard

1. Site settings → Environment variables
2. Adicionar variável (se ainda não existe):
   - **Key:** `SQL_PASSWORD`
   - **Value:** `A57458974x23*`
   - **Scopes:** All scopes

### 3.2 Verificar Firewall Azure SQL

⚠️ **CRÍTICO**: Certifique-se que o firewall está configurado!

**Verificar no Portal Azure:**
```
SQL servers → srv-db-cxtce → Security → Networking
☑️ "Allow Azure services and resources to access this server"
```

**Ou via PowerShell:**
```powershell
az sql server firewall-rule list `
  --resource-group rg-ematech `
  --server srv-db-cxtce `
  --output table
```

**Deve existir regra:** `AllowAllAzureServices` (0.0.0.0 → 0.0.0.0)

Se não existir, executar:
```powershell
.\configurar-firewall-azure.ps1
```

---

## 🧪 PASSO 4: Testes

### 4.1 Testar Function Localmente (Opcional)

```powershell
# Instalar Netlify CLI
npm install -g netlify-cli

# Testar localmente
cd C:\Users\darkf\OneDrive\Documentos\formema
netlify dev
```

Acesse: http://localhost:8888/gerentes.html

### 4.2 Testar Function em Produção

**Teste 1: Salvar formulário**
```powershell
$body = @{
    protocolo = "TEST-GEREN-12345"
    municipio = "Porto Velho"
    escritorioLocal = "Porto Velho"
    tempoGerente = "1a3"
} | ConvertTo-Json

Invoke-RestMethod `
  -Method POST `
  -Uri "https://formextensionista.netlify.app/.netlify/functions/salvar-gerentes" `
  -Body $body `
  -ContentType "application/json"
```

**Teste 2: Buscar formulário**
```powershell
Invoke-RestMethod `
  -Uri "https://formextensionista.netlify.app/.netlify/functions/buscar-gerentes?protocolo=TEST-GEREN-12345"
```

**Teste 3: Listar todos**
```powershell
Invoke-RestMethod `
  -Uri "https://formextensionista.netlify.app/.netlify/functions/buscar-gerentes?limite=10"
```

### 4.3 Testar Formulário Completo

1. Acesse: https://formextensionista.netlify.app/gerentes.html
2. Preencha o formulário completo
3. Submeta
4. Verifique no Azure SQL:

```sql
SELECT TOP 10 
    protocolo,
    municipio,
    escritorio_local,
    tempo_gerente,
    created_at
FROM formulario_gerentes
ORDER BY created_at DESC;
```

---

## 📊 PASSO 5: Validação Final

### 5.1 Checklist de Validação

- [ ] Tabela `formulario_gerentes` criada no Azure SQL
- [ ] 6 views criadas (vw_*_gerentes)
- [ ] Function `salvar-gerentes` deployada
- [ ] Function `buscar-gerentes` deployada
- [ ] Variável `SQL_PASSWORD` configurada no Netlify
- [ ] Firewall Azure SQL configurado
- [ ] Teste de inserção manual bem-sucedido
- [ ] Teste de busca manual bem-sucedido
- [ ] Formulário HTML funcionando end-to-end

### 5.2 Queries de Validação

```sql
-- Estatísticas gerais
SELECT * FROM vw_estatisticas_gerentes;

-- Cobertura por município
SELECT * FROM vw_cobertura_municipios_gerentes;

-- Ranking de desafios
SELECT * FROM vw_ranking_desafios_gerentes
ORDER BY media_impacto DESC;

-- Análise de planejamento
SELECT * FROM vw_analise_planejamento_gerentes;

-- Engajamento em fóruns
SELECT * FROM vw_engajamento_foruns_gerentes;
```

---

## 🔧 Troubleshooting

### Erro: "Cannot open server"

**Causa:** Firewall bloqueando Netlify IPs

**Solução:**
```powershell
.\configurar-firewall-azure.ps1
```

Aguarde 5 minutos para propagação.

### Erro: "Invalid column name"

**Causa:** Campo faltando na tabela

**Solução:** Re-executar schema.sql ou adicionar coluna:
```sql
ALTER TABLE formulario_gerentes
ADD nome_coluna NVARCHAR(MAX) NULL;
```

### Erro: "Login failed"

**Causa:** Senha incorreta ou variável não configurada

**Solução:**
1. Verificar variável `SQL_PASSWORD` no Netlify
2. Testar login manual no Azure Data Studio

### Erro: "Request timeout"

**Causa:** Query muito lenta ou conexão instável

**Solução:**
1. Verificar índices criados
2. Aumentar timeout em `salvar-gerentes.js`:
```javascript
requestTimeout: 60000  // 60 segundos
```

---

## 🎯 Próximos Passos

Após validação completa:

1. **Merge para develop:**
   ```powershell
   git checkout develop
   git merge feature/formulario-gerentes
   git push origin develop
   ```

2. **Criar página administrativa:**
   - Visualizar formulários de gerentes
   - Relatórios específicos
   - Exportação de dados

3. **Documentação adicional:**
   - Manual do usuário
   - Guia de análise de dados
   - Dashboards no Power BI

4. **Testes de campo:**
   - Piloto com 5-10 gerentes
   - Coletar feedback
   - Ajustes finais

---

## 📞 Suporte

**Problemas com Azure SQL:**
- Portal: https://portal.azure.com
- Logs: SQL Database → Monitoring → Insights

**Problemas com Netlify:**
- Dashboard: https://app.netlify.com
- Logs: Site → Functions → Logs

**Problemas com Código:**
- Verificar console do navegador (F12)
- Verificar logs da Netlify Function
- Testar com dados mínimos primeiro

---

## ✅ Status Atual

**✅ COMPLETO:**
- Schema SQL criado
- Netlify Functions criadas
- IndexedDB configurado
- Formulário HTML pronto

**🔄 PENDENTE:**
- [ ] Executar schema.sql no Azure
- [ ] Deploy das functions (commit + push)
- [ ] Testes de integração
- [ ] Validação end-to-end

**⏭️ PRÓXIMO:**
Execute PASSO 1 (Criar tabela no Azure SQL)
