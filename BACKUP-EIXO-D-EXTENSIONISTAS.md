# Backup do Eixo D - Formulário Extensionistas
## EIXO D – Articulação Produtiva e Comercialização

**Data do Backup:** 2025-12-09  
**Propósito:** Documentação da estrutura original do Eixo D antes de reestruturação

---

## Estrutura Original

### Questão 10: Frequência de orientação com base na demanda de mercado
**Tipo:** Select dropdown  
**Campo:** `freqDemandaMercado`

**Opções:**
- `nunca` - Nunca
- `raramente` - Raramente
- `as_vezes` - Às vezes
- `frequentemente` - Frequentemente
- `sempre` - Sempre

---

### Questão 11: Participação em capacitações
**Tipo:** Radio (escolha única)  
**Campo:** `capacitacaoMercado`

**Pergunta:** "Participou de capacitações sobre mercado, cadeias de valor ou canais de comercialização nos últimos 2 anos?"

**Opções:**
- `sim` - Sim
- `nao` - Não

---

### Questão 12: Impacto das capacitações
**Tipo:** Likert Scale (1-5)  
**Campo:** `impactoCapacitacao`

**Pergunta:** "Avalie o quanto capacitações de mercado ajudam ou ajudariam sua orientação técnica."

**Escala:**
- 1 = Nada
- 2 = Pouco
- 3 = Regular
- 4 = Muito
- 5 = Extremamente

---

### Questão 13: Instrumentos para organização da produção
**Tipo:** Radio (escolha única)  
**Campo:** `instrumentosProducao`

**Pergunta:** "Existem instrumentos/rotinas para orientar organização da produção?"

**Opções:**
- `sim_frequentemente` - Sim, usamos frequentemente
- `sim_pouco` - Sim, mas pouco utilizados
- `nao_existem` - Não existem
- `nao_sei` - Não sei

**Campo adicional:**
- `exemploInstrumentosProducao` (NVARCHAR MAX) - Exemplo de instrumento (opcional)

---

### Questão 14: Apoio a mercados institucionais
**Tipo:** Select dropdown  
**Campo:** `freqApoioMercadosInstitucionais`

**Pergunta:** "Com que frequência você apoia agricultores no acesso a mercados institucionais (como PAA/PNAE)?"

**Opções:**
- `nunca` - Nunca
- `raramente` - Raramente
- `as_vezes` - Às vezes
- `frequentemente` - Frequentemente
- `sempre` - Sempre

---

### Questão 15: Conhecimento sobre oferta/demanda local
**Tipo:** Likert Scale (1-5)  
**Campo:** `conhecimentoOfertaDemanda`

**Pergunta:** "Seu conhecimento sobre oferta/demanda local é…"

**Escala:**
- 1 = Muito baixo
- 2 = Baixo
- 3 = Médio
- 4 = Alto
- 5 = Muito alto

---

### Campo Aberto: Comentários
**Campo:** `comentarioD`  
**Tipo:** Textarea  
**Descrição:** "Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?"

---

## Mapeamento de Campos no Banco de Dados

### Campos Principais (Azure SQL)
```sql
-- Frequência de orientação por demanda de mercado
freqDemandaMercado NVARCHAR(50) NULL

-- Participou de capacitação sobre mercado
capacitacaoMercado NVARCHAR(10) NULL

-- Impacto das capacitações (Likert 1-5)
impactoCapacitacao INT NULL
CHECK (impactoCapacitacao BETWEEN 1 AND 5)

-- Instrumentos para organização da produção
instrumentosProducao NVARCHAR(50) NULL

-- Exemplo de instrumentos
exemploInstrumentosProducao NVARCHAR(MAX) NULL

-- Frequência de apoio a mercados institucionais
freqApoioMercadosInstitucionais NVARCHAR(50) NULL

-- Conhecimento sobre oferta/demanda (Likert 1-5)
conhecimentoOfertaDemanda INT NULL
CHECK (conhecimentoOfertaDemanda BETWEEN 1 AND 5)

-- Comentários do Eixo D
comentarioD NVARCHAR(MAX) NULL
```

### Exemplo de Dados JSON (IndexedDB)
```json
{
  "freqDemandaMercado": "frequentemente",
  "capacitacaoMercado": "sim",
  "impactoCapacitacao": 4,
  "instrumentosProducao": "sim_frequentemente",
  "exemploInstrumentosProducao": "Usamos planilhas de planejamento de safra e calendário de comercialização",
  "freqApoioMercadosInstitucionais": "sempre",
  "conhecimentoOfertaDemanda": 4,
  "comentarioD": "O acesso ao PAA/PNAE tem sido fundamental para os produtores locais..."
}
```

---

## Integração com Backend

### Extração de Campos (formato estruturado)
```javascript
// Em salvar-formulario.js
let freqDemandaMercado = respostas.freqDemandaMercado || null;
let capacitacaoMercado = respostas.capacitacaoMercado || null;
let impactoCapacitacao = respostas.impactoCapacitacao ? parseInt(respostas.impactoCapacitacao) : null;
let instrumentosProducao = respostas.instrumentosProducao || null;
let exemploInstrumentosProducao = respostas.exemploInstrumentosProducao || null;
let freqApoioMercadosInstitucionais = respostas.freqApoioMercadosInstitucionais || null;
let conhecimentoOfertaDemanda = respostas.conhecimentoOfertaDemanda ? parseInt(respostas.conhecimentoOfertaDemanda) : null;
let comentarioD = respostas.comentarioD || null;
```

---

## Características Especiais

### Select Dropdowns
- Questões 10 e 14 usam `<select>` com opções de frequência
- Fornecem interface limpa para escalas ordinais

### Campos Condicionais
- `exemploInstrumentosProducao` só é relevante se resposta for "Sim" na questão 13

---

## Análises Possíveis

### Orientação por mercado vs apoio a PAA/PNAE
```sql
SELECT 
    freqDemandaMercado,
    freqApoioMercadosInstitucionais,
    COUNT(*) AS total
FROM formulario_extensionista
WHERE status = 'completo'
GROUP BY freqDemandaMercado, freqApoioMercadosInstitucionais;
```

### Impacto de capacitações
```sql
SELECT 
    capacitacaoMercado,
    AVG(CAST(impactoCapacitacao AS FLOAT)) AS media_impacto,
    AVG(CAST(conhecimentoOfertaDemanda AS FLOAT)) AS media_conhecimento
FROM formulario_extensionista
WHERE status = 'completo'
GROUP BY capacitacaoMercado;
```

---

## Status
✅ Estrutura validada e funcionando  
✅ Backup criado em: 2025-12-09  
⏳ Aguardando reestruturação conforme novos requisitos
