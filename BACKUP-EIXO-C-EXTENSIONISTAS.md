# Backup do Eixo C - Formulário Extensionistas
## EIXO C – Parcerias e Atuação em Fóruns

**Data do Backup:** 2025-12-09  
**Propósito:** Documentação da estrutura original do Eixo C antes de potenciais modificações

---

## Estrutura Atual

### Questão 7: Parcerias Ativas
**Tipo:** Checkbox (múltipla escolha, máximo 3)  
**Campo:** `parceriasAtivas`

**Opções:**
- `idaron` - Idaron
- `embrapa` - Embrapa
- `prefeituras` - Prefeituras
- `sedam` - Sedam
- `secretarias_municipais` - Secretarias municipais
- `cooperativas_associacoes` - Cooperativas/associações
- `movimentos_sociais` - Movimentos sociais
- `instituicoes_financeiras` - Instituições financeiras
- `sistema_s` - Sistema S (Senar, Sebrae etc.)
- `sindicatos` - Sindicatos
- `outro` - Outro (campo livre)

**Campo adicional:**
- `parceriasAtivasOutro` (NVARCHAR 500) - Texto livre quando "outro" é selecionado

**Validação:** Máximo de 3 opções

---

### Questão 8: Participação em Fóruns
**Tipo:** Radio (escolha única)  
**Campo:** `participaForuns`

**Opções:**
- `sim_frequentemente` - Sim, frequentemente
- `sim_ocasionamente` - Sim, ocasionalmente
- `nao_participa` - Não participa

---

### Questão 9: Influência da Emater
**Tipo:** Likert Scale (1-5)  
**Campo:** `influenciaEmater`

**Escala:**
- 1 = Nenhuma
- 2 = Baixa
- 3 = Média
- 4 = Alta
- 5 = Muito alta

**Descrição:** "Avalie o grau de influência da Emater nesses espaços."

---

### Campo Aberto: Comentários
**Campo:** `comentarioC`  
**Tipo:** Textarea  
**Descrição:** "Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?"

---

## Mapeamento de Campos no Banco de Dados

### Campos Principais (Azure SQL)
```sql
-- Parcerias ativas (JSON array)
parceriasAtivas NVARCHAR(MAX) NULL

-- Parcerias ativas - outro
parceriasAtivasOutro NVARCHAR(500) NULL

-- Participação em fóruns
participaForuns NVARCHAR(50) NULL

-- Influência da Emater (Likert 1-5)
influenciaEmater INT NULL
CHECK (influenciaEmater BETWEEN 1 AND 5)

-- Comentários do Eixo C
comentarioC NVARCHAR(MAX) NULL
```

### Exemplo de Dados JSON (IndexedDB)
```json
{
  "parceriasAtivas": ["prefeituras", "cooperativas_associacoes", "sistema_s"],
  "parceriasAtivasOutro": null,
  "participaForuns": "sim_frequentemente",
  "influenciaEmater": 4,
  "comentarioC": "Participamos ativamente do Conselho Municipal de Desenvolvimento Rural..."
}
```

---

## Integração com Backend

### Extração de Campos (formato estruturado)
```javascript
// Em salvar-formulario.js
let parceriasAtivas = respostas.parceriasAtivas ? JSON.stringify(respostas.parceriasAtivas) : null;
let parceriasAtivasOutro = respostas.parceriasAtivasOutro || null;
let participaForuns = respostas.participaForuns || null;
let influenciaEmater = respostas.influenciaEmater ? parseInt(respostas.influenciaEmater) : null;
let comentarioC = respostas.comentarioC || null;
```

### Extração de Campos (formato flat - IndexedDB antigo)
```javascript
// Em salvar-formulario.js
let parceriasAtivas = formulario.parceriasAtivas ? JSON.stringify(formulario.parceriasAtivas) : null;
let parceriasAtivasOutro = formulario.parceriasAtivasOutro || null;
let participaForuns = formulario.participaForuns || null;
let influenciaEmater = formulario.influenciaEmater ? parseInt(formulario.influenciaEmater) : null;
let comentarioC = formulario.comentarioC || null;
```

---

## Características Especiais

### Validação de Checkbox (max-check)
```html
<div class="checkbox-group" data-max-check="3">
```
- JavaScript valida e permite no máximo 3 seleções
- Usuário recebe feedback visual ao atingir o limite

### Campo Condicional
- `parceriasAtivasOutro` só é relevante se "outro" for marcado em `parceriasAtivas`

---

## Análises Possíveis

### Parcerias mais comuns
```sql
SELECT 
    VALUE AS parceria,
    COUNT(*) AS frequencia
FROM formulario_extensionista
CROSS APPLY OPENJSON(parceriasAtivas)
GROUP BY VALUE
ORDER BY frequencia DESC;
```

### Nível de participação em fóruns
```sql
SELECT 
    participaForuns,
    COUNT(*) AS total,
    AVG(CAST(influenciaEmater AS FLOAT)) AS media_influencia
FROM formulario_extensionista
WHERE status = 'completo'
GROUP BY participaForuns;
```

### Influência média por município
```sql
SELECT 
    municipio,
    AVG(CAST(influenciaEmater AS FLOAT)) AS media_influencia,
    COUNT(*) AS total_respostas
FROM formulario_extensionista
WHERE influenciaEmater IS NOT NULL
GROUP BY municipio
ORDER BY media_influencia DESC;
```

---

## Notas Técnicas

1. **Limite de Seleção:** O atributo `data-max-check="3"` é processado por JavaScript para limitar escolhas
2. **Armazenamento JSON:** `parceriasAtivas` é armazenado como JSON array no banco
3. **Campo Outro:** Implementado como checkbox separado com input text condicional
4. **Likert Scale:** Valores numéricos 1-5 facilitam análises estatísticas

---

## Tempo Estimado
**5 minutos** para preenchimento completo do Eixo C

---

## Status
✅ Estrutura validada e funcionando  
✅ Backup criado em: 2025-12-09  
✅ Pronto para análise e possíveis modificações futuras
