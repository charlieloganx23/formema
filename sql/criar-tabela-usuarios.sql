-- =========================================================
-- SCRIPT DE CRIAÇÃO DA TABELA DE USUÁRIOS - SISTEMA FORMEMA
-- =========================================================
-- Data: 19/02/2026
-- Descrição: Tabela para autenticação de usuários com 3 perfis
-- Perfis: extensionista, gerente, admin
-- =========================================================

-- Criar tabela de usuários
CREATE TABLE usuarios_formema (
    id INT PRIMARY KEY IDENTITY(1,1),
    usuario NVARCHAR(50) NOT NULL UNIQUE,
    senha NVARCHAR(64) NOT NULL,  -- Hash SHA-256
    nome_completo NVARCHAR(100) NOT NULL,
    email NVARCHAR(100),
    
    -- PERFIS: 'extensionista', 'gerente', 'admin'
    perfil NVARCHAR(20) NOT NULL,
    
    -- VÍNCULO GEOGRÁFICO (para pré-preenchimento)
    municipio NVARCHAR(100),
    escritorio_local NVARCHAR(100),
    
    -- CONTROLE DE ACESSO
    ativo BIT DEFAULT 1,
    data_criacao DATETIME DEFAULT GETDATE(),
    data_ultimo_acesso DATETIME,
    
    -- CONSTRAINT para validar perfis
    CONSTRAINT CHK_perfil_formema CHECK (perfil IN ('extensionista', 'gerente', 'admin'))
);
GO

-- Criar índice único para login rápido
CREATE UNIQUE INDEX IDX_usuario_formema ON usuarios_formema(usuario) WHERE ativo = 1;
GO

-- Criar índice no perfil para filtros
CREATE INDEX IDX_perfil_formema ON usuarios_formema(perfil);
GO

-- =========================================================
-- INSERIR USUÁRIOS DE TESTE
-- =========================================================

-- ADMIN (usuário: admin, senha: admin123)
INSERT INTO usuarios_formema (usuario, senha, nome_completo, email, perfil, municipio, escritorio_local)
VALUES (
    'admin', 
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9',  -- Hash SHA-256 de 'admin123'
    'Administrador do Sistema',
    'admin@emater.ro.gov.br',
    'admin',
    NULL,
    NULL
);
GO

-- EXTENSIONISTA (usuário: extensionista, senha: ext123)
INSERT INTO usuarios_formema (usuario, senha, nome_completo, email, perfil, municipio, escritorio_local)
VALUES (
    'extensionista',
    'e90f8ebece18574d492ba9c500ea0f6b260cc33bc62918efe683893a29e84d86',  -- Hash SHA-256 de 'ext123'
    'Extensionista Teste',
    'extensionista@emater.ro.gov.br',
    'extensionista',
    'Ministro Andreazza',
    'Escritório Local de Ministro Andreazza'
);
GO

-- GERENTE (usuário: gerentes, senha: ger123)
INSERT INTO usuarios_formema (usuario, senha, nome_completo, email, perfil, municipio, escritorio_local)
VALUES (
    'gerentes',
    '64b579c165d1f10844bbe0ce9e2bfb51d298ce9e2ac46302944f9fd01d08ef16',  -- Hash SHA-256 de 'ger123'
    'Maria Santos - Gerente',
    'maria.santos@emater.ro.gov.br',
    'gerente',
    'Ministro Andreazza',
    'Escritório Local de Ministro Andreazza'
);
GO

-- =========================================================
-- SCRIPT PARA GERAR HASH SHA-256 (Node.js)
-- =========================================================
/*
const crypto = require('crypto');

function gerarHashSenha(senha) {
    return crypto.createHash('sha256').update(senha).digest('hex');
}

// Gerar hashes
console.log('admin123:', gerarHashSenha('admin123'));
console.log('ext123:', gerarHashSenha('ext123'));
console.log('senha123:', gerarHashSenha('senha123'));

// RESULTADO:
// admin123: 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
// ext123: e90f8ebece18574d492ba9c500ea0f6b260cc33bc62918efe683893a29e84d86
// senha123: 55a5e9e78207b4df8699d60886fa070079463547b095d1a05bc719bb4e6cd251
*/

-- =========================================================
-- CONSULTAS ÚTEIS
-- =========================================================

-- Listar todos os usuários ativos
-- SELECT id, usuario, nome_completo, perfil, municipio, escritorio_local, ativo 
-- FROM usuarios_formema WHERE ativo = 1;

-- Contar usuários por perfil
-- SELECT perfil, COUNT(*) as total 
-- FROM usuarios_formema WHERE ativo = 1 
-- GROUP BY perfil;

-- Atualizar senha de usuário
-- UPDATE usuarios_formema 
-- SET senha = 'NOVO_HASH_SHA256_AQUI' 
-- WHERE usuario = 'nome_usuario';

-- Desativar usuário (soft delete)
-- UPDATE usuarios_formema SET ativo = 0 WHERE usuario = 'nome_usuario';

-- =========================================================
-- FIM DO SCRIPT
-- =========================================================
