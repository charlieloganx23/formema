# 📦 BACKUP - EIXO A ORIGINAL (Extensionistas)

**Data do Backup:** 09/12/2025  
**Arquivo:** extensionistas.html  
**Seção:** ETAPA 2 - EIXO A  
**Motivo:** Backup antes de reestruturação para nova versão focada em métodos de ATER

---

## 🎯 Estrutura Original

### **Título do Eixo:**
**Eixo A – Visão dos Resultados e Desafios**

### **Perguntas:**

#### **QUESTÃO 1:** Resultados mais relevantes
- **Tipo:** Checkbox (marque até 5)
- **Campos HTML:**
  - `resultadosRelevantes` (checkbox array)
  - `resultadosRelevantesOutro` (text)

**Opções:**
- Aumento de produtividade dos beneficiários
- Aumento de comercialização/novos mercados
- Inclusão em programas públicos (PAA/PNAE/PRONAF)
- Implementação de tecnologias/boas práticas
- Fortalecimento de organizações coletivas (cooperativas)
- Capacitação/treinamento de produtores
- Redução de perdas pós-colheita
- Outro (campo aberto)

**SUBQUESTÃO 1:** Nível de impacto de cada resultado
- **Tipo:** Likert Scale (1-5)
- **Campos HTML:**
  - `impacto_aumento_produtividade`
  - `impacto_aumento_comercializacao`
  - `impacto_inclusao_programas`
  - `impacto_implementacao_tecnologias`
  - `impacto_fortalecimento_organizacoes`
  - `impacto_capacitacao_produtores`
  - `impacto_reducao_perdas`

---

#### **QUESTÃO 2:** Avalie o impacto dos desafios
- **Tipo:** Likert Scale (1-5)
- **Campos HTML:**
  - `desafio_fatores_externos`
  - `desafio_falta_pessoal`
  - `desafio_falta_veiculos`
  - `desafio_falta_orcamento`
  - `desafio_baixa_organizacao`
  - `desafio_falta_dados`
  - `desafio_resistencia_produtores`
  - `desafio_burocracia`

**Opções:**
- a) Fatores externos ou não controláveis
- b) Falta de pessoal técnico
- c) Falta de veículos/recursos logísticos
- d) Falta de orçamento para insumos/atividades
- e) Baixa organização coletiva dos produtores
- f) Falta de dados ou sistema atualizado (Sigater)
- g) Resistência dos produtores a novas técnicas
- h) Burocracia interna

---

#### **QUESTÃO 3:** Estratégias utilizadas
- **Tipo:** Checkbox (marcar todas que se aplicam)
- **Campos HTML:**
  - `estrategias` (checkbox array)
  - `estrategiasOutro` (text)

**Opções:**
- Realocação de técnicos entre municípios
- Parcerias com prefeituras/ONGs
- Oficinas e capacitações locais
- Uso de ferramentas digitais (WhatsApp, apps)
- Mobilização de recursos via convênios
- Outro (campo aberto)

**SUBQUESTÃO 3:** Estratégia mais efetiva
- **Tipo:** Radio button
- **Campo HTML:** `estrategiaMaisEfetiva`

**Opções:**
- Realocação de técnicos entre municípios
- Parcerias com prefeituras/ONGs
- Oficinas e capacitações locais
- Uso de ferramentas digitais (WhatsApp, apps)
- Mobilização de recursos via convênios
- Outro

---

## 📊 Campos SQL Relacionados (schema original)

Todos os campos acima devem estar mapeados no `respostas` JSON do banco de dados `formulario_extensionista`.

### Estrutura JSON esperada:

```json
{
  "resultadosRelevantes": ["aumento_produtividade", "inclusao_programas"],
  "resultadosRelevantesOutro": "Texto opcional",
  "impacto_aumento_produtividade": "4",
  "impacto_aumento_comercializacao": "3",
  "impacto_inclusao_programas": "5",
  "impacto_implementacao_tecnologias": "4",
  "impacto_fortalecimento_organizacoes": "3",
  "impacto_capacitacao_produtores": "5",
  "impacto_reducao_perdas": "2",
  "desafio_fatores_externos": "4",
  "desafio_falta_pessoal": "5",
  "desafio_falta_veiculos": "4",
  "desafio_falta_orcamento": "5",
  "desafio_baixa_organizacao": "3",
  "desafio_falta_dados": "4",
  "desafio_resistencia_produtores": "2",
  "desafio_burocracia": "5",
  "estrategias": ["parcerias", "ferramentas_digitais"],
  "estrategiasOutro": "Texto opcional",
  "estrategiaMaisEfetiva": "ferramentas_digitais"
}
```

---

## 🔄 Uso Futuro

**Este Eixo A será reutilizado no formulário de GERENTES.**

Quando implementar o formulário de gerentes com esta estrutura:
1. Copiar todo o HTML deste backup
2. Ajustar os IDs/nomes de campos se necessário
3. Garantir que o backend (`salvar-gerentes.js`) mapeia corretamente
4. Validar sincronização com `db-gerentes.js`

---

## 📝 Observações

- **Max checkboxes Q1:** 5 opções
- **Likert scales:** Todos 1-5
- **Tempo estimado:** 8 minutos
- **Validações:** Implementadas via JavaScript no formulário
- **Responsivo:** Layout otimizado para mobile

---

## 🗂️ Arquivos Relacionados

- `extensionistas.html` (linhas 1052-1610)
- `db-extensionistas.js` (funções de salvamento IndexedDB)
- `netlify/functions/salvar-formulario.js` (backend)
- `netlify/functions/buscar-formularios.js` (backend)
- `azure/schema.sql` (estrutura do banco)

---

**✅ Backup concluído em 09/12/2025 antes da reestruturação do Eixo A**
