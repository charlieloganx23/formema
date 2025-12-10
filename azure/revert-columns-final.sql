-- ========================================
-- REVERTER NOMES DAS COLUNAS - VERSÃO FINAL
-- Remove dependências antes de renomear
-- Data: 09/12/2025
-- ========================================

USE [db-ematech];
GO

-- Desabilitar constraints temporariamente
DECLARE @sql NVARCHAR(MAX) = '';

-- Gerar comandos para desabilitar constraints
SELECT @sql = @sql + 'ALTER TABLE formulario_extensionista NOCHECK CONSTRAINT ' + name + ';' + CHAR(13)
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('formulario_extensionista');

EXEC sp_executesql @sql;
PRINT '✅ Constraints desabilitadas';
GO

-- Renomear colunas
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_recursos')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_recursos', 'dificuldade_num_tecnicos', 'COLUMN';
    PRINT '✅ dificuldade_falta_recursos → dificuldade_num_tecnicos';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_resistencia_produtores')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_resistencia_produtores', 'dificuldade_distancia', 'COLUMN';
    PRINT '✅ dificuldade_resistencia_produtores → dificuldade_distancia';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_capacitacao')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_capacitacao', 'dificuldade_baixa_adesao', 'COLUMN';
    PRINT '✅ dificuldade_falta_capacitacao → dificuldade_baixa_adesao';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_metodos_inadequados')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_metodos_inadequados', 'dificuldade_recursos', 'COLUMN';
    PRINT '✅ dificuldade_metodos_inadequados → dificuldade_recursos';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_apoio_gestao')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_apoio_gestao', 'dificuldade_demandas_admin', 'COLUMN';
    PRINT '✅ dificuldade_falta_apoio_gestao → dificuldade_demandas_admin';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_comunicacao_equipe')
BEGIN
    EXEC sp_rename 'formulario_extensionista.dificuldade_comunicacao_equipe', 'dificuldade_metas', 'COLUMN';
    PRINT '✅ dificuldade_comunicacao_equipe → dificuldade_metas';
END
GO

-- Reabilitar constraints
DECLARE @sql2 NVARCHAR(MAX) = '';

SELECT @sql2 = @sql2 + 'ALTER TABLE formulario_extensionista CHECK CONSTRAINT ' + name + ';' + CHAR(13)
FROM sys.foreign_keys
WHERE parent_object_id = OBJECT_ID('formulario_extensionista');

EXEC sp_executesql @sql2;
PRINT '✅ Constraints reabilitadas';
GO

-- Verificar resultado
PRINT '';
PRINT '🔍 Colunas após reversão:';
SELECT name, TYPE_NAME(system_type_id) AS tipo
FROM sys.columns 
WHERE object_id = OBJECT_ID('formulario_extensionista')
    AND name LIKE 'dificuldade_%'
ORDER BY name;
GO
