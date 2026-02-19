const crypto = require('crypto');

function gerarHash(senha) {
    return crypto.createHash('sha256').update(senha).digest('hex');
}

console.log('=== Gerando Hashes SHA-256 ===\n');

console.log('ext123:', gerarHash('ext123'));
console.log('senha123:', gerarHash('senha123'));
console.log('admin123:', gerarHash('admin123'));

console.log('\n=== SQL UPDATE ===\n');

const hashExt123 = gerarHash('ext123');

console.log(`-- Atualizar usuário extensionista
UPDATE usuarios_formema 
SET usuario = 'extensionista', 
    senha = '${hashExt123}',
    nome_completo = 'Extensionista Teste'
WHERE id = 2;`);
