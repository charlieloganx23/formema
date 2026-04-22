# Relatório de Atividades — Portal Central EMATECH
**Data:** 22 de abril de 2026  
**Responsável técnico:** SGCE/CECEX-9 — Tribunal de Contas do Estado de Rondônia  
**Projeto:** Ecossistema EMATECH — Auditoria Operacional ATER/EMATER-RO  

---

## 1. Objetivo da Atividade

Criação de um **Portal Central** para o ecossistema EMATECH, reunindo em um único endereço web todos os sistemas digitais utilizados na Auditoria Operacional da EMATER-RO, permitindo que gestores e equipe de auditoria acessem qualquer plataforma de forma unificada e organizada.

---

## 2. Contexto

O ecossistema EMATECH era composto por cinco sistemas independentes, cada um com URL própria, sem ponto de entrada centralizado. Isso dificultava a navegação da equipe gestora, que precisava memorizar ou consultar links separados para cada sistema. A solução adotada foi a criação de um portal de acesso único.

---

## 3. Sistemas Integrados ao Portal

| # | Sistema | URL | Perfil |
|---|---|---|---|
| 1 | **Sistema Principal EMATECH** | https://ematech.up.railway.app/login.html | Painel gerencial, relatórios, administração |
| 2 | **Formulário Extensionistas/Gerentes** | https://formextensionista.netlify.app/menu.html | Técnicos de campo e gerentes locais |
| 3 | **Formulário Coordenadores** | https://coordform.netlify.app/login-ater.html | Coordenadores regionais ATER |
| 4 | **Fluxo da Auditoria (Infográfico)** | https://infograficoemater.netlify.app/infografico_auditoria.html | Metodologia e processo de auditoria |
| 5 | **Insights EMATER-RO** | https://ematerinsights.netlify.app | Análise cruzada, dashboard e indicadores |

---

## 4. Atividades Realizadas

### 4.1 Criação da Branch de Desenvolvimento
- Criada branch `feature/portal` a partir da `main` atualizada
- Branch publicada no repositório remoto: `github.com/charlieloganx23/formema`
- Estratégia de isolamento adotada: alterações na `feature/portal` não afetam o sistema `formextensionista.netlify.app` (branch `main`)

### 4.2 Desenvolvimento do Portal (`portal.html`)
- Criado arquivo `portal.html` com layout responsivo e identidade visual verde EMATECH
- Implementados 5 cards de acesso, cada um com cor temática, tags de perfil e indicador de status
- Card do Sistema Principal destacado em posição de destaque (card largo/full-width)
- Todos os links abrem em nova aba (`target="_blank"`) com atributo de segurança `rel="noopener noreferrer"`
- Design adaptativo para desktop, tablet e mobile

**Paleta de cores por sistema:**
| Sistema | Cor |
|---|---|
| Sistema Principal EMATECH | Roxo |
| Formulário Extensionistas | Verde |
| Formulário Coordenadores | Laranja |
| Fluxo da Auditoria | Azul |
| Insights EMATER-RO | Âmbar/Dourado |

### 4.3 Publicação no Netlify
- Novo site criado no Netlify vinculado ao repositório `formema`, branch `feature/portal`
- Site nomeado: **`portalematech.netlify.app`**
- Configurações de build: sem build command (HTML estático puro)
- Deploy automático ativo a cada push na branch `feature/portal`

### 4.4 Correção de Redirect (2 iterações)
**Problema identificado:** O Netlify servia o `index.html` existente no repositório (que redirecionava para `menu.html` via JavaScript) ao invés do `portal.html`.

**Causa raiz:** O `index.html` é servido por padrão pelo Netlify quando existe no diretório raiz, e a regra de redirect no `netlify.toml` sem `force = true` não sobrepõe arquivos estáticos existentes.

**Solução aplicada:** Adicionadas duas regras no `netlify.toml` com `force = true`:
```toml
[[redirects]]
  from = "/"
  to = "/portal.html"
  status = 302
  force = true

[[redirects]]
  from = "/index.html"
  to = "/portal.html"
  status = 302
  force = true
```

### 4.5 Adição do Card de Insights (requisito adicional)
- Card **Insights EMATER-RO** adicionado após validação inicial do portal
- Link: `https://ematerinsights.netlify.app`
- Nova cor temática âmbar/dourado criada no CSS para diferenciar dos demais sistemas
- Sistema inclui dashboard de análise cruzada com indicadores de monitoramento, efetividade, comercialização e recomendações estratégicas

---

## 5. Commits Realizados

| Hash | Descrição |
|---|---|
| `062ac0d` | feat: cria portal central do ecossistema EMATECH |
| `1751c4b` | fix: redireciona raiz para portal.html no Netlify |
| `23a611c` | fix: force redirect para portal.html, sobrepondo index.html |
| `a4da2b7` | feat: adiciona card Insights EMATER-RO ao portal |

---

## 6. Resultado Final

Portal publicado e operacional em:

> **https://portalematech.netlify.app**

- Acesso aos 5 sistemas via cards visuais em página única
- Layout responsivo testado em desktop e mobile
- Deploy contínuo configurado (push → deploy automático)
- Branch `main` (sistema de formulários) **não foi afetada** pelas alterações

---

## 7. Pendências e Próximos Passos

| Item | Prioridade | Descrição |
|---|---|---|
| Merge para `main` | Baixa | Quando o portal estiver validado em produção, fazer merge de `feature/portal` → `main` |
| Renomear URL | Opcional | Alterar para `portal-ematech.netlify.app` em Site settings do Netlify |
| Domínio customizado | Futuro | Vincular domínio institucional TCE-RO ao portal |

---

*Relatório gerado em 22/04/2026 — SGCE/CECEX-9 — TCE-RO*
