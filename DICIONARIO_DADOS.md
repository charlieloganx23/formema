# Dicionário de Dados - Sistema Formema
**Sistema de Formulários de Avaliação EMATER-RO**

**Versão**: 1.0  
**Data**: 15/12/2025  
**Desenvolvido para**: Emater-RO - Escritório Local de Ministro Andreazza

---

## 📊 Visão Geral do Sistema

O sistema Formema é composto por dois formulários principais:
1. **Extensionistas** - Avaliação aplicada por técnicos de campo
2. **Gerentes Locais** - Avaliação aplicada para gestores de escritórios locais

### Tecnologias Utilizadas
- **Frontend**: HTML5, CSS3, JavaScript
- **Armazenamento Local**: IndexedDB
- **Backend**: Netlify Functions
- **Banco de Dados**: Azure SQL
- **Sincronização**: Híbrida (local + cloud)

---

## 🗄️ Estrutura de Bancos de Dados IndexedDB

### Banco: `EmatechExtensionistas`
- **Versão**: 1
- **Object Store**: `formularios`
- **Key Path**: `id` (auto-increment)

### Banco: `EmatechGerentes`
- **Versão**: 1
- **Object Store**: `formularios`
- **Key Path**: `id` (auto-increment)

### Índices Comuns
| Índice | Campo | Único |
|--------|-------|-------|
| protocolo | protocolo | Sim |
| municipio | municipio | Não |
| timestamp_fim | timestamp_fim | Não |
| sincronizado | sincronizado | Não |

---

## 📋 FORMULÁRIO EXTENSIONISTAS

### Metadados do Formulário

| Campo | Tipo | Descrição | Obrigatório | Geração |
|-------|------|-----------|-------------|---------|
| `id` | Integer | ID único local (auto-increment) | Sim | Auto |
| `protocolo` | String | Protocolo único (FORMATO: YYYYMMDDHHMMSS) | Sim | Auto |
| `timestamp_inicio` | DateTime | Data/hora início preenchimento | Sim | Auto |
| `timestamp_fim` | DateTime | Data/hora conclusão | Sim | Auto |
| `sincronizado` | Boolean | Status de sincronização com servidor | Sim | Auto (false) |
| `data_sincronizacao` | DateTime | Data/hora da última sincronização | Não | Auto |

---

### MÓDULO I - IDENTIFICAÇÃO

#### Dados do Técnico e Localização

| Campo | Nome Técnico | Tipo | Valores Possíveis | Obrigatório | Descrição |
|-------|--------------|------|-------------------|-------------|-----------|
| **Município** | `municipio` | Select | Lista de municípios RO | Sim | Município de atuação do extensionista |
| **Escritório Local** | `escritorioLocal` | Select | Escritórios do município | Sim | Escritório local da Emater-RO |
| **Tempo de Emater** | `tempoEmater` | Radio | menos5, 5a9, 10a14, 15a19, 20a24, 25a29, mais30 | Sim | Tempo de serviço na instituição |
| **Nome Completo** | `nomeCompleto` | Text | Texto livre | Não | Nome completo do extensionista (opcional) |

**Municípios Disponíveis**:
- Alta Floresta D'Oeste, Alto Alegre dos Parecis, Alto Paraíso, Alvorada D'Oeste, Ariquemes, Buritis, Cabixi, Cacaulândia, Cacoal, Campo Novo de Rondônia, Candeias do Jamari, Castanheiras, Cerejeiras, Chupinguaia, Colorado do Oeste, Corumbiara, Costa Marques, Cujubim, Espigão D'Oeste, Governador Jorge Teixeira, Guajará-Mirim, Itapuã do Oeste, Jaru, Ji-Paraná, Machadinho D'Oeste, **Ministro Andreazza**, Mirante da Serra, Monte Negro, Nova Brasilândia D'Oeste, Nova Mamoré, Nova União, Novo Horizonte do Oeste, Ouro Preto do Oeste, Parecis, Pimenta Bueno, Pimenteiras do Oeste, Porto Velho, Presidente Médici, Primavera de Rondônia, Rio Crespo, Rolim de Moura, Santa Luzia D'Oeste, São Felipe D'Oeste, São Francisco do Guaporé, São Miguel do Guaporé, Seringueiras, Teixeirópolis, Theobroma, Urupá, Vale do Anari, Vale do Paraíso, Vilhena

---

### EIXO A – MÉTODOS DE ATER E RESULTADOS PERCEBIDOS

#### A1. Métodos Mais Utilizados

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Métodos Frequentes** | `metodosFrequentes` | Checkbox (múltipla escolha) | visitas_tecnicas, dias_campo, demonstracao_metodo, capacitacoes_coletivas, whatsapp_digital, planejamento_produtivo, apoio_programas, outro |
| **Outro método** | `metodosFrequentesOutro` | Text | Texto livre (condicional) |

**Opções**:
- Visitas técnicas individuais
- Dias de campo
- Demonstração de Método
- Capacitações coletivas
- Grupos de WhatsApp/comunicação digital
- Planejamento produtivo
- Apoio para acessar programas (DAP/CAF/Pronaf etc.)
- Outro (especificar)

#### A2. Métodos com Melhores Resultados

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Melhores Resultados** | `metodosMelhoresResultados` | Checkbox (múltipla escolha) | visitas_tecnicas, dias_campo, demonstracao_metodo, capacitacoes_coletivas, whatsapp_digital, planejamento_produtivo, apoio_programas, outro |
| **Outro método** | `metodosMelhoresResultadosOutro` | Text | Texto livre (condicional) |

#### A3. Dificuldades Percebidas (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Falta de tempo** | `dificuldade_falta_tempo` | Radio | 1-5 | 1=Nenhuma dificuldade, 5=Muita dificuldade |
| **Número de técnicos** | `dificuldade_num_tecnicos` | Radio | 1-5 | Poucos técnicos para área coberta |
| **Distância/acesso** | `dificuldade_distancia` | Radio | 1-5 | Dificuldade de acesso às comunidades |
| **Baixa adesão** | `dificuldade_baixa_adesao` | Radio | 1-5 | Baixa adesão dos agricultores |
| **Falta de recursos** | `dificuldade_recursos` | Radio | 1-5 | Recursos materiais e financeiros |
| **Demandas administrativas** | `dificuldade_demandas_admin` | Radio | 1-5 | Excesso de tarefas burocráticas |
| **Pressão por metas** | `dificuldade_metas` | Radio | 1-5 | Pressão para atingir metas numéricas |

#### A4. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo A** | `comentario_eixo_a` | Textarea | Não |

---

### EIXO B – CRITÉRIOS DE PRIORIZAÇÃO E EQUIDADE

#### B1. Critérios de Priorização de Atendimentos

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Critérios** | `priorizacao_atendimentos` | Checkbox (múltipla escolha) | demanda_espontanea, criterios_tecnicos_emater, criterios_tecnicos_extensionista, politicas_publicas, vulnerabilidade_social, ordem_chegada, outro |
| **Outro critério** | `priorizacao_atendimentos_outro` | Text | Texto livre (condicional) |

**Opções**:
- Por demanda espontânea
- Por critérios técnicos definidos pela Emater
- Por critérios técnicos definidos pelo extensionista
- Por políticas públicas específicas (PAA/PNAE etc.)
- Por vulnerabilidade social (mulheres, jovens, comunidades afastadas)
- Por ordem de chegada
- Outro (especificar)

#### B2. Nível de Equidade Percebido (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Equidade no atendimento** | `nivel_equidade` | Radio | 1-5 | 1=Muito desigual, 5=Muito equitativo |

#### B3. Instrumentos Formais de Priorização

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Uso de instrumentos** | `instrumentos_formais` | Radio | sim_oficiais, sim_parcialmente, nao_existe, nao_sei |
| **Exemplo** | `exemplo_instrumento_formal` | Textarea | Texto livre (condicional) |

**Opções**:
- Sim, utilizamos instrumentos oficiais
- Sim, mas usamos apenas parcialmente
- Não existe instrumento
- Não sei

#### B4. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo B** | `comentario_eixo_b` | Textarea | Não |

---

### EIXO C – PARCERIAS E ATUAÇÃO EM FÓRUNS

#### C1. Parcerias Ativas

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Parcerias** | `parcerias_ativas` | Checkbox (múltipla escolha) | idaron, embrapa, prefeituras, sedam, secretarias_municipais, cooperativas_associacoes, movimentos_sociais, instituicoes_financeiras, sistema_s, sindicatos, outro |
| **Outra parceria** | `parcerias_ativas_outro` | Text | Texto livre (condicional) |

**Opções**:
- Idaron
- Embrapa
- Prefeituras
- Sedam
- Secretarias municipais
- Cooperativas/associações
- Movimentos sociais
- Instituições financeiras
- Sistema S (Senar, Sebrae etc.)
- Sindicatos
- Outro (especificar)

#### C2. Participação em Fóruns

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `participa_foruns` | Radio | sim_frequentemente, sim_ocasionamente, nao_participa |

**Opções**:
- Sim, frequentemente
- Sim, ocasionalmente
- Não participa

#### C3. Influência da Emater em Fóruns (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Nível de influência** | `influencia_emater` | Radio | 1-5 | 1=Nenhuma influência, 5=Muita influência |

#### C4. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo C** | `comentario_eixo_c` | Textarea | Não |

---

### EIXO D – ARTICULAÇÃO PRODUTIVA E COMERCIALIZAÇÃO

#### D1. Demandas de Mercado

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `freq_demanda_mercado` | Select | sempre, frequentemente, as_vezes, raramente, nunca |

**Opções**:
- Sempre
- Frequentemente
- Às vezes
- Raramente
- Nunca

#### D2. Capacitação em Acesso a Mercados

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Oferece capacitação** | `capacitacao_mercado` | Radio | sim, nao |

#### D3. Impacto da Capacitação (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Nível de impacto** | `impacto_capacitacao` | Radio | 1-5 | 1=Nenhum impacto, 5=Impacto muito alto |

#### D4. Instrumentos de Planejamento da Produção

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Uso de instrumentos** | `instrumentos_producao` | Radio | sim_frequentemente, sim_pouco, nao_existem, nao_sei |
| **Exemplo** | `exemplo_instrumentos_producao` | Textarea | Texto livre (condicional) |

**Opções**:
- Sim, usamos frequentemente
- Sim, mas pouco utilizados
- Não existem
- Não sei

#### D5. Apoio a Mercados Institucionais

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `freq_apoio_mercados_institucionais` | Select | sempre, frequentemente, as_vezes, raramente, nunca |

**Opções**:
- Sempre
- Frequentemente
- Às vezes
- Raramente
- Nunca

#### D6. Conhecimento de Oferta e Demanda (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Nível de conhecimento** | `conhecimento_oferta_demanda` | Radio | 1-5 | 1=Nenhum conhecimento, 5=Conhecimento muito alto |

#### D7. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo D** | `comentario_eixo_d` | Textarea | Não |

---

### EIXO E – INDICADORES, RELATÓRIOS E AVALIAÇÃO DE RESULTADOS

#### E1. Instrumentos de Acompanhamento

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Instrumentos** | `instrumentos_acompanhamento` | Checkbox (múltipla escolha) | sigater, relatorios_internos, planilhas_proprias, nenhum, outro |
| **Outro instrumento** | `instrumentos_acompanhamento_outro` | Text | Texto livre (condicional) |

**Opções**:
- Registros no Sigater
- Relatórios internos
- Planilhas próprias
- Nenhum instrumento
- Outro (especificar)

#### E2. Frequência de Uso de Indicadores

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `freq_uso_indicadores` | Radio | nunca, raramente, as_vezes, frequentemente, sempre |

**Opções**:
- Nunca
- Raramente
- Às vezes
- Frequentemente
- Sempre

#### E3. Principais Indicadores

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Indicadores utilizados** | `principais_indicadores` | Textarea | Não |

#### E4. Avaliação - Indicadores Ajudam (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Utilidade** | `avaliacao_ajuda_indicadores` | Radio | 1-5 | 1=Não ajudam, 5=Ajudam muito |

#### E5. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo E** | `comentario_eixo_e` | Textarea | Não |

---

### COMENTÁRIO FINAL

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Considerações finais** | `comentario_final` | Textarea | Não |

---

## 📋 FORMULÁRIO GERENTES LOCAIS

### Metadados do Formulário

*Mesma estrutura do formulário de extensionistas*

| Campo | Tipo | Descrição | Obrigatório | Geração |
|-------|------|-----------|-------------|---------|
| `id` | Integer | ID único local (auto-increment) | Sim | Auto |
| `protocolo` | String | Protocolo único (FORMATO: YYYYMMDDHHMMSS) | Sim | Auto |
| `timestamp_inicio` | DateTime | Data/hora início preenchimento | Sim | Auto |
| `timestamp_fim` | DateTime | Data/hora conclusão | Sim | Auto |
| `sincronizado` | Boolean | Status de sincronização com servidor | Sim | Auto (false) |
| `data_sincronizacao` | DateTime | Data/hora da última sincronização | Não | Auto |

---

### MÓDULO I - IDENTIFICAÇÃO DO ESCRITÓRIO

| Campo | Nome Técnico | Tipo | Valores Possíveis | Obrigatório | Descrição |
|-------|--------------|------|-------------------|-------------|-----------|
| **Município** | `municipio` | Select | Lista de municípios RO | Sim | Município do escritório local |
| **Escritório Local** | `escritorioLocal` | Select | Escritórios do município | Sim | Nome do escritório local |
| **Nome do Gerente** | `nomeGerente` | Text | Texto livre | Não | Nome do gerente local (opcional) |
| **Tempo como Gerente** | `tempoGerente` | Radio | menos1, 1a2, 3a5, 6a10, mais10 | Sim | Tempo na função de gerente |

**Opções de Tempo**:
- Menos de 1 ano
- 1-2 anos
- 3-5 anos
- 6-10 anos
- Mais de 10 anos

---

### EIXO A – GESTÃO DE EQUIPE E RECURSOS

#### A1. Número de Extensionistas

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Quantidade** | `num_extensionistas` | Select | 1-2, 3-5, 6-10, mais10 |

**Opções**:
- 1-2 extensionistas
- 3-5 extensionistas
- 6-10 extensionistas
- Mais de 10 extensionistas

#### A2. Principais Desafios de Gestão

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Desafios** | `desafios_gestao` | Checkbox (múltipla escolha) | falta_equipe, recursos_limitados, distancias, burocracia, metas_irreais, capacitacao_equipe, outro |
| **Outro desafio** | `desafios_gestao_outro` | Text | Texto livre (condicional) |

**Opções**:
- Falta de equipe técnica
- Recursos materiais limitados
- Grandes distâncias territoriais
- Excesso de burocracia
- Metas institucionais irreais
- Falta de capacitação da equipe
- Outro (especificar)

#### A3. Frequência de Reuniões de Equipe

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `freq_reunioes_equipe` | Select | semanal, quinzenal, mensal, bimestral, semestral, raramente, nunca |

**Opções**:
- Semanal
- Quinzenal
- Mensal
- Bimestral
- Semestral
- Raramente
- Nunca

#### A4. Instrumentos de Planejamento

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Uso** | `instrumentos_planejamento` | Radio | sim_estruturado, sim_informal, nao_usa, nao_sabe |
| **Exemplo** | `exemplo_planejamento` | Textarea | Texto livre (condicional) |

**Opções**:
- Sim, de forma estruturada
- Sim, mas de forma informal
- Não utiliza
- Não sabe

#### A5. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo A** | `comentario_eixo_a` | Textarea | Não |

---

### EIXO B – ARTICULAÇÃO INSTITUCIONAL

#### B1. Parcerias Estabelecidas

*Mesma estrutura do formulário de extensionistas*

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Parcerias** | `parcerias_institucionais` | Checkbox (múltipla escolha) | idaron, embrapa, prefeituras, sedam, secretarias_municipais, cooperativas_associacoes, movimentos_sociais, instituicoes_financeiras, sistema_s, sindicatos, outro |
| **Outra parceria** | `parcerias_institucionais_outro` | Text | Texto livre (condicional) |

#### B2. Participação em Conselhos e Fóruns

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `participa_conselhos` | Radio | sim_ativo, sim_ocasional, nao_participa |

**Opções**:
- Sim, participação ativa
- Sim, ocasionalmente
- Não participa

#### B3. Influência do Escritório (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Nível de influência** | `influencia_escritorio` | Radio | 1-5 | 1=Nenhuma influência, 5=Muita influência |

#### B4. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo B** | `comentario_eixo_b` | Textarea | Não |

---

### EIXO C – POLÍTICAS PÚBLICAS E ACESSO A PROGRAMAS

#### C1. Programas com Mais Atuação

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Programas** | `programas_atuacao` | Checkbox (múltipla escolha) | pronaf, paa, pnae, garantia_safra, car, dap_caf, credito_rural, assistencia_tecnica, outro |
| **Outro programa** | `programas_atuacao_outro` | Text | Texto livre (condicional) |

**Opções**:
- Pronaf
- PAA (Programa de Aquisição de Alimentos)
- PNAE (Alimentação Escolar)
- Garantia Safra
- CAR (Cadastro Ambiental Rural)
- DAP/CAF
- Crédito rural
- Assistência técnica
- Outro (especificar)

#### C2. Principais Dificuldades de Acesso

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Dificuldades** | `dificuldades_acesso` | Checkbox (múltipla escolha) | burocracia, falta_documentacao, desconhecimento, falta_recursos, distancia, prazos_curtos, outro |
| **Outra dificuldade** | `dificuldades_acesso_outro` | Text | Texto livre (condicional) |

**Opções**:
- Excesso de burocracia
- Falta de documentação dos agricultores
- Desconhecimento dos programas
- Falta de recursos para contrapartida
- Distância dos órgãos
- Prazos muito curtos
- Outro (especificar)

#### C3. Avaliação de Impacto dos Programas (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Impacto** | `impacto_programas` | Radio | 1-5 | 1=Nenhum impacto, 5=Impacto muito alto |

#### C4. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo C** | `comentario_eixo_c` | Textarea | Não |

---

### EIXO D – INDICADORES E RESULTADOS

#### D1. Principais Indicadores Acompanhados

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Indicadores** | `indicadores_acompanhados` | Textarea | Não |

#### D2. Frequência de Uso de Indicadores

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Frequência** | `freq_uso_indicadores` | Radio | sempre, frequentemente, as_vezes, raramente, nunca |

#### D3. Instrumentos de Monitoramento

| Campo | Nome Técnico | Tipo | Valores Possíveis |
|-------|--------------|------|-------------------|
| **Instrumentos** | `instrumentos_monitoramento` | Checkbox (múltipla escolha) | sigater, planilhas, relatorios_mensais, reunioes, nenhum, outro |
| **Outro instrumento** | `instrumentos_monitoramento_outro` | Text | Texto livre (condicional) |

**Opções**:
- Sigater
- Planilhas de controle
- Relatórios mensais
- Reuniões de equipe
- Nenhum instrumento formal
- Outro (especificar)

#### D4. Utilidade dos Indicadores (Escala Likert 1-5)

| Campo | Nome Técnico | Tipo | Escala | Descrição |
|-------|--------------|------|--------|-----------|
| **Utilidade** | `utilidade_indicadores` | Radio | 1-5 | 1=Não ajudam, 5=Ajudam muito |

#### D5. Comentário Livre

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Comentário Eixo D** | `comentario_eixo_d` | Textarea | Não |

---

### COMENTÁRIO FINAL

| Campo | Nome Técnico | Tipo | Obrigatório |
|-------|--------------|------|-------------|
| **Considerações finais** | `comentario_final` | Textarea | Não |

---

## 🔄 Fluxo de Dados

### 1. Coleta (Offline-First)
```
Formulário → Validação → IndexedDB Local → Status: Pendente
```

### 2. Sincronização
```
IndexedDB → Netlify Function → Azure SQL → Status: Sincronizado
```

### 3. Visualização
```
Admin Panel → IndexedDB/Azure SQL → Filtros por Aba → Renderização
```

---

## 📊 Estrutura de Dados JSON

### Exemplo de Formulário Extensionista Completo

```json
{
  "id": 1,
  "protocolo": "20251210143022",
  "timestamp_inicio": "2025-12-10T14:30:22.123Z",
  "timestamp_fim": "2025-12-10T14:45:18.456Z",
  "sincronizado": true,
  "data_sincronizacao": "2025-12-10T14:46:05.789Z",
  
  "municipio": "Ministro Andreazza",
  "escritorioLocal": "Escritório Local de Ministro Andreazza",
  "tempoEmater": "15a19",
  "nomeCompleto": "João Silva",
  
  "metodosFrequentes": ["visitas_tecnicas", "dias_campo", "whatsapp_digital"],
  "metodosFrequentesOutro": "",
  
  "metodosMelhoresResultados": ["visitas_tecnicas", "demonstracao_metodo"],
  "metodosMelhoresResultadosOutro": "",
  
  "dificuldade_falta_tempo": "4",
  "dificuldade_num_tecnicos": "5",
  "dificuldade_distancia": "3",
  "dificuldade_baixa_adesao": "2",
  "dificuldade_recursos": "4",
  "dificuldade_demandas_admin": "5",
  "dificuldade_metas": "3",
  
  "comentario_eixo_a": "Maior dificuldade é conciliar todas as demandas...",
  
  "priorizacao_atendimentos": ["demanda_espontanea", "vulnerabilidade_social"],
  "priorizacao_atendimentos_outro": "",
  
  "nivel_equidade": "4",
  
  "instrumentos_formais": "sim_parcialmente",
  "exemplo_instrumento_formal": "Utilizamos fichas de cadastro...",
  
  "comentario_eixo_b": "",
  
  "parcerias_ativas": ["prefeituras", "cooperativas_associacoes", "sistema_s"],
  "parcerias_ativas_outro": "",
  
  "participa_foruns": "sim_ocasionalmente",
  
  "influencia_emater": "4",
  
  "comentario_eixo_c": "",
  
  "freq_demanda_mercado": "frequentemente",
  "capacitacao_mercado": "sim",
  "impacto_capacitacao": "4",
  
  "instrumentos_producao": "sim_pouco",
  "exemplo_instrumentos_producao": "Calendário agrícola",
  
  "freq_apoio_mercados_institucionais": "as_vezes",
  
  "conhecimento_oferta_demanda": "3",
  
  "comentario_eixo_d": "",
  
  "instrumentos_acompanhamento": ["sigater", "planilhas_proprias"],
  "instrumentos_acompanhamento_outro": "",
  
  "freq_uso_indicadores": "frequentemente",
  
  "principais_indicadores": "Número de visitas, famílias atendidas...",
  
  "avaliacao_ajuda_indicadores": "4",
  
  "comentario_eixo_e": "",
  
  "comentario_final": "Sistema funcionou bem no campo..."
}
```

---

## 🔐 Segurança e Privacidade

### Dados Pessoais Coletados
- **Nome completo** (opcional): Apenas para identificação interna
- **Município e escritório**: Dados de localização profissional
- **Tempo de serviço**: Informação funcional

### Conformidade LGPD
- ✅ Dados coletados com finalidade específica (avaliação institucional)
- ✅ Dados mínimos necessários
- ✅ Armazenamento seguro (Azure SQL)
- ✅ Acesso restrito (apenas admin)
- ✅ Nome opcional (privacidade por design)

---

## 📱 Compatibilidade e Requisitos Técnicos

### Navegadores Suportados
- Chrome/Edge 90+
- Firefox 88+
- Safari 14+

### Requisitos de Sistema
- **IndexedDB** habilitado
- **JavaScript** ativado
- **Conexão** para sincronização (opcional para preenchimento)

### Armazenamento
- **Local**: ~2-5 KB por formulário
- **Servidor**: Backup completo em Azure SQL

---

## 📈 Estatísticas e Análises Possíveis

### Por Formulário
- Taxa de preenchimento por eixo
- Tempo médio de preenchimento
- Campos mais/menos respondidos

### Por Município
- Cobertura territorial
- Métodos mais utilizados
- Dificuldades predominantes
- Nível de parcerias

### Por Região
- Comparação entre escritórios
- Tendências de gestão
- Impacto de programas

---

## 🔄 Versionamento

| Versão | Data | Alterações |
|--------|------|------------|
| 1.0 | 15/12/2025 | Versão inicial do dicionário |

---

## 📞 Contato e Suporte

**Desenvolvedor**: Sistema Formema  
**Cliente**: Emater-RO  
**Escritório Piloto**: Ministro Andreazza, RO

---

**Fim do Documento**
