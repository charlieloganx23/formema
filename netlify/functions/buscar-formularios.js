const sql = require('mssql');

const config = {
    server: 'srv-db-cxtce.database.windows.net',
    database: 'db-ematech',
    user: 'admin.dba',
    password: process.env.SQL_PASSWORD || 'A57458974x23*',
    options: {
        encrypt: true,
        trustServerCertificate: false
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

exports.handler = async (event, context) => {
    // CORS headers
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Access-Control-Allow-Methods': 'GET, OPTIONS'
    };

    // Handle preflight
    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers, body: '' };
    }

    if (event.httpMethod !== 'GET') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }

    try {
        const params = event.queryStringParameters || {};
        const protocolo = params.protocolo;
        const municipio = params.municipio;
        const limite = parseInt(params.limite) || 100;
        const offset = parseInt(params.offset) || 0;

        const pool = await sql.connect(config);

        let query = 'SELECT * FROM formulario_extensionista WHERE 1=1';
        const request = pool.request();

        if (protocolo) {
            query += ' AND protocolo = @protocolo';
            request.input('protocolo', sql.NVarChar, protocolo);
        }

        if (municipio) {
            query += ' AND municipio = @municipio';
            request.input('municipio', sql.NVarChar, municipio);
        }

        query += ' ORDER BY timestamp_inicio DESC';
        query += ' OFFSET @offset ROWS FETCH NEXT @limite ROWS ONLY';

        request.input('offset', sql.Int, offset);
        request.input('limite', sql.Int, limite);

        const result = await request.query(query);

        // Parse JSON fields
        const formularios = result.recordset.map(row => ({
            ...row,
            respostas: row.respostas ? JSON.parse(row.respostas) : null,
            fotos: row.fotos ? JSON.parse(row.fotos) : []
        }));

        // Buscar estatísticas
        const statsResult = await pool.request().query('SELECT * FROM vw_estatisticas');
        const estatisticas = statsResult.recordset[0] || {};

        await pool.close();

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                total: formularios.length,
                formularios: formularios,
                estatisticas: estatisticas
            })
        };

    } catch (error) {
        console.error('Erro:', error);
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                success: false,
                error: error.message
            })
        };
    }
};
