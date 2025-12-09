# 🌳 Guia de Branches - Projeto EMATER-RO

## 📊 Estrutura de Branches

```
main (produção)
  ↓
develop (homologação)
  ↓
feature/formulario-gerentes (desenvolvimento)
```

---

## 🎯 Descrição das Branches

### 🟢 **main** - Produção
- **Propósito:** Código estável em produção
- **URL:** https://formextensionista.netlify.app
- **Deploy:** Automático via Netlify
- **Proteção:** ❌ Nunca commitar diretamente
- **Merge:** Apenas via Pull Request do `develop`

### 🟡 **develop** - Homologação
- **Propósito:** Integração e testes antes da produção
- **URL:** https://develop--formextensionista.netlify.app
- **Deploy:** Automático via Netlify
- **Merge:** Features testadas e aprovadas
- **Testes:** Validação completa antes de produção

### 🟣 **feature/formulario-gerentes** - Desenvolvimento
- **Propósito:** Nova funcionalidade (formulário gerentes)
- **URL:** Deploy preview automático do Netlify
- **Commits:** Frequentes e descritivos
- **Merge:** Para `develop` quando funcionalidade estiver pronta

---

## 🚀 Fluxo de Trabalho

### 1️⃣ **Desenvolvimento (Você está aqui)**

```bash
# Verificar branch atual
git branch

# Desenvolver nova funcionalidade
# ... fazer alterações ...

# Commitar mudanças
git add .
git commit -m "feat: adicionar menu inicial de seleção"
git push origin feature/formulario-gerentes
```

### 2️⃣ **Testes em Homologação**

```bash
# Ir para develop
git checkout develop

# Atualizar develop com main (se necessário)
git pull origin main

# Mesclar feature
git merge feature/formulario-gerentes

# Resolver conflitos (se houver)
# ... resolver ...

# Push para homologação
git push origin develop

# Netlify vai deployar automaticamente
# Testar em: https://develop--formextensionista.netlify.app
```

### 3️⃣ **Deploy em Produção**

```bash
# Opção A: Via GitHub (Recomendado)
# 1. Ir para GitHub
# 2. Criar Pull Request: develop → main
# 3. Revisar código
# 4. Aprovar e fazer merge
# 5. Netlify faz deploy automático

# Opção B: Via terminal (Cuidado!)
git checkout main
git merge develop
git push origin main
```

---

## 📋 Comandos Úteis

### Ver todas as branches
```bash
git branch -a
```

### Trocar de branch
```bash
git checkout <nome-da-branch>
```

### Criar nova feature
```bash
git checkout develop
git checkout -b feature/nome-da-feature
git push -u origin feature/nome-da-feature
```

### Atualizar branch com mudanças de outra
```bash
git checkout feature/minha-feature
git merge develop
```

### Deletar branch local (após merge)
```bash
git branch -d feature/nome-da-feature
```

### Deletar branch remota (após merge)
```bash
git push origin --delete feature/nome-da-feature
```

---

## 🔒 Regras de Proteção (Configurar no GitHub)

### Branch `main`:
- ✅ Require pull request reviews (1 aprovação)
- ✅ Require status checks to pass
- ✅ Require branches to be up to date
- ❌ Allow force pushes
- ❌ Allow deletions

### Branch `develop`:
- ✅ Require pull request reviews (opcional)
- ✅ Allow force pushes (com cuidado)
- ✅ Allow deletions (features antigas)

---

## 🎨 Convenção de Commits

```bash
# Novas funcionalidades
git commit -m "feat: adicionar menu de seleção de formulários"

# Correções de bugs
git commit -m "fix: corrigir sincronização de dados gerentes"

# Documentação
git commit -m "docs: atualizar guia de branches"

# Refatoração
git commit -m "refactor: separar lógica de formulários em módulos"

# Testes
git commit -m "test: adicionar testes para formulário gerentes"

# Estilo/formatação
git commit -m "style: ajustar espaçamento no menu inicial"

# Performance
git commit -m "perf: otimizar carregamento de dados"
```

---

## 📊 URLs de Deploy

| Branch | URL | Propósito |
|--------|-----|-----------|
| `main` | https://formextensionista.netlify.app | 🟢 Produção |
| `develop` | https://develop--formextensionista.netlify.app | 🟡 Homologação |
| `feature/*` | Deploy preview automático | 🟣 Testes de feature |

---

## ⚠️ Boas Práticas

### ✅ FAZER:
- Commitar frequentemente
- Usar mensagens descritivas
- Testar em `develop` antes de `main`
- Criar Pull Requests para revisão
- Manter branches atualizadas

### ❌ NÃO FAZER:
- Commitar direto em `main`
- Force push em branches compartilhadas
- Deixar features incompletas em `develop`
- Misturar múltiplas features em um commit
- Ignorar conflitos de merge

---

## 🆘 Comandos de Emergência

### Desfazer último commit (não enviado)
```bash
git reset --soft HEAD~1
```

### Desfazer mudanças não commitadas
```bash
git checkout -- <arquivo>
# ou para todos os arquivos:
git checkout -- .
```

### Voltar branch para estado anterior
```bash
git reset --hard origin/<nome-da-branch>
```

### Ver histórico de commits
```bash
git log --oneline --graph --all
```

---

## 📞 Suporte

- **GitHub:** https://github.com/charlieloganx23/formema
- **Netlify:** Dashboard → Deploys
- **Documentação Git:** https://git-scm.com/doc
