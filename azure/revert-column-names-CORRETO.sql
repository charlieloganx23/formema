-- ========================================
-- REVERTER NOMES DAS COLUNAS - EIXO A (CORRIGIDO)
-- Script para reverter na tabela CORRETA: formulario_extensionista
-- Data: 09/12/2025
-- ========================================

USE [db-ematech];
GO

PRINT '🔄 Iniciando reversão dos nomes das colunas do Eixo A...';
PRINT '📋 Tabela: formulario_extensionista';
GO

-- Verificar se as colunas existem antes de renomear
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_recursos')
BEGIN
    PRINT '📝 Renomeando: dificuldade_falta_recursos → dificuldade_num_tecnicos';
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_recursos', 'dificuldade_num_tecnicos', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_falta_recursos não encontrada (pode já estar renomeada)';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_resistencia_produtores')
BEGIN
    PRINT '📝 Renomeando: dificuldade_resistencia_produtores → dificuldade_distancia';
    EXEC sp_rename 'formulario_extensionista.dificuldade_resistencia_produtores', 'dificuldade_distancia', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_resistencia_produtores não encontrada (pode já estar renomeada)';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_capacitacao')
BEGIN
    PRINT '📝 Renomeando: dificuldade_falta_capacitacao → dificuldade_baixa_adesao';
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_capacitacao', 'dificuldade_baixa_adesao', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_falta_capacitacao não encontrada (pode já estar renomeada)';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_metodos_inadequados')
BEGIN
    PRINT '📝 Renomeando: dificuldade_metodos_inadequados → dificuldade_recursos';
    EXEC sp_rename 'formulario_extensionista.dificuldade_metodos_inadequados', 'dificuldade_recursos', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_metodos_inadequados não encontrada (pode já estar renomeada)';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_apoio_gestao')
BEGIN
    PRINT '📝 Renomeando: dificuldade_falta_apoio_gestao → dificuldade_demandas_admin';
    EXEC sp_rename 'formulario_extensionista.dificuldade_falta_apoio_gestao', 'dificuldade_demandas_admin', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_falta_apoio_gestao não encontrada (pode já estar renomeada)';
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_comunicacao_equipe')
BEGIN
    PRINT '📝 Renomeando: dificuldade_comunicacao_equipe → dificuldade_metas';
    EXEC sp_rename 'formulario_extensionista.dificuldade_comunicacao_equipe', 'dificuldade_metas', 'COLUMN';
END
ELSE
    PRINT '⚠️ Coluna dificuldade_comunicacao_equipe não encontrada (pode já estar renomeada)';
GO

PRINT '';
PRINT '✅ Reversão concluída!';
PRINT '';
PRINT '📋 Estrutura final esperada:';
PRINT '   - dificuldade_falta_tempo (mantido)';
PRINT '   - dificuldade_num_tecnicos (revertido)';
PRINT '   - dificuldade_distancia (revertido)';
PRINT '   - dificuldade_baixa_adesao (revertido)';
PRINT '   - dificuldade_recursos (revertido)';
PRINT '   - dificuldade_demandas_admin (revertido)';
PRINT '   - dificuldade_metas (revertido)';
GO

-- Verificar colunas finais
PRINT '';
PRINT '🔍 Verificando colunas após reversão:';
SELECT 
    name AS 'Nome da Coluna',
    TYPE_NAME(system_type_id) AS 'Tipo'
FROM sys.columns 
WHERE object_id = OBJECT_ID('formulario_extensionista')
    AND name LIKE 'dificuldade_%'
ORDER BY name;
GO
