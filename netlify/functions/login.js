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
        
        // Se for erro de conexão com o banco
        if (error.code === 'ELOGIN' || error.code === 'ETIMEOUT') {
            return {
                statusCode: 503,
                headers,
                body: JSON.stringify({
                    sucesso: false,
                    mensagem: 'Erro ao conectar com o banco de dados.',
                    erro: error.message
                })
            };
        }

        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                sucesso: false,
                mensagem: 'Erro interno do servidor.',
                erro: error.message
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
