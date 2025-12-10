-- ========================================
-- IDENTIFICAR DEPENDÊNCIAS
-- ========================================

USE [db-ematech];
GO

-- Verificar índices nas colunas
SELECT 
    i.name AS indice,
    c.name AS coluna,
    'DROP INDEX ' + i.name + ' ON formulario_extensionista;' AS comando_drop,
    ic.index_column_id,
    i.type_desc
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('formulario_extensionista')
    AND c.name IN (
        'dificuldade_falta_recursos',
        'dificuldade_resistencia_produtores',
        'dificuldade_falta_capacitacao',
        'dificuldade_metodos_inadequados',
        'dificuldade_falta_apoio_gestao',
        'dificuldade_comunicacao_equipe'
    );
GO

-- Verificar constraints de check
SELECT 
    cc.name AS constraint_name,
    cc.definition,
    'ALTER TABLE formulario_extensionista DROP CONSTRAINT ' + cc.name + ';' AS comando_drop
FROM sys.check_constraints cc
WHERE cc.parent_object_id = OBJECT_ID('formulario_extensionista')
    AND (
        cc.definition LIKE '%dificuldade_falta_recursos%' OR
        cc.definition LIKE '%dificuldade_resistencia_produtores%' OR
        cc.definition LIKE '%dificuldade_falta_capacitacao%' OR
        cc.definition LIKE '%dificuldade_metodos_inadequados%' OR
        cc.definition LIKE '%dificuldade_falta_apoio_gestao%' OR
        cc.definition LIKE '%dificuldade_comunicacao_equipe%'
    );
GO

-- Verificar constraints default
SELECT 
    dc.name AS constraint_name,
    c.name AS column_name,
    'ALTER TABLE formulario_extensionista DROP CONSTRAINT ' + dc.name + ';' AS comando_drop
FROM sys.default_constraints dc
INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
WHERE dc.parent_object_id = OBJECT_ID('formulario_extensionista')
    AND c.name IN (
        'dificuldade_falta_recursos',
        'dificuldade_resistencia_produtores',
        'dificuldade_falta_capacitacao',
        'dificuldade_metodos_inadequados',
        'dificuldade_falta_apoio_gestao',
        'dificuldade_comunicacao_equipe'
    );
GO

-- Verificar foreign keys
SELECT 
    fk.name AS constraint_name,
    'ALTER TABLE ' + OBJECT_NAME(fk.parent_object_id) + ' DROP CONSTRAINT ' + fk.name + ';' AS comando_drop
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('formulario_extensionista')
    OR fk.referenced_object_id = OBJECT_ID('formulario_extensionista');
GO
