# 🔐 Instruções: Criar Tabela de Usuários no Azure SQL

## 📋 Passo a Passo

### Opção 1: Portal Azure (Mais Fácil)

1. **Acesse o Portal Azure**
   - Vá para: https://portal.azure.com
   - Navegue até: SQL databases → `db-ematech`

2. **Abra o Query Editor**
   - No menu lateral, clique em "Query editor (preview)"
   - Faça login com:
     - **Server**: srv-db-cxtce.database.windows.net
     - **Database**: db-ematech
     - **Username**: admin.dba
     - **Password**: A57458974x23*

3. **Execute o Script**
   - Copie todo o conteúdo do arquivo `criar-tabela-usuarios.sql`
   - Cole no editor de queries
   - Clique em "Run" (▶️)
   - Aguarde a mensagem de sucesso

### Opção 2: Azure Data Studio

1. **Abra o Azure Data Studio**
   - Se não tiver, baixe em: https://aka.ms/azuredatastudio

2. **Crie uma Nova Conexão**
   - Server: `srv-db-cxtce.database.windows.net`
   - Authentication type: SQL Login
   - User name: `admin.dba`
   - Password: `A57458974x23*`
   - Database: `db-ematech`
   - Encrypt: Mandatory (Yes)

3. **Execute o Script**
   - Abra o arquivo `criar-tabela-usuarios.sql`
   - Pressione F5 ou clique em "Run"
   - Verifique se aparece a mensagem de sucesso

### Opção 3: VS Code com extensão SQL

1. **Instale a extensão SQL Server (mssql)**
   - Pesquise por "SQL Server (mssql)" na Extensions

2. **Conecte ao Azure**
   - Pressione Ctrl+Shift+P
   - Digite "MS SQL: Connect"
   - Configure a conexão conforme Opção 2

3. **Execute o Script**
   - Abra `criar-tabela-usuarios.sql`
   - Pressione Ctrl+Shift+E
   - Selecione "Execute Query"

## ✅ Verificar se Funcionou

Execute esta consulta para verificar:

```sql
SELECT id, usuario, nome_completo, perfil, ativo
FROM usuarios_formema;
```

Deve retornar 3 usuários:
- **admin** (perfil: admin)
- **extensionista** (perfil: extensionista)
- **ger.teste** (perfil: gerente)

## 🔑 Credenciais de Teste

| Usuário | Senha | Perfil |
|---------|-------|--------|
| admin | admin123 | Administrador |
| extensionista | ext123 | Extensionista |
| ger.teste | senha123 | Gerente |

## ⚠️ Importante

- As senhas estão em **hash SHA-256** no banco
- O frontend faz o hash antes de enviar
- **NUNCA** armazene senhas em texto simples
- Altere as senhas de teste em produção!

## 🛠️ Criar Novos Usuários

Para criar um novo usuário, você precisa gerar o hash SHA-256 da senha.

### Gerar Hash (Node.js):

```javascript
const crypto = require('crypto');
const senha = 'sua_senha_aqui';
const hash = crypto.createHash('sha256').update(senha).digest('hex');
console.log(hash);
```

### Inserir Usuário:

```sql
INSERT INTO usuarios_formema (usuario, senha, nome_completo, email, perfil, municipio, escritorio_local)
VALUES (
    'nome.usuario',
    'HASH_SHA256_AQUI',
    'Nome Completo do Usuário',
    'email@emater.ro.gov.br',
    'extensionista',  -- ou 'gerente' ou 'admin'
    'Ministro Andreazza',  -- opcional
    'Escritório Local XYZ'  -- opcional
);
```

## 📊 Estrutura da Tabela

```
usuarios_formema
├── id (INT, PK, IDENTITY)
├── usuario (NVARCHAR, UNIQUE) ✅ Login
├── senha (NVARCHAR) ✅ Hash SHA-256
├── nome_completo (NVARCHAR)
├── email (NVARCHAR)
├── perfil (NVARCHAR) ✅ extensionista | gerente | admin
├── municipio (NVARCHAR) ← Pré-preenchimento
├── escritorio_local (NVARCHAR) ← Pré-preenchimento
├── ativo (BIT) ← 1=ativo, 0=inativo
├── data_criacao (DATETIME)
└── data_ultimo_acesso (DATETIME)
```

## 🔄 Próximos Passos

Após executar o SQL:

1. ✅ Acesse: https://formextensionista.netlify.app/menu.html
2. ✅ Clique em "Acessar Formulário Extensionistas"
3. ✅ Faça login com: `ext.teste` / `senha123`
4. ✅ Deve redirecionar para extensionistas.html

---

**🆘 Problemas?**
- Verifique se o firewall do Azure permite seu IP
- Confirme que as credenciais estão corretas
- Veja os logs no console do navegador (F12)
