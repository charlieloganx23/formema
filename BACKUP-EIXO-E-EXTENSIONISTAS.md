# Backup do Eixo E - Formulário Extensionistas
## EIXO E – Monitoramento e Avaliação de Resultados

**Data do Backup:** 2025-12-09  
**Propósito:** Documentação da estrutura original do Eixo E antes de reestruturação

---

## Estrutura Original (6 questões)

### Questão 21: Indicadores usados para avaliar desempenho
**Tipo:** Checkbox (múltipla escolha)  
**Campo:** `indicadoresDesempenho`

**Pergunta:** "Quais indicadores são usados rotineiramente para avaliar o desempenho da unidade?"

**Opções:**
- `visitas_tecnicas` - Nº de visitas técnicas/ano
- `produtores_atendidos` - Nº de produtores atendidos
- `capacitacoes` - Nº de capacitações
- `vendas_assistidas` - Volume/Valor de vendas assistidas
- `praticas_sustentaveis` - Adoção de práticas sustentáveis
- `outro` - Outro (campo livre)

**Campo adicional:**
- `indicadoresDesempenhoOutro` (NVARCHAR 500)

---

### Questão 22: Formalização em relatórios
**Tipo:** Radio (escolha única)  
**Campo:** `indicadoresFormalizados`

**Pergunta:** "Esses indicadores estão formalizados em relatórios periódicos?"

**Opções:**
- `sim` - Sim
- `parcialmente` - Parcialmente
- `nao` - Não

---

### Questão 23: Indicadores de efetividade
**Tipo:** Radio (escolha única)  
**Campo:** `indicadoresEfetividade`

**Pergunta:** "São utilizados indicadores de efetividade, ou seja, consegue verificar o impacto do trabalho da Emater na vida do pequeno produtor?"

**Opções:**
- `sim` - Sim
- `parcialmente` - Parcialmente
- `nao` - Não

**Campo adicional:**
- `indicadoresEfetividadeQuais` (NVARCHAR MAX) - Quais indicadores são utilizados (opcional)

---

### Questão 24: Frequência de influência nas decisões
**Tipo:** Radio (escolha única)  
**Campo:** `frequenciaInfluencia`

**Pergunta:** "Com que frequência os indicadores ou relatórios influenciam decisões de replanejamento das ações locais?"

**Opções:**
- `sempre` - Sempre
- `frequentemente` - Frequentemente
- `as_vezes` - Às vezes
- `raramente` - Raramente
- ~~`as_vezes` - Às vezes~~ (duplicado no código original)

**Observação:** Há um bug no HTML original - "Às vezes" aparece duplicado

---

### Questão 25: Capacidade de acompanhamento
**Tipo:** Likert Scale (1-5)  
**Campo:** `capacidadeAcompanhamento`

**Pergunta:** "Avalie a capacidade da Emater-RO de acompanhamento de impactos gerados junto aos pequenos agricultores:"

**Escala:**
- 1 = Muito fraca
- 2 = Fraca
- 3 = Regular
- 4 = Robusta
- 5 = Muito robusta

---

### Questão 26: Limitações para acompanhamento
**Tipo:** Textarea (texto livre)  
**Campo:** `limitacoesAcompanhamento`

**Pergunta:** "Quais as principais limitações para acompanhar os impactos gerados?"

---

### Campo Final: Comentário adicional
**Campo:** `comentarioFinal`  
**Tipo:** Textarea  
**Descrição:** "Gostaria de registrar algum comentário adicional sobre sua experiência como extensionista da Emater?"

---

## Mapeamento de Campos no Banco de Dados

### Campos Principais (Azure SQL)
```sql
-- Indicadores de desempenho (JSON array)
indicadoresDesempenho NVARCHAR(MAX) NULL

-- Indicadores de desempenho - outro
indicadoresDesempenhoOutro NVARCHAR(500) NULL

-- Indicadores formalizados
indicadoresFormalizados NVARCHAR(20) NULL

-- Indicadores de efetividade
indicadoresEfetividade NVARCHAR(20) NULL

-- Quais indicadores de efetividade
indicadoresEfetividadeQuais NVARCHAR(MAX) NULL

-- Frequência de influência
frequenciaInfluencia NVARCHAR(20) NULL

-- Capacidade de acompanhamento (Likert 1-5)
capacidadeAcompanhamento INT NULL
CHECK (capacidadeAcompanhamento BETWEEN 1 AND 5)

-- Limitações para acompanhamento
limitacoesAcompanhamento NVARCHAR(MAX) NULL

-- Comentário final
comentarioFinal NVARCHAR(MAX) NULL
```

### Exemplo de Dados JSON (IndexedDB)
```json
{
  "indicadoresDesempenho": ["visitas_tecnicas", "produtores_atendidos", "capacitacoes"],
  "indicadoresDesempenhoOutro": null,
  "indicadoresFormalizados": "parcialmente",
  "indicadoresEfetividade": "sim",
  "indicadoresEfetividadeQuais": "Aumento de renda, melhoria na produtividade, acesso a mercados",
  "frequenciaInfluencia": "frequentemente",
  "capacidadeAcompanhamento": 3,
  "limitacoesAcompanhamento": "Falta de pessoal, dificuldade de deslocamento, ausência de sistemas integrados",
  "comentarioFinal": "A ATER tem grande potencial mas precisa de mais recursos..."
}
```

---

## Integração com Backend

### Extração de Campos (formato estruturado)
```javascript
// Em salvar-formulario.js
let indicadoresDesempenho = respostas.indicadoresDesempenho ? JSON.stringify(respostas.indicadoresDesempenho) : null;
let indicadoresDesempenhoOutro = respostas.indicadoresDesempenhoOutro || null;
let indicadoresFormalizados = respostas.indicadoresFormalizados || null;
let indicadoresEfetividade = respostas.indicadoresEfetividade || null;
let indicadoresEfetividadeQuais = respostas.indicadoresEfetividadeQuais || null;
let frequenciaInfluencia = respostas.frequenciaInfluencia || null;
let capacidadeAcompanhamento = respostas.capacidadeAcompanhamento ? parseInt(respostas.capacidadeAcompanhamento) : null;
let limitacoesAcompanhamento = respostas.limitacoesAcompanhamento || null;
let comentarioFinal = respostas.comentarioFinal || null;
```

---

## Bugs Encontrados

### ⚠️ Bug 1: Duplicação de opção na Q24
```html
<!-- LINHA DUPLICADA -->
<label class="radio-label"><input type="radio" name="frequenciaInfluencia" value="as_vezes"> <span>Às vezes</span></label>
```
**Impacto:** Pode causar confusão visual. Não afeta funcionalidade pois mesmo `value`.

### ⚠️ Bug 2: Caractere especial mal codificado
```html
<span>Ã€s vezes</span>  <!-- Deveria ser "Às vezes" -->
```
**Impacto:** Exibição incorreta do texto.

---

## Análises Possíveis

### Uso de indicadores por tipo
```sql
SELECT 
    VALUE AS indicador,
    COUNT(*) AS frequencia
FROM formulario_extensionista
CROSS APPLY OPENJSON(indicadoresDesempenho)
WHERE status = 'completo'
GROUP BY VALUE
ORDER BY frequencia DESC;
```

### Correlação entre formalização e influência
```sql
SELECT 
    indicadoresFormalizados,
    frequenciaInfluencia,
    COUNT(*) AS total,
    AVG(CAST(capacidadeAcompanhamento AS FLOAT)) AS media_capacidade
FROM formulario_extensionista
WHERE status = 'completo'
GROUP BY indicadoresFormalizados, frequenciaInfluencia;
```

---

## Tempo Estimado
**6 minutos** para preenchimento completo do Eixo E

---

## Status
✅ Estrutura atual documentada  
⚠️ Bugs identificados (duplicação + encoding)  
⏳ Aguardando reestruturação para 3 questões (16, 17, 18)

---

## Nova Estrutura Solicitada (simplificação)

### Redução de 6 → 3 questões

**Q16:** Instrumentos para acompanhar resultados (checkbox)
- Sigater, Relatórios internos, Planilhas próprias, Nenhum, Outro

**Q17:** Frequência de uso de indicadores (Likert) + campo texto

**Q18:** Avaliação da ajuda dos indicadores (Likert 1-5)

**Mudanças principais:**
- Foco em instrumentos (não indicadores específicos)
- Consolidação de perguntas sobre uso/impacto
- Remoção de questões sobre formalização e efetividade
- Mais conciso e objetivo
