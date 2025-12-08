# Formulário Emater-RO

Sistema de coleta de dados para extensionistas da Emater-RO.

## 🚀 Stack Tecnológica

- **Frontend**: HTML5 + CSS3 + JavaScript Vanilla
- **Hospedagem**: Netlify
- **Backend**: Azure Functions (Node.js)
- **Banco de Dados**: Azure SQL Database
- **Controle de Versão**: Git + GitHub

## 📦 Estrutura do Projeto

```
formema/
├── index.html          # Formulário principal
├── api/                # Azure Functions
│   ├── SaveResponse/
│   │   ├── function.json
│   │   └── index.js
│   └── package.json
├── database/
│   └── schema.sql      # Script de criação do banco
├── netlify.toml        # Configuração Netlify
└── README.md
```

## 🔧 Setup Local

### 1. Clonar repositório
```bash
git clone https://github.com/SEU-USUARIO/formema.git
cd formema
```

### 2. Instalar dependências da API
```bash
cd api
npm install
```

### 3. Configurar variáveis de ambiente
Crie arquivo `api/local.settings.json`:
```json
{
  "IsEncrypted": false,
  "Values": {
    "AzureWebJobsStorage": "",
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "SQL_USER": "seu_usuario",
    "SQL_PASSWORD": "sua_senha",
    "SQL_SERVER": "seu-server.database.windows.net",
    "SQL_DATABASE": "formema"
  }
}
```

### 4. Executar localmente
```bash
# Terminal 1 - API
cd api
npm start

# Terminal 2 - Frontend (servidor local)
python -m http.server 8000
# ou
npx serve .
```

Acesse: http://localhost:8000

## ☁️ Deploy na Azure

### 1. Criar Azure SQL Database

```bash
# Via Azure CLI
az sql server create \
  --name formema-server \
  --resource-group formema-rg \
  --location brazilsouth \
  --admin-user adminuser \
  --admin-password SuaSenhaForte123!

az sql db create \
  --resource-group formema-rg \
  --server formema-server \
  --name formema \
  --service-objective S0
```

### 2. Executar script SQL
- Conecte no Azure SQL via Azure Data Studio ou SSMS
- Execute `database/schema.sql`

### 3. Criar Azure Function App

```bash
az functionapp create \
  --resource-group formema-rg \
  --consumption-plan-location brazilsouth \
  --runtime node \
  --runtime-version 18 \
  --functions-version 4 \
  --name formema-api \
  --storage-account formemast
```

### 4. Configurar variáveis de ambiente

```bash
az functionapp config appsettings set \
  --name formema-api \
  --resource-group formema-rg \
  --settings \
    SQL_USER=adminuser \
    SQL_PASSWORD=SuaSenhaForte123! \
    SQL_SERVER=formema-server.database.windows.net \
    SQL_DATABASE=formema
```

### 5. Deploy da Function

```bash
cd api
func azure functionapp publish formema-api
```

## 🌐 Deploy no Netlify

### Opção 1: Via Interface Web
1. Acesse https://netlify.com
2. "New site from Git"
3. Conecte seu GitHub
4. Selecione repositório `formema`
5. Deploy!

### Opção 2: Via CLI
```bash
npm install -g netlify-cli
netlify login
netlify init
netlify deploy --prod
```

### Configurar URL da API
Após deploy da Azure Function, atualize em `index.html`:
```javascript
const API_URL = 'https://formema-api.azurewebsites.net/api/save-response';
```

Commit e push:
```bash
git add index.html
git commit -m "Update API URL"
git push
```

## 🔐 Segurança

- API usa autenticação anonymous (adicionar auth se necessário)
- SQL usa conexão criptografada (TLS 1.2+)
- CORS configurado para domínio específico
- Dados sensíveis em variáveis de ambiente

## 📊 Consultas Úteis

### Total de respostas por município
```sql
SELECT * FROM vw_RespostasPorMunicipio
ORDER BY total_respostas DESC;
```

### Média de dificuldades
```sql
SELECT * FROM vw_DificuldadesMedia
ORDER BY media DESC;
```

### Exportar dados
```sql
EXEC sp_BackupRespostas 
  @dataInicio = '2025-01-01', 
  @dataFim = '2025-12-31';
```

## 🐛 Troubleshooting

### Erro de CORS
Verifique headers em `api/SaveResponse/index.js`:
```javascript
'Access-Control-Allow-Origin': 'https://seu-dominio.netlify.app'
```

### Erro de conexão SQL
Verifique firewall do Azure SQL:
```bash
az sql server firewall-rule create \
  --resource-group formema-rg \
  --server formema-server \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

## 📝 Licença

Uso interno da Emater-RO.

## 👥 Contato

Equipe de TI - Emater-RO
