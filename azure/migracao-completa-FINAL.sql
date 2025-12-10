-- ========================================
-- SOLUÇÃO COMPLETA: Remover dependências + Migrar colunas
-- ========================================

USE [db-ematech];
GO

-- PASSO 1: Dropar índice
DROP INDEX idx_dificuldade_falta_tempo ON formulario_extensionista;
PRINT '✅ Índice removido';
GO

-- PASSO 2: Dropar check constraint
ALTER TABLE formulario_extensionista DROP CONSTRAINT CK__formulari__dific__74794A92;
PRINT '✅ Check constraint removido';
GO

-- PASSO 3: Adicionar novas colunas
ALTER TABLE formulario_extensionista ADD dificuldade_num_tecnicos INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_distancia INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_baixa_adesao INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_recursos INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_demandas_admin INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_metas INT NULL;
PRINT '✅ Novas colunas criadas';
GO

-- PASSO 4: Copiar dados
UPDATE formulario_extensionista 
SET 
    dificuldade_num_tecnicos = dificuldade_falta_recursos,
    dificuldade_distancia = dificuldade_resistencia_produtores,
    dificuldade_baixa_adesao = dificuldade_falta_capacitacao,
    dificuldade_recursos = dificuldade_metodos_inadequados,
    dificuldade_demandas_admin = dificuldade_falta_apoio_gestao,
    dificuldade_metas = dificuldade_comunicacao_equipe;
PRINT '✅ Dados copiados';
GO

-- PASSO 5: Dropar colunas antigas
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_recursos;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_resistencia_produtores;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_capacitacao;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_metodos_inadequados;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_apoio_gestao;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_comunicacao_equipe;
PRINT '✅ Colunas antigas removidas';
GO

-- PASSO 6: Recriar índice (agora nas colunas corretas)
CREATE NONCLUSTERED INDEX idx_dificuldade_falta_tempo 
ON formulario_extensionista (dificuldade_falta_tempo, dificuldade_num_tecnicos);
PRINT '✅ Índice recriado';
GO

-- PASSO 7: Recriar check constraint (valores entre 1 e 5)
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

-- PASSO 8: Verificar resultado
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
PRINT 'Todas as colunas foram renomeadas e dependências recriadas.';
GO
