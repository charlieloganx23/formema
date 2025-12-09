-- Script SQL para adicionar novos campos do Eixo B - Critérios de Priorização e Equidade
-- Formulário: Extensionistas
-- Banco de dados: db-ematech
-- Servidor: srv-db-cxtce.database.windows.net
-- Data: 2025

-- ========================================
-- EIXO B: Critérios de Priorização e Equidade
-- ========================================

-- 1. Campo priorizacao_atendimentos (JSON array)
-- Armazena quais critérios são usados para priorizar atendimentos
-- Valores possíveis: demanda_espontanea, criterios_tecnicos_emater, criterios_tecnicos_extensionista,
--                    politicas_publicas, vulnerabilidade_social, ordem_chegada, outro
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'priorizacao_atendimentos'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD priorizacao_atendimentos NVARCHAR(MAX) NULL;
    PRINT 'Coluna priorizacao_atendimentos adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna priorizacao_atendimentos já existe.';
END
GO

-- 2. Campo priorizacao_atendimentos_outro (texto livre)
-- Para quando o usuário seleciona "outro" na questão anterior
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'priorizacao_atendimentos_outro'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD priorizacao_atendimentos_outro NVARCHAR(500) NULL;
    PRINT 'Coluna priorizacao_atendimentos_outro adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna priorizacao_atendimentos_outro já existe.';
END
GO

-- 3. Campo nivel_equidade (Likert 1-5)
-- Avaliação do nível de equidade no atendimento
-- Valores: 1 = muito baixa, 2 = baixa, 3 = média, 4 = alta, 5 = muito alta
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'nivel_equidade'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD nivel_equidade INT NULL
    CHECK (nivel_equidade BETWEEN 1 AND 5);
    PRINT 'Coluna nivel_equidade adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna nivel_equidade já existe.';
END
GO

-- 4. Campo instrumentos_formais (escolha única)
-- Existência de instrumentos formais de priorização
-- Valores: sim_oficiais, sim_parcialmente, nao_existe, nao_sei
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'instrumentos_formais'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD instrumentos_formais NVARCHAR(100) NULL;
    PRINT 'Coluna instrumentos_formais adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna instrumentos_formais já existe.';
END
GO

-- 5. Campo exemplo_instrumento_formal (texto livre)
-- Exemplo de instrumento formal utilizado (se aplicável)
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'exemplo_instrumento_formal'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD exemplo_instrumento_formal NVARCHAR(MAX) NULL;
    PRINT 'Coluna exemplo_instrumento_formal adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna exemplo_instrumento_formal já existe.';
END
GO

-- 6. Campo comentario_eixo_b (texto livre)
-- Comentários abertos sobre o Eixo B
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'comentario_eixo_b'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD comentario_eixo_b NVARCHAR(MAX) NULL;
    PRINT 'Coluna comentario_eixo_b adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna comentario_eixo_b já existe.';
END
GO

-- ========================================
-- VIEWS ANALÍTICAS PARA EIXO B
-- ========================================

-- VIEW 1: Análise de Equidade e Priorização
-- Combina dados de equidade e instrumentos formais para análise institucional
IF OBJECT_ID('vw_analise_equidade_priorizacao', 'V') IS NOT NULL
    DROP VIEW vw_analise_equidade_priorizacao;
GO

CREATE VIEW vw_analise_equidade_priorizacao AS
SELECT 
    f.protocolo,
    f.municipio,
    f.unidade_emater,
    f.territorio,
    f.nivel_equidade,
    f.instrumentos_formais,
    f.priorizacao_atendimentos,
    f.exemplo_instrumento_formal,
    f.comentario_eixo_b,
    f.created_at,
    -- Calcular se há baixa equidade (níveis 1 ou 2)
    CASE 
        WHEN f.nivel_equidade <= 2 THEN 'Baixa'
        WHEN f.nivel_equidade = 3 THEN 'Média'
        WHEN f.nivel_equidade >= 4 THEN 'Alta'
        ELSE 'Não informado'
    END AS classificacao_equidade,
    -- Indicador de formalização (tem instrumento formal)
    CASE 
        WHEN f.instrumentos_formais IN ('sim_oficiais', 'sim_parcialmente') THEN 1
        ELSE 0
    END AS tem_instrumento_formal
FROM formulario_extensionista f
WHERE f.status = 'completo';
GO

PRINT 'View vw_analise_equidade_priorizacao criada com sucesso.';
GO

-- VIEW 2: Critérios de Priorização por Município
-- Mostra quais critérios são mais utilizados em cada município
IF OBJECT_ID('vw_criterios_por_municipio', 'V') IS NOT NULL
    DROP VIEW vw_criterios_por_municipio;
GO

CREATE VIEW vw_criterios_por_municipio AS
SELECT 
    f.municipio,
    f.territorio,
    COUNT(*) AS total_respostas,
    -- Contar quantos têm instrumentos formais
    SUM(CASE WHEN f.instrumentos_formais IN ('sim_oficiais', 'sim_parcialmente') THEN 1 ELSE 0 END) AS com_instrumento_formal,
    -- Média de equidade
    AVG(CAST(f.nivel_equidade AS FLOAT)) AS media_nivel_equidade,
    -- Contar respostas com baixa equidade
    SUM(CASE WHEN f.nivel_equidade <= 2 THEN 1 ELSE 0 END) AS count_baixa_equidade,
    -- Contar respostas com alta equidade
    SUM(CASE WHEN f.nivel_equidade >= 4 THEN 1 ELSE 0 END) AS count_alta_equidade
FROM formulario_extensionista f
WHERE f.status = 'completo'
GROUP BY f.municipio, f.territorio;
GO

PRINT 'View vw_criterios_por_municipio criada com sucesso.';
GO

-- VIEW 3: Diagnóstico de Equidade Crítica
-- Identifica unidades com equidade muito baixa ou sem instrumentos formais
IF OBJECT_ID('vw_diagnostico_equidade_critica', 'V') IS NOT NULL
    DROP VIEW vw_diagnostico_equidade_critica;
GO

CREATE VIEW vw_diagnostico_equidade_critica AS
SELECT 
    f.protocolo,
    f.municipio,
    f.unidade_emater,
    f.territorio,
    f.nivel_equidade,
    f.instrumentos_formais,
    f.comentario_eixo_b,
    f.created_at,
    -- Identificar situações críticas
    CASE 
        WHEN f.nivel_equidade = 1 THEN 'CRÍTICO: Equidade muito baixa'
        WHEN f.nivel_equidade = 2 AND f.instrumentos_formais = 'nao_existe' THEN 'ALERTA: Baixa equidade sem instrumentos'
        WHEN f.instrumentos_formais = 'nao_existe' THEN 'ATENÇÃO: Sem instrumentos formais'
        ELSE 'Situação adequada'
    END AS diagnostico
FROM formulario_extensionista f
WHERE f.status = 'completo'
  AND (f.nivel_equidade <= 2 OR f.instrumentos_formais IN ('nao_existe', 'nao_sei'));
GO

PRINT 'View vw_diagnostico_equidade_critica criada com sucesso.';
GO

-- ========================================
-- ÍNDICES PARA PERFORMANCE
-- ========================================

-- Índice para consultas por nível de equidade
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'idx_nivel_equidade' 
    AND object_id = OBJECT_ID('formulario_extensionista')
)
BEGIN
    CREATE INDEX idx_nivel_equidade 
    ON formulario_extensionista(nivel_equidade)
    INCLUDE (municipio, unidade_emater, instrumentos_formais);
    PRINT 'Índice idx_nivel_equidade criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Índice idx_nivel_equidade já existe.';
END
GO

-- Índice para consultas por instrumentos formais
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'idx_instrumentos_formais' 
    AND object_id = OBJECT_ID('formulario_extensionista')
)
BEGIN
    CREATE INDEX idx_instrumentos_formais 
    ON formulario_extensionista(instrumentos_formais)
    INCLUDE (municipio, nivel_equidade);
    PRINT 'Índice idx_instrumentos_formais criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Índice idx_instrumentos_formais já existe.';
END
GO

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================

PRINT '========================================';
PRINT 'RESUMO DA ATUALIZAÇÃO DO SCHEMA - EIXO B';
PRINT '========================================';
PRINT '';
PRINT 'Novos campos adicionados:';
PRINT '  1. priorizacao_atendimentos (NVARCHAR MAX) - array JSON com critérios';
PRINT '  2. priorizacao_atendimentos_outro (NVARCHAR 500) - texto livre';
PRINT '  3. nivel_equidade (INT 1-5) - escala Likert';
PRINT '  4. instrumentos_formais (NVARCHAR 100) - escolha única';
PRINT '  5. exemplo_instrumento_formal (NVARCHAR MAX) - texto livre';
PRINT '  6. comentario_eixo_b (NVARCHAR MAX) - comentários abertos';
PRINT '';
PRINT 'Views analíticas criadas:';
PRINT '  - vw_analise_equidade_priorizacao';
PRINT '  - vw_criterios_por_municipio';
PRINT '  - vw_diagnostico_equidade_critica';
PRINT '';
PRINT 'Índices criados:';
PRINT '  - idx_nivel_equidade';
PRINT '  - idx_instrumentos_formais';
PRINT '';
PRINT 'Atualização concluída com sucesso!';
GO
