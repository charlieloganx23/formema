-- =========================================================
-- SCRIPT PARA CORRIGIR HASHES DOS USUÁRIOS
-- =========================================================
-- PROBLEMA: Os hashes estavam incorretos no banco
-- SOLUÇÃO: Atualizar com hashes SHA-256 corretos
-- =========================================================

-- Atualizar ADMIN (senha: admin123)
UPDATE usuarios_formema 
SET senha = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9'
WHERE usuario = 'admin';

-- Atualizar ou criar EXTENSIONISTA (login: extensionista, senha: ext123)
-- Primeiro, tentar atualizar o registro com id=2
UPDATE usuarios_formema 
SET usuario = 'extensionista',
    senha = 'e90f8ebece18574d492ba9c500ea0f6b260cc33bc62918efe683893a29e84d86',
    nome_completo = 'Extensionista Teste',
    email = 'extensionista@emater.ro.gov.br'
WHERE id = 2;

-- Se não existir, inserir
IF NOT EXISTS (SELECT 1 FROM usuarios_formema WHERE usuario = 'extensionista')
BEGIN
    INSERT INTO usuarios_formema (usuario, senha, nome_completo, email, perfil, municipio, escritorio_local)
    VALUES (
        'extensionista',
        'e90f8ebece18574d492ba9c500ea0f6b260cc33bc62918efe683893a29e84d86',
        'Extensionista Teste',
        'extensionista@emater.ro.gov.br',
        'extensionista',
        'Ministro Andreazza',
        'Escritório Local de Ministro Andreazza'
    );
END

-- Atualizar GERENTE (senha: senha123 - CORRIGIDA)
UPDATE usuarios_formema 
SET senha = '55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251'
WHERE usuario = 'ger.teste';

-- Verificar resultado
SELECT id, usuario, nome_completo, perfil, ativo
FROM usuarios_formema
ORDER BY id;

PRINT '✅ Hashes corrigidos com sucesso!';
PRINT '';
PRINT '📋 CREDENCIAIS ATUALIZADAS:';
PRINT '   admin / admin123';
PRINT '   extensionista / ext123';
PRINT '   ger.teste / senha123';
