-- Verificar nome correto da tabela
USE [db-ematech];
GO

-- Listar todas as tabelas que contêm "formulario" ou "extensionista"
SELECT 
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME LIKE '%formulario%' 
   OR TABLE_NAME LIKE '%extensionista%'
ORDER BY TABLE_NAME;
GO

-- Se encontrar a tabela, mostrar estrutura completa
IF OBJECT_ID('formulario_extensionista') IS NOT NULL
BEGIN
    PRINT '✅ Tabela encontrada: formulario_extensionista (SINGULAR)';
    SELECT name, TYPE_NAME(system_type_id) AS tipo
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista')
    ORDER BY column_id;
END
ELSE IF OBJECT_ID('formularios_extensionistas') IS NOT NULL
BEGIN
    PRINT '✅ Tabela encontrada: formularios_extensionistas (PLURAL)';
    SELECT name, TYPE_NAME(system_type_id) AS tipo
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('formularios_extensionistas')
    ORDER BY column_id;
END
ELSE
BEGIN
    PRINT '❌ ERRO: Nenhuma tabela encontrada!';
END
GO
