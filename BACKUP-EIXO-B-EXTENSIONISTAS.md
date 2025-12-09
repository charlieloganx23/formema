# 📦 BACKUP - EIXO B ORIGINAL (Extensionistas)

**Data do Backup:** 09/12/2025  
**Arquivo:** extensionistas.html  
**Seção:** ETAPA 3 - EIXO B  
**Motivo:** Backup antes de reestruturação para nova versão focada em critérios de priorização e equidade

---

## 🎯 Estrutura Original

### **Título do Eixo:**
**Eixo B – Planejamento, Critérios de Atendimento e Gestão de Recursos**

### **Perguntas:**

#### **QUESTÃO 4:** Critérios de priorização
- **Tipo:** Checkbox (marcar todos que se aplicam)
- **Campo HTML:** `criteriosPriorizacao` (checkbox array)
- **Campo HTML adicional:** `criteriosPriorizacaoOutro` (text)

**Opções:**
- Critérios técnicos (produtividade, vulnerabilidade)
- Diretrizes da sede
- Requisição municipal/convênio
- Demanda espontânea dos produtores
- Critério de impacto econômico (potencial de mercado)
- Indicadores sociais (mulheres, jovens)
- Outro (campo aberto)

---

#### **QUESTÃO 5:** Documento formal
- **Tipo:** Likert Scale (1-5)
- **Campo HTML:** `documentoFormalCriterios`
- **Pergunta:** "Existe documento formal que explicite esses critérios?"

**Escala:**
- 1 = Muito baixa
- 2 = Baixa
- 3 = Média
- 4 = Alta
- 5 = Muito alta

---

#### **QUESTÃO 6:** Instrumentos formais de priorização
- **Tipo:** Radio button
- **Campo HTML:** `instrumentosPriorizacao`

**Opções:**
- Sim
- Parcialmente
- Não

**SUBQUESTÃO:** Exemplo de instrumento
- **Campo HTML:** `exemploInstrumento` (textarea)
- **Condicional:** Caso "Sim"

---

#### **Campo de comentário:**
- **Campo HTML:** `comentarioB` (textarea)
- **Pergunta:** "Gostaria de registrar algum comentário ou descrição sobre sua experiência relacionada a esse bloco?"

---

## 📊 Campos SQL Relacionados (schema original)

Todos os campos acima devem estar mapeados no `respostas` JSON do banco de dados `formulario_extensionista`.

### Estrutura JSON esperada:

```json
{
  "criteriosPriorizacao": ["criterios_tecnicos", "demanda_espontanea", "indicadores_sociais"],
  "criteriosPriorizacaoOutro": "Texto opcional",
  "documentoFormalCriterios": "3",
  "instrumentosPriorizacao": "parcialmente",
  "exemploInstrumento": "Descrição do instrumento usado",
  "comentarioB": "Comentários opcionais sobre o bloco"
}
```

---

## 🔄 Uso Futuro

**Manter para referência ou possível reutilização.**

---

## 📝 Observações

- **Tempo estimado:** 6 minutos
- **Validações:** Implementadas via JavaScript no formulário
- **Responsivo:** Layout otimizado para mobile
- **Formato:** Consistente com outros eixos

---

## 🗂️ Arquivos Relacionados

- `extensionistas.html` (linhas 1349-1480 aproximadamente)
- `db-extensionistas.js` (funções de salvamento IndexedDB)
- `netlify/functions/salvar-formulario.js` (backend)
- `netlify/functions/buscar-formularios.js` (backend)
- `azure/schema.sql` (estrutura do banco)

---

**✅ Backup concluído em 09/12/2025 antes da reestruturação do Eixo B**
