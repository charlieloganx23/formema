-- Script SQL para adicionar novos campos do Eixo E - Indicadores, Relatórios e Avaliação
-- Formulário: Extensionistas
-- Banco de dados: db-ematech
-- Servidor: srv-db-cxtce.database.windows.net
-- Data: 2025

-- ========================================
-- EIXO E: Indicadores, Relatórios e Avaliação de Resultados
-- ========================================

-- 1. Campo instrumentos_acompanhamento (JSON array)
-- Armazena quais instrumentos são usados para acompanhar resultados
-- Valores possíveis: sigater, relatorios_internos, planilhas_proprias, nenhum, outro
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'instrumentos_acompanhamento'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD instrumentos_acompanhamento NVARCHAR(MAX) NULL;
    PRINT 'Coluna instrumentos_acompanhamento adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna instrumentos_acompanhamento já existe.';
END
GO

-- 2. Campo instrumentos_acompanhamento_outro (texto livre)
-- Para quando o usuário seleciona "outro" na questão anterior
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'instrumentos_acompanhamento_outro'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD instrumentos_acompanhamento_outro NVARCHAR(500) NULL;
    PRINT 'Coluna instrumentos_acompanhamento_outro adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna instrumentos_acompanhamento_outro já existe.';
END
GO

-- 3. Campo freq_uso_indicadores (Likert textual)
-- Frequência de uso de indicadores para tomada de decisão
-- Valores: nunca, raramente, as_vezes, frequentemente, sempre
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'freq_uso_indicadores'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD freq_uso_indicadores NVARCHAR(50) NULL;
    PRINT 'Coluna freq_uso_indicadores adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna freq_uso_indicadores já existe.';
END
GO

-- 4. Campo principais_indicadores (texto livre)
-- Descrição dos principais indicadores utilizados
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'principais_indicadores'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD principais_indicadores NVARCHAR(MAX) NULL;
    PRINT 'Coluna principais_indicadores adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna principais_indicadores já existe.';
END
GO

-- 5. Campo avaliacao_ajuda_indicadores (Likert 1-5)
-- Avaliação do quanto os indicadores ajudam na tomada de decisão
-- Valores: 1 = nada, 2 = pouco, 3 = moderado, 4 = bastante, 5 = muito
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'avaliacao_ajuda_indicadores'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD avaliacao_ajuda_indicadores INT NULL
    CHECK (avaliacao_ajuda_indicadores BETWEEN 1 AND 5);
    PRINT 'Coluna avaliacao_ajuda_indicadores adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna avaliacao_ajuda_indicadores já existe.';
END
GO

-- 6. Campo comentario_eixo_e (texto livre)
-- Comentários abertos sobre o Eixo E
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'comentario_eixo_e'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD comentario_eixo_e NVARCHAR(MAX) NULL;
    PRINT 'Coluna comentario_eixo_e adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna comentario_eixo_e já existe.';
END
GO

-- 7. Campo comentario_final (texto livre)
-- Comentário final geral sobre experiência como extensionista
IF NOT EXISTS (
    SELECT * FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista') 
    AND name = 'comentario_final'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD comentario_final NVARCHAR(MAX) NULL;
    PRINT 'Coluna comentario_final adicionada com sucesso.';
END
ELSE
BEGIN
    PRINT 'Coluna comentario_final já existe.';
END
GO

-- ========================================
-- VIEWS ANALÍTICAS PARA EIXO E
-- ========================================

-- VIEW 1: Análise de Uso de Instrumentos e Indicadores
-- Combina dados sobre instrumentos utilizados e frequência de uso
IF OBJECT_ID('vw_analise_instrumentos_indicadores', 'V') IS NOT NULL
    DROP VIEW vw_analise_instrumentos_indicadores;
GO

CREATE VIEW vw_analise_instrumentos_indicadores AS
SELECT 
    f.protocolo,
    f.municipio,
    f.unidade_emater,
    f.territorio,
    f.instrumentos_acompanhamento,
    f.freq_uso_indicadores,
    f.avaliacao_ajuda_indicadores,
    f.principais_indicadores,
    f.created_at,
    -- Classificar frequência de uso
    CASE 
        WHEN f.freq_uso_indicadores = 'sempre' THEN 'Alto'
        WHEN f.freq_uso_indicadores = 'frequentemente' THEN 'Alto'
        WHEN f.freq_uso_indicadores = 'as_vezes' THEN 'Médio'
        WHEN f.freq_uso_indicadores = 'raramente' THEN 'Baixo'
        WHEN f.freq_uso_indicadores = 'nunca' THEN 'Baixo'
        ELSE 'Não informado'
    END AS nivel_uso,
    -- Classificar avaliação de ajuda
    CASE 
        WHEN f.avaliacao_ajuda_indicadores >= 4 THEN 'Alta utilidade'
        WHEN f.avaliacao_ajuda_indicadores = 3 THEN 'Moderada utilidade'
        WHEN f.avaliacao_ajuda_indicadores <= 2 THEN 'Baixa utilidade'
        ELSE 'Não avaliado'
    END AS classificacao_utilidade
FROM formulario_extensionista f
WHERE f.status = 'completo';
GO

PRINT 'View vw_analise_instrumentos_indicadores criada com sucesso.';
GO

-- VIEW 2: Instrumentos Mais Utilizados por Município
-- Análise de quais instrumentos são mais comuns em cada região
IF OBJECT_ID('vw_instrumentos_por_municipio', 'V') IS NOT NULL
    DROP VIEW vw_instrumentos_por_municipio;
GO

CREATE VIEW vw_instrumentos_por_municipio AS
SELECT 
    f.municipio,
    f.territorio,
    COUNT(*) AS total_respostas,
    -- Média de avaliação de ajuda dos indicadores
    AVG(CAST(f.avaliacao_ajuda_indicadores AS FLOAT)) AS media_avaliacao_ajuda,
    -- Contar por frequência de uso
    SUM(CASE WHEN f.freq_uso_indicadores IN ('sempre', 'frequentemente') THEN 1 ELSE 0 END) AS alto_uso,
    SUM(CASE WHEN f.freq_uso_indicadores = 'as_vezes' THEN 1 ELSE 0 END) AS medio_uso,
    SUM(CASE WHEN f.freq_uso_indicadores IN ('raramente', 'nunca') THEN 1 ELSE 0 END) AS baixo_uso
FROM formulario_extensionista f
WHERE f.status = 'completo'
GROUP BY f.municipio, f.territorio;
GO

PRINT 'View vw_instrumentos_por_municipio criada com sucesso.';
GO

-- VIEW 3: Diagnóstico de Baixo Uso de Indicadores
-- Identifica unidades com baixo uso ou baixa percepção de utilidade dos indicadores
IF OBJECT_ID('vw_diagnostico_baixo_uso_indicadores', 'V') IS NOT NULL
    DROP VIEW vw_diagnostico_baixo_uso_indicadores;
GO

CREATE VIEW vw_diagnostico_baixo_uso_indicadores AS
SELECT 
    f.protocolo,
    f.municipio,
    f.unidade_emater,
    f.territorio,
    f.freq_uso_indicadores,
    f.avaliacao_ajuda_indicadores,
    f.instrumentos_acompanhamento,
    f.comentario_eixo_e,
    f.created_at,
    -- Identificar situações críticas
    CASE 
        WHEN f.freq_uso_indicadores = 'nunca' AND f.avaliacao_ajuda_indicadores <= 2 THEN 'CRÍTICO: Não usa e não vê utilidade'
        WHEN f.freq_uso_indicadores IN ('nunca', 'raramente') THEN 'ALERTA: Baixo uso de indicadores'
        WHEN f.avaliacao_ajuda_indicadores <= 2 THEN 'ATENÇÃO: Baixa percepção de utilidade'
        ELSE 'Situação adequada'
    END AS diagnostico
FROM formulario_extensionista f
WHERE f.status = 'completo'
  AND (f.freq_uso_indicadores IN ('nunca', 'raramente') 
       OR f.avaliacao_ajuda_indicadores <= 2);
GO

PRINT 'View vw_diagnostico_baixo_uso_indicadores criada com sucesso.';
GO

-- ========================================
-- ÍNDICES PARA PERFORMANCE
-- ========================================

-- Índice para consultas por frequência de uso
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'idx_freq_uso_indicadores' 
    AND object_id = OBJECT_ID('formulario_extensionista')
)
BEGIN
    CREATE INDEX idx_freq_uso_indicadores 
    ON formulario_extensionista(freq_uso_indicadores)
    INCLUDE (municipio, unidade_emater, avaliacao_ajuda_indicadores);
    PRINT 'Índice idx_freq_uso_indicadores criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Índice idx_freq_uso_indicadores já existe.';
END
GO

-- Índice para consultas por avaliação de ajuda
IF NOT EXISTS (
    SELECT * FROM sys.indexes 
    WHERE name = 'idx_avaliacao_ajuda_indicadores' 
    AND object_id = OBJECT_ID('formulario_extensionista')
)
BEGIN
    CREATE INDEX idx_avaliacao_ajuda_indicadores 
    ON formulario_extensionista(avaliacao_ajuda_indicadores)
    INCLUDE (municipio, freq_uso_indicadores);
    PRINT 'Índice idx_avaliacao_ajuda_indicadores criado com sucesso.';
END
ELSE
BEGIN
    PRINT 'Índice idx_avaliacao_ajuda_indicadores já existe.';
END
GO

-- ========================================
-- VERIFICAÇÃO FINAL
-- ========================================

PRINT '========================================';
PRINT 'RESUMO DA ATUALIZAÇÃO DO SCHEMA - EIXO E';
PRINT '========================================';
PRINT '';
PRINT 'Novos campos adicionados:';
PRINT '  1. instrumentos_acompanhamento (NVARCHAR MAX) - array JSON com instrumentos';
PRINT '  2. instrumentos_acompanhamento_outro (NVARCHAR 500) - texto livre';
PRINT '  3. freq_uso_indicadores (NVARCHAR 50) - frequência de uso';
PRINT '  4. principais_indicadores (NVARCHAR MAX) - texto livre';
PRINT '  5. avaliacao_ajuda_indicadores (INT 1-5) - escala Likert';
PRINT '  6. comentario_eixo_e (NVARCHAR MAX) - comentários sobre Eixo E';
PRINT '  7. comentario_final (NVARCHAR MAX) - comentário final geral';
PRINT '';
PRINT 'Views analíticas criadas:';
PRINT '  - vw_analise_instrumentos_indicadores';
PRINT '  - vw_instrumentos_por_municipio';
PRINT '  - vw_diagnostico_baixo_uso_indicadores';
PRINT '';
PRINT 'Índices criados:';
PRINT '  - idx_freq_uso_indicadores';
PRINT '  - idx_avaliacao_ajuda_indicadores';
PRINT '';
PRINT 'Atualização concluída com sucesso!';
GO
