-- =========================================================
-- Script para atualizar usuário gerente
-- De: ger.teste / senha123
-- Para: gerentes / ger123
-- =========================================================

USE db_ematech;
GO

-- Atualizar usuário e senha do gerente
UPDATE usuarios_formema
SET 
    usuario = 'gerentes',
    senha = '64b579c165d1f10844bbe0ce9e2bfb51d298ce9e2ac46302944f9fd01d08ef16'  -- Hash SHA-256 de 'ger123'
WHERE 
    usuario = 'ger.teste'
    AND perfil = 'gerente';
GO

-- Verificar a atualização
SELECT 
    usuario,
    nome_completo,
    email,
    perfil,
    municipio,
    ativo,
    data_criacao,
    CASE 
        WHEN senha = '64b579c165d1f10844bbe0ce9e2bfb51d298ce9e2ac46302944f9fd01d08ef16' 
        THEN '✅ CORRETO (ger123)' 
        ELSE '❌ ERRO'
    END as verificacao_senha
FROM usuarios_formema
WHERE perfil = 'gerente';
GO
