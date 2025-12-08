const sql = require('mssql');

// Configuração do SQL Azure
const config = {
    server: 'srv-db-cxtce.database.windows.net',
    database: 'db-ematech',
    user: 'admin.dba',
    password: process.env.SQL_PASSWORD || 'A57458974x23*',
    options: {
        encrypt: true,
        trustServerCertificate: false,
        enableArithAbort: true
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

module.exports = async function (context, req) {
    context.log('Azure Function: Buscando formulários...');

    // CORS headers
    context.res = {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Content-Type': 'application/json'
        }
    };

    // Handle preflight
    if (req.method === 'OPTIONS') {
        context.res.status = 200;
        return;
    }

    try {
        // Conectar ao SQL Azure
        const pool = await sql.connect(config);

        // Parâmetros de query
        const protocolo = req.query.protocolo;
        const municipio = req.query.municipio;
        const limite = parseInt(req.query.limite) || 100;
        const offset = parseInt(req.query.offset) || 0;

        let query = 'SELECT * FROM formulario_extensionista WHERE 1=1';
        const request = pool.request();

        // Filtros opcionais
        if (protocolo) {
            query += ' AND protocolo = @protocolo';
            request.input('protocolo', sql.NVarChar(50), protocolo);
        }

        if (municipio) {
            query += ' AND municipio = @municipio';
            request.input('municipio', sql.NVarChar(100), municipio);
        }

        // Ordenação e paginação
        query += ' ORDER BY timestamp_fim DESC';
        query += ' OFFSET @offset ROWS FETCH NEXT @limite ROWS ONLY';
        
        request.input('offset', sql.Int, offset);
        request.input('limite', sql.Int, limite);

        const result = await pool.request(query);

        // Processar resultados (converter JSON strings)
        const formularios = result.recordset.map(row => ({
            ...row,
            respostas: row.respostas ? JSON.parse(row.respostas) : {},
            fotos: row.fotos ? JSON.parse(row.fotos) : [],
            geolocalizacao: {
                latitude: row.latitude,
                longitude: row.longitude,
                precisao: row.precisao,
                erro: row.geo_erro
            }
        }));

        // Buscar estatísticas
        const statsResult = await pool.request()
            .query('SELECT * FROM vw_estatisticas');

        context.res.status = 200;
        context.res.body = {
            success: true,
            total: formularios.length,
            formularios: formularios,
            estatisticas: statsResult.recordset[0] || {}
        };

        context.log(`✅ Retornados ${formularios.length} formulários`);

    } catch (error) {
        context.log.error('❌ Erro ao buscar formulários:', error);
        context.res.status = 500;
        context.res.body = {
            success: false,
            error: error.message
        };
    }
};
