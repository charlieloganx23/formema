-- ========================================
-- REMOVER TODAS AS CONSTRAINTS E MIGRAR
-- ========================================

USE [db-ematech];
GO

-- PASSO 1: Remover TODAS as constraints das colunas antigas
DECLARE @sql NVARCHAR(MAX) = '';

-- Gerar comandos para dropar todos os check constraints relacionados às colunas antigas
SELECT @sql = @sql + 'ALTER TABLE formulario_extensionista DROP CONSTRAINT ' + cc.name + ';' + CHAR(13)
FROM sys.check_constraints cc
INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id 
    AND cc.parent_column_id = c.column_id
WHERE cc.parent_object_id = OBJECT_ID('formulario_extensionista')
    AND c.name IN (
        'dificuldade_falta_recursos',
        'dificuldade_resistencia_produtores',
        'dificuldade_falta_capacitacao',
        'dificuldade_metodos_inadequados',
        'dificuldade_falta_apoio_gestao',
        'dificuldade_comunicacao_equipe'
    );

-- Executar comandos de DROP
IF LEN(@sql) > 0
BEGIN
    EXEC sp_executesql @sql;
    PRINT '✅ Check constraints removidos';
END
GO

-- PASSO 2: Remover índice se existir
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'idx_dificuldade_falta_tempo' AND object_id = OBJECT_ID('formulario_extensionista'))
BEGIN
    DROP INDEX idx_dificuldade_falta_tempo ON formulario_extensionista;
    PRINT '✅ Índice removido';
END
GO

-- PASSO 3: Copiar dados para colunas novas (que já existem)
UPDATE formulario_extensionista 
SET 
    dificuldade_num_tecnicos = COALESCE(dificuldade_num_tecnicos, dificuldade_falta_recursos),
    dificuldade_distancia = COALESCE(dificuldade_distancia, dificuldade_resistencia_produtores),
    dificuldade_baixa_adesao = COALESCE(dificuldade_baixa_adesao, dificuldade_falta_capacitacao),
    dificuldade_recursos = COALESCE(dificuldade_recursos, dificuldade_metodos_inadequados),
    dificuldade_demandas_admin = COALESCE(dificuldade_demandas_admin, dificuldade_falta_apoio_gestao),
    dificuldade_metas = COALESCE(dificuldade_metas, dificuldade_comunicacao_equipe);
PRINT '✅ Dados copiados/atualizados';
GO

-- PASSO 4: Dropar colunas antigas
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_recursos;
PRINT '✅ dificuldade_falta_recursos removida';
GO

ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_resistencia_produtores;
PRINT '✅ dificuldade_resistencia_produtores removida';
GO

ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_capacitacao;
PRINT '✅ dificuldade_falta_capacitacao removida';
GO

ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_metodos_inadequados;
PRINT '✅ dificuldade_metodos_inadequados removida';
GO

ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_apoio_gestao;
PRINT '✅ dificuldade_falta_apoio_gestao removida';
GO

ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_comunicacao_equipe;
PRINT '✅ dificuldade_comunicacao_equipe removida';
GO

-- PASSO 5: Recriar índice
CREATE NONCLUSTERED INDEX idx_dificuldade_falta_tempo 
ON formulario_extensionista (dificuldade_falta_tempo, dificuldade_num_tecnicos);
PRINT '✅ Índice recriado';
GO

-- PASSO 6: Criar novo check constraint para TODAS as colunas
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
PRINT '✅ Check constraint recriado';
GO

-- VERIFICAÇÃO FINAL
PRINT '';
PRINT '🔍 Estrutura final:';
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
PRINT '🎉🎉🎉 MIGRAÇÃO CONCLUÍDA COM SUCESSO! 🎉🎉🎉';
PRINT 'Agora teste a sincronização do formulário pendente.';
GO
