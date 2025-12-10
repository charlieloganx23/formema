-- ========================================
-- SOLUÇÃO ALTERNATIVA: Adicionar novas colunas, copiar dados, dropar antigas
-- ========================================

USE [db-ematech];
GO

-- 1. Adicionar novas colunas com nomes corretos
ALTER TABLE formulario_extensionista ADD dificuldade_num_tecnicos INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_distancia INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_baixa_adesao INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_recursos INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_demandas_admin INT NULL;
ALTER TABLE formulario_extensionista ADD dificuldade_metas INT NULL;
GO

PRINT '✅ Novas colunas criadas';
GO

-- 2. Copiar dados das colunas antigas para as novas
UPDATE formulario_extensionista 
SET 
    dificuldade_num_tecnicos = dificuldade_falta_recursos,
    dificuldade_distancia = dificuldade_resistencia_produtores,
    dificuldade_baixa_adesao = dificuldade_falta_capacitacao,
    dificuldade_recursos = dificuldade_metodos_inadequados,
    dificuldade_demandas_admin = dificuldade_falta_apoio_gestao,
    dificuldade_metas = dificuldade_comunicacao_equipe;
GO

PRINT '✅ Dados copiados';
GO

-- 3. Dropar colunas antigas
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_recursos;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_resistencia_produtores;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_capacitacao;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_metodos_inadequados;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_falta_apoio_gestao;
ALTER TABLE formulario_extensionista DROP COLUMN dificuldade_comunicacao_equipe;
GO

PRINT '✅ Colunas antigas removidas';
GO

-- 4. Verificar resultado final
SELECT 
    name AS 'Coluna',
    TYPE_NAME(system_type_id) AS 'Tipo',
    is_nullable AS 'Nullable'
FROM sys.columns 
WHERE object_id = OBJECT_ID('formulario_extensionista')
    AND name LIKE 'dificuldade_%'
ORDER BY name;
GO

PRINT '✅✅✅ MIGRAÇÃO CONCLUÍDA COM SUCESSO!';
GO
