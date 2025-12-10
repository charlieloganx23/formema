-- ========================================
-- LIMPEZA FINAL - Verificar estado atual
-- ========================================

USE [db-ematech];
GO

-- Verificar quais colunas AINDA EXISTEM
PRINT '🔍 Verificando colunas atuais:';
SELECT 
    name AS 'Coluna Existente',
    TYPE_NAME(system_type_id) AS 'Tipo'
FROM sys.columns 
WHERE object_id = OBJECT_ID('formulario_extensionista')
    AND name LIKE 'dificuldade_%'
ORDER BY name;
GO

-- Remover índice antigo se existir
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_dificuldade_falta_tempo' AND object_id = OBJECT_ID('formulario_extensionista'))
BEGIN
    DROP INDEX idx_dificuldade_falta_tempo ON formulario_extensionista;
    PRINT '✅ Índice antigo removido';
END
GO

-- Dropar apenas colunas que AINDA EXISTEM
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_resistencia_produtores')
BEGIN
    ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_resistencia_produtores;
    PRINT '✅ dificuldade_resistencia_produtores removida';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_capacitacao')
BEGIN
    ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_capacitacao;
    PRINT '✅ dificuldade_falta_capacitacao removida';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_metodos_inadequados')
BEGIN
    ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_metodos_inadequados;
    PRINT '✅ dificuldade_metodos_inadequados removida';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_falta_apoio_gestao')
BEGIN
    ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_apoio_gestao;
    PRINT '✅ dificuldade_falta_apoio_gestao removida';
END
GO

IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('formulario_extensionista') AND name = 'dificuldade_comunicacao_equipe')
BEGIN
    ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_comunicacao_equipe;
    PRINT '✅ dificuldade_comunicacao_equipe removida';
END
GO

-- Recriar índice com colunas corretas
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_dificuldade_falta_tempo' AND object_id = OBJECT_ID('formulario_extensionista'))
BEGIN
    CREATE NONCLUSTERED INDEX idx_dificuldade_falta_tempo 
    ON formulario_extensionista (dificuldade_falta_tempo, dificuldade_num_tecnicos);
    PRINT '✅ Índice recriado';
END
GO

-- Criar check constraint se não existir
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_dificuldades_range')
BEGIN
    ALTER TABLE formulario_extensionista 
    ADD CONSTRAINT CK_dificuldades_range 
    CHECK (
        (dificuldade_falta_tempo IS NULL OR dificuldade_falta_tempo BETWEEN 1 AND 5) AND
        (dificuldade_num_tecnicos IS NULL OR dificuldade_num_tecnicos BETWEEN 1 AND 5) AND
        (dificuldade_distancia IS NULL OR dificuldade_distancia BETWEEN 1 AND 5) AND
        (dificuldade_baixa_adesao IS NULL OR dificuldade_baixa_adesao BETWEEN 1 AND 5) AND
        (dificuldade_recursos IS NULL OR dificuldade_recursos BETWEEN 1 AND 5) AND
        (dificuldade_demandas_admin IS NULL OR dificuldade_demandas_admin BETWEEN 1 AND 5) AND
        (dificuldade_metas IS NULL OR dificuldade_metas BETWEEN 1 AND 5)
    );
    PRINT '✅ Check constraint criado';
END
GO

-- VERIFICAÇÃO FINAL
PRINT '';
PRINT '🔍 ESTRUTURA FINAL DAS COLUNAS:';
SELECT 
    name AS 'Coluna',
    TYPE_NAME(system_type_id) AS 'Tipo',
    is_nullable AS 'Nullable'
FROM sys.columns 
WHERE object_id = OBJECT_ID('formulario_extensionista')
    AND name LIKE 'dificuldade_%'
ORDER BY name;
GO

PRINT '';
PRINT '✅ Esperado: 7 colunas (dificuldade_falta_tempo + 6 novas)';
PRINT '🎉 MIGRAÇÃO CONCLUÍDA! Teste a sincronização agora.';
GO
