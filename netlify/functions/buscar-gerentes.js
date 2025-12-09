// Netlify Function: Buscar formulários de GERENTES
// Path: /.netlify/functions/buscar-gerentes.js

const sql = require('mssql');

// Configuração SQL Azure
const config = {
    server: 'srv-db-cxtce.database.windows.net',
    database: 'db-ematech',
    user: 'admin.dba',
    password: process.env.SQL_PASSWORD || 'A57458974x23*',
    options: {
        encrypt: true,
        trustServerCertificate: false,
        enableArithAbort: true,
        connectTimeout: 30000,
        requestTimeout: 30000
    },
    pool: {
        max: 10,
        min: 0,
        idleTimeoutMillis: 30000
    }
};

exports.handler = async function(event, context) {
    console.log('📥 Netlify Function: buscar-gerentes iniciada');
    
    // CORS headers
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
    };

    // Handle preflight
    if (event.httpMethod === 'OPTIONS') {
        return {
            statusCode: 200,
            headers,
            body: ''
        };
    }

    // Validar método
    if (event.httpMethod !== 'GET') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Método não permitido. Use GET.' })
        };
    }

    try {
        // Parse query parameters
        const params = event.queryStringParameters || {};
        const limite = parseInt(params.limite) || 100;
        const offset = parseInt(params.offset) || 0;
        const municipio = params.municipio;
        const protocolo = params.protocolo;

        console.log('🔍 Parâmetros de busca:', { limite, offset, municipio, protocolo });

        // Conectar ao banco
        console.log('🔌 Conectando ao SQL Azure...');
        const pool = await sql.connect(config);
        console.log('✅ Conectado ao banco de dados');

        let query = '';
        let whereClause = [];
        
        // Query específica por protocolo
        if (protocolo) {
            query = `
                SELECT TOP 1 *
                FROM formulario_gerentes
                WHERE protocolo = @protocolo
            `;
        } else {
            // Query geral com filtros
            if (municipio) {
                whereClause.push('municipio = @municipio');
            }

            const where = whereClause.length > 0 ? `WHERE ${whereClause.join(' AND ')}` : '';

            query = `
                SELECT *
                FROM formulario_gerentes
                ${where}
                ORDER BY created_at DESC
                OFFSET @offset ROWS
                FETCH NEXT @limite ROWS ONLY
            `;
        }

        const request = pool.request();
        
        // Adicionar parâmetros
        if (protocolo) {
            request.input('protocolo', sql.NVarChar(50), protocolo);
        } else {
            request.input('limite', sql.Int, limite);
            request.input('offset', sql.Int, offset);
            if (municipio) {
                request.input('municipio', sql.NVarChar(100), municipio);
            }
        }

        console.log('📊 Executando query...');
        const result = await request.query(query);
        
        // Buscar totais se não for busca por protocolo
        let total = 0;
        if (!protocolo) {
            const countQuery = municipio 
                ? 'SELECT COUNT(*) as total FROM formulario_gerentes WHERE municipio = @municipio'
                : 'SELECT COUNT(*) as total FROM formulario_gerentes';
            
            const countRequest = pool.request();
            if (municipio) {
                countRequest.input('municipio', sql.NVarChar(100), municipio);
            }
            
            const countResult = await countRequest.query(countQuery);
            total = countResult.recordset[0].total;
        }

        // Fechar conexão
        await pool.close();

        console.log(`✅ ${result.recordset.length} formulário(s) encontrado(s)`);

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                data: result.recordset,
                total: protocolo ? result.recordset.length : total,
                limite,
                offset
            })
        };

    } catch (error) {
        console.error('❌ Erro ao buscar formulários:', error);
        
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                success: false,
                error: error.message,
                stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
            })
        };
    }
};
