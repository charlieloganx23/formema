-- =============================================
-- Script: Adicionar Colunas Eixos C e D
-- Descrição: Adiciona 13 colunas ao formulario_extensionista
--            para suportar dados dos Eixos C (Parcerias) e D (Comercialização)
-- Tabela: formulario_extensionista
-- Data: 2024
-- =============================================

USE [db-ematech];
GO

-- =============================================
-- Eixo C: Parcerias e Articulação (5 campos)
-- =============================================

-- Campo 1: Parcerias ativas (array ou string, pode conter múltiplas seleções)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'parcerias_ativas'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD parcerias_ativas NVARCHAR(MAX) NULL;
    PRINT '✅ Coluna parcerias_ativas adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna parcerias_ativas já existe';
END
GO

-- Campo 2: Outras parcerias (texto livre)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'parcerias_ativas_outro'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD parcerias_ativas_outro NVARCHAR(500) NULL;
    PRINT '✅ Coluna parcerias_ativas_outro adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna parcerias_ativas_outro já existe';
END
GO

-- Campo 3: Participa de fóruns (texto, ex: "sim", "nao", "as-vezes")
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'participa_foruns'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD participa_foruns NVARCHAR(100) NULL;
    PRINT '✅ Coluna participa_foruns adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna participa_foruns já existe';
END
GO

-- Campo 4: Influência da Emater (escala 1-5)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'influencia_emater'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD influencia_emater INT NULL;
    PRINT '✅ Coluna influencia_emater adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna influencia_emater já existe';
END
GO

-- Campo 5: Comentários Eixo C (texto livre)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'comentario_eixo_c'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD comentario_eixo_c NVARCHAR(MAX) NULL;
    PRINT '✅ Coluna comentario_eixo_c adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna comentario_eixo_c já existe';
END
GO

-- =============================================
-- Eixo D: Acesso a Mercados e Comercialização (8 campos)
-- =============================================

-- Campo 6: Frequência demanda por mercado (texto, ex: "sempre", "frequentemente", "raramente", "nunca")
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'freq_demanda_mercado'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD freq_demanda_mercado NVARCHAR(50) NULL;
    PRINT '✅ Coluna freq_demanda_mercado adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna freq_demanda_mercado já existe';
END
GO

-- Campo 7: Capacitação em mercado (texto, ex: "sim", "nao", "parcial")
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'capacitacao_mercado'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD capacitacao_mercado NVARCHAR(100) NULL;
    PRINT '✅ Coluna capacitacao_mercado adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna capacitacao_mercado já existe';
END
GO

-- Campo 8: Impacto da capacitação (escala 1-5)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'impacto_capacitacao'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD impacto_capacitacao INT NULL;
    PRINT '✅ Coluna impacto_capacitacao adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna impacto_capacitacao já existe';
END
GO

-- Campo 9: Instrumentos de produção (array ou string, pode conter múltiplas seleções)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'instrumentos_producao'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD instrumentos_producao NVARCHAR(MAX) NULL;
    PRINT '✅ Coluna instrumentos_producao adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna instrumentos_producao já existe';
END
GO

-- Campo 10: Exemplo de instrumentos (texto livre)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'exemplo_instrumentos_producao'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD exemplo_instrumentos_producao NVARCHAR(MAX) NULL;
    PRINT '✅ Coluna exemplo_instrumentos_producao adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna exemplo_instrumentos_producao já existe';
END
GO

-- Campo 11: Frequência apoio mercados institucionais (texto, ex: "sempre", "frequentemente", "raramente", "nunca")
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'freq_apoio_mercados_institucionais'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD freq_apoio_mercados_institucionais NVARCHAR(50) NULL;
    PRINT '✅ Coluna freq_apoio_mercados_institucionais adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna freq_apoio_mercados_institucionais já existe';
END
GO

-- Campo 12: Conhecimento oferta/demanda (texto, ex: "muito-bom", "bom", "regular", "ruim")
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'conhecimento_oferta_demanda'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD conhecimento_oferta_demanda NVARCHAR(100) NULL;
    PRINT '✅ Coluna conhecimento_oferta_demanda adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna conhecimento_oferta_demanda já existe';
END
GO

-- Campo 13: Comentários Eixo D (texto livre)
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_NAME = 'formulario_extensionista' 
    AND COLUMN_NAME = 'comentario_eixo_d'
)
BEGIN
    ALTER TABLE formulario_extensionista
    ADD comentario_eixo_d NVARCHAR(MAX) NULL;
    PRINT '✅ Coluna comentario_eixo_d adicionada';
END
ELSE
BEGIN
    PRINT '⚠️  Coluna comentario_eixo_d já existe';
END
GO

-- =============================================
-- Verificação Final
-- =============================================

PRINT '';
PRINT '=============================================';
PRINT 'Verificando estrutura final...';
PRINT '=============================================';

SELECT 
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'formulario_extensionista'
AND COLUMN_NAME IN (
    'parcerias_ativas', 'parcerias_ativas_outro', 'participa_foruns',
    'influencia_emater', 'comentario_eixo_c',
    'freq_demanda_mercado', 'capacitacao_mercado', 'impacto_capacitacao',
    'instrumentos_producao', 'exemplo_instrumentos_producao',
    'freq_apoio_mercados_institucionais', 'conhecimento_oferta_demanda',
    'comentario_eixo_d'
)
ORDER BY ORDINAL_POSITION;

PRINT '';
PRINT '✅ Script finalizado com sucesso!';
PRINT 'Total de colunas adicionadas: 13 (Eixo C: 5, Eixo D: 8)';
GO
