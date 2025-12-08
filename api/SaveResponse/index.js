const sql = require('mssql');

// Configuração do Azure SQL (use variáveis de ambiente)
const config = {
    user: process.env.SQL_USER,
    password: process.env.SQL_PASSWORD,
    server: process.env.SQL_SERVER, // ex: formema-server.database.windows.net
    database: process.env.SQL_DATABASE,
    options: {
        encrypt: true,
        enableArithAbort: true
    }
};

module.exports = async function (context, req) {
    // CORS headers
    context.res = {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type'
        }
    };

    // Handle preflight
    if (req.method === 'OPTIONS') {
        context.res.status = 200;
        return;
    }

    try {
        const data = req.body;

        // Validação básica
        if (!data.municipio || !data.tempoEmater) {
            context.res = {
                status: 400,
                body: { error: 'Campos obrigatórios faltando' }
            };
            return;
        }

        // Conectar ao SQL
        const pool = await sql.connect(config);

        // Gerar protocolo único
        const protocolo = `EMT-${Date.now()}-${Math.random().toString(36).substr(2, 9).toUpperCase()}`;
        const timestamp = new Date().toISOString();

        // Inserir dados principais
        const result = await pool.request()
            .input('protocolo', sql.VarChar(50), protocolo)
            .input('timestamp', sql.DateTime, timestamp)
            .input('municipio', sql.VarChar(100), data.municipio)
            .input('escritorioLocal', sql.VarChar(100), data.escritorioLocal)
            .input('tempoEmater', sql.VarChar(20), data.tempoEmater)
            .input('nomeCompleto', sql.VarChar(200), data.nomeCompleto || null)
            .input('dadosCompletos', sql.NVarChar(sql.MAX), JSON.stringify(data))
            .query(`
                INSERT INTO Respostas 
                (protocolo, timestamp, municipio, escritorioLocal, tempoEmater, nomeCompleto, dadosCompletos)
                VALUES 
                (@protocolo, @timestamp, @municipio, @escritorioLocal, @tempoEmater, @nomeCompleto, @dadosCompletos)
            `);

        // Inserir respostas detalhadas (opcional - para análise)
        await insertDetailedResponses(pool, protocolo, data);

        context.res = {
            status: 200,
            body: {
                success: true,
                protocolo: protocolo,
                message: 'Respostas salvas com sucesso!'
            }
        };

    } catch (error) {
        context.log.error('Erro ao salvar:', error);
        context.res = {
            status: 500,
            body: {
                error: 'Erro ao salvar respostas',
                details: error.message
            }
        };
    }
};

// Função auxiliar para inserir respostas detalhadas
async function insertDetailedResponses(pool, protocolo, data) {
    // Eixo A - Métodos
    if (data.metodosFrequentes) {
        const metodos = Array.isArray(data.metodosFrequentes) 
            ? data.metodosFrequentes 
            : [data.metodosFrequentes];
        
        for (const metodo of metodos) {
            await pool.request()
                .input('protocolo', sql.VarChar(50), protocolo)
                .input('categoria', sql.VarChar(50), 'metodosFrequentes')
                .input('valor', sql.VarChar(100), metodo)
                .query(`
                    INSERT INTO RespostasDetalhadas (protocolo, categoria, valor)
                    VALUES (@protocolo, @categoria, @valor)
                `);
        }
    }

    // Eixo A - Dificuldades (Likert)
    const dificuldades = [
        'dif_falta_tempo',
        'dif_num_tecnicos',
        'dif_distancia',
        'dif_baixa_adesao',
        'dif_lim_recursos',
        'dif_demandas_admin',
        'dif_estrutura_metas'
    ];

    for (const dif of dificuldades) {
        if (data[dif]) {
            await pool.request()
                .input('protocolo', sql.VarChar(50), protocolo)
                .input('categoria', sql.VarChar(50), dif)
                .input('valor', sql.Int, parseInt(data[dif]))
                .query(`
                    INSERT INTO RespostasDetalhadas (protocolo, categoria, valorNumerico)
                    VALUES (@protocolo, @categoria, @valor)
                `);
        }
    }

    // Continue para outros eixos conforme necessário...
}
