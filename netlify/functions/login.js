const sql = require('mssql');
const crypto = require('crypto');

// ========== CONFIGURAÇÃO DO BANCO DE DADOS ==========
const config = {
    server: process.env.AZURE_SQL_SERVER || 'seu-servidor.database.windows.net',
    database: process.env.AZURE_SQL_DATABASE || 'seu-banco',
    user: process.env.AZURE_SQL_USER,
    password: process.env.AZURE_SQL_PASSWORD,
    options: {
        encrypt: true,
        trustServerCertificate: false,
        enableArithAbort: true
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    },
    connectionTimeout: 30000,
    requestTimeout: 30000
};

// Log de configuração (sem senha)
console.log('🔧 Configuração SQL:', {
    server: config.server,
    database: config.database,
    user: config.user,
    hasPassword: !!config.password
});

// ========== HANDLER PRINCIPAL ==========
exports.handler = async (event, context) => {
    // Headers CORS
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Content-Type': 'application/json; charset=utf-8'
    };

    // Responder OPTIONS para CORS preflight
    if (event.httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers,
            body: ''
        };
    }

    // Aceitar apenas POST
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ 
                sucesso: false, 
                mensagem: 'Método não permitido. Use POST.' 
            })
        };
    }

    let pool;
    
    try {
        // Parsear dados recebidos
        const dados = JSON.parse(event.body);
        const { usuario, senha } = dados;

        // Validar campos obrigatórios
        if (!usuario || !senha) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ 
                    sucesso: false, 
                    mensagem: 'Usuário e senha são obrigatórios.' 
                })
            };
        }

        console.log(`🔐 Tentativa de login: ${usuario}`);

        // Conectar ao Azure SQL
        pool = await sql.connect(config);
        console.log('✅ Conectado ao banco de dados');

        // Buscar usuário no banco
        const result = await pool.request()
            .input('usuario', sql.NVarChar, usuario)
            .query(`
                SELECT 
                    id, 
                    usuario, 
                    senha, 
                    nome_completo, 
                    email, 
                    perfil, 
                    municipio,
                    escritorio_local,
                    ativo
                FROM usuarios_formema 
                WHERE usuario = @usuario AND ativo = 1
            `);

        // Verificar se usuário existe
        if (result.recordset.length === 0) {
            console.log(`❌ Usuário não encontrado: ${usuario}`);
            return {
                statusCode: 401,
                headers,
                body: JSON.stringify({ 
                    sucesso: false, 
                    mensagem: 'Usuário ou senha inválidos.' 
                })
            };
        }

        const usuarioData = result.recordset[0];

        // Verificar senha (hash já vem do frontend)
        if (usuarioData.senha !== senha) {
            console.log(`❌ Senha incorreta para: ${usuario}`);
            return {
                statusCode: 401,
                headers,
                body: JSON.stringify({ 
                    sucesso: false, 
                    mensagem: 'Usuário ou senha inválidos.' 
                })
            };
        }

        console.log(`✅ Login bem-sucedido: ${usuario} (${usuarioData.perfil})`);

        // Atualizar data do último acesso
        await pool.request()
            .input('id', sql.Int, usuarioData.id)
            .query('UPDATE usuarios_formema SET data_ultimo_acesso = GETDATE() WHERE id = @id');

        // Gerar token de sessão (aleatório de 32 bytes)
        const token = crypto.randomBytes(32).toString('hex');

        // Retornar dados do usuário (sem a senha)
        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                sucesso: true,
                mensagem: 'Login realizado com sucesso!',
                token: token,
                usuario: {
                    id: usuarioData.id,
                    usuario: usuarioData.usuario,
                    nome_completo: usuarioData.nome_completo,
                    email: usuarioData.email,
                    perfil: usuarioData.perfil,
                    municipio: usuarioData.municipio,
                    escritorio_local: usuarioData.escritorio_local
                }
            })
        };

    } catch (error) {
        console.error('❌ Erro no login:', error);
        console.error('Código do erro:', error.code);
        console.error('Mensagem:', error.message);
        
        // Mensagens específicas por tipo de erro
        let mensagem = 'Erro interno do servidor.';
        let statusCode = 500;
        
        if (error.code === 'ELOGIN') {
            mensagem = 'Falha na autenticação com o banco de dados. Verifique as credenciais.';
            statusCode = 503;
        } else if (error.code === 'ETIMEOUT') {
            mensagem = 'Timeout ao conectar com o banco. Verifique o firewall do Azure SQL.';
            statusCode = 503;
        } else if (error.code === 'ESOCKET') {
            mensagem = 'Não foi possível conectar ao servidor de banco de dados. Verifique o firewall.';
            statusCode = 503;
        } else if (error.message && error.message.includes('firewall')) {
            mensagem = 'Conexão bloqueada pelo firewall do Azure SQL. Libere o acesso aos serviços do Azure.';
            statusCode = 503;
        } else if (!config.server || !config.database || !config.user || !config.password) {
            mensagem = 'Variáveis de ambiente do banco não configuradas corretamente.';
            statusCode = 500;
        }

        return {
            statusCode: statusCode,
            headers,
            body: JSON.stringify({
                sucesso: false,
                mensagem: mensagem,
                detalhes: error.message,
                codigo: error.code
            })
        };
        
    } finally {
        // Fechar conexão com o banco
        if (pool) {
            try {
                await pool.close();
                console.log('🔌 Conexão com o banco encerrada');
            } catch (closeError) {
                console.error('❌ Erro ao fechar conexão:', closeError);
            }
        }
    }
};
