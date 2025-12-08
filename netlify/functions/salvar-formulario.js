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
        'Access-Control-Allow-Methods': 'POST, OPTIONS'
    };

    // Handle preflight
    if (event.httpMethod === 'OPTIONS') {
        return { statusCode: 200, headers, body: '' };
    }

    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Method not allowed' })
        };
    }

    try {
        const formulario = JSON.parse(event.body);
        
        // Conectar ao SQL Azure
        const pool = await sql.connect(config);

        // Extrair protocolo
        const protocolo = formulario.protocolo;
        
        // Suportar dois formatos:
        // 1. Estruturado: {respostas: {...}, fotos: [], geolocalizacao: {}}
        // 2. Flat: {municipio: "...", latitude: ..., ...} (dados soltos no root)
        
        let respostas, fotos, geolocalizacao, municipio, unidade_emater, territorio, identificador_iniciais;
        let latitude, longitude, precisao, geo_erro, timestampInicio, timestampFim, duracaoMinutos, status;

        if (formulario.respostas) {
            // Formato estruturado
            respostas = formulario.respostas;
            fotos = formulario.fotos || [];
            geolocalizacao = formulario.geolocalizacao || {};
            status = formulario.status || 'completo';
            
            municipio = respostas.municipio || null;
            unidade_emater = respostas.unidade_emater || null;
            territorio = respostas.territorio || null;
            identificador_iniciais = respostas.identificador_iniciais || null;
            
            latitude = geolocalizacao.latitude || null;
            longitude = geolocalizacao.longitude || null;
            precisao = geolocalizacao.precisao || null;
            geo_erro = geolocalizacao.erro || null;
            
            timestampInicio = formulario.timestampInicio || formulario.timestamp_inicio;
            timestampFim = formulario.timestampFim || formulario.timestamp_fim;
            duracaoMinutos = formulario.duracaoMinutos || formulario.duracao_minutos || 0;
        } else {
            // Formato flat (IndexedDB antigo)
            respostas = { ...formulario }; // Usar o objeto inteiro como respostas
            fotos = [];
            geolocalizacao = {};
            
            municipio = formulario.municipio || null;
            unidade_emater = formulario.unidade_emater || formulario.escritorioLocal || null;
            territorio = formulario.territorio || null;
            identificador_iniciais = formulario.identificador_iniciais || formulario.nomeCompleto || null;
            
            latitude = formulario.latitude || null;
            longitude = formulario.longitude || null;
            precisao = formulario.precisao || null;
            geo_erro = formulario.geo_erro || null;
            
            timestampInicio = formulario.timestamp_inicio || formulario.timestamp;
            timestampFim = formulario.timestamp_fim;
            duracaoMinutos = formulario.duracao_minutos || 0;
            status = formulario.status || 'completo';
        }

        // Verificar se já existe
        const checkResult = await pool.request()
            .input('protocolo', sql.NVarChar, protocolo)
            .query('SELECT protocolo FROM formulario_extensionista WHERE protocolo = @protocolo');

        if (checkResult.recordset.length > 0) {
            // Atualizar
            await pool.request()
                .input('protocolo', sql.NVarChar(50), protocolo)
                .input('municipio', sql.NVarChar(100), municipio)
                .input('unidade_emater', sql.NVarChar(100), unidade_emater)
                .input('territorio', sql.NVarChar(100), territorio)
                .input('identificador_iniciais', sql.NVarChar(10), identificador_iniciais)
                .input('timestamp_inicio', sql.DateTime2, timestampInicio)
                .input('timestamp_fim', sql.DateTime2, timestampFim)
                .input('duracao_minutos', sql.Int, duracaoMinutos)
                .input('latitude', sql.Decimal(10, 8), latitude)
                .input('longitude', sql.Decimal(11, 8), longitude)
                .input('precisao', sql.Decimal(10, 2), precisao)
                .input('geo_erro', sql.NVarChar(500), geo_erro)
                .input('status', sql.NVarChar(20), status || 'completo')
                .input('respostas', sql.NVarChar(sql.MAX), JSON.stringify(respostas))
                .input('fotos', sql.NVarChar(sql.MAX), JSON.stringify(fotos || []))
                .query(`
                    UPDATE formulario_extensionista SET
                        municipio = @municipio,
                        unidade_emater = @unidade_emater,
                        territorio = @territorio,
                        identificador_iniciais = @identificador_iniciais,
                        timestamp_inicio = @timestamp_inicio,
                        timestamp_fim = @timestamp_fim,
                        duracao_minutos = @duracao_minutos,
                        latitude = @latitude,
                        longitude = @longitude,
                        precisao = @precisao,
                        geo_erro = @geo_erro,
                        status = @status,
                        respostas = @respostas,
                        fotos = @fotos,
                        updated_at = GETUTCDATE()
                    WHERE protocolo = @protocolo
                `);
        } else {
            // Inserir
            await pool.request()
                .input('protocolo', sql.NVarChar(50), protocolo)
                .input('municipio', sql.NVarChar(100), municipio)
                .input('unidade_emater', sql.NVarChar(100), unidade_emater)
                .input('territorio', sql.NVarChar(100), territorio)
                .input('identificador_iniciais', sql.NVarChar(10), identificador_iniciais)
                .input('timestamp_inicio', sql.DateTime2, timestampInicio)
                .input('timestamp_fim', sql.DateTime2, timestampFim)
                .input('duracao_minutos', sql.Int, duracaoMinutos)
                .input('latitude', sql.Decimal(10, 8), latitude)
                .input('longitude', sql.Decimal(11, 8), longitude)
                .input('precisao', sql.Decimal(10, 2), precisao)
                .input('geo_erro', sql.NVarChar(500), geo_erro)
                .input('status', sql.NVarChar(20), status || 'completo')
                .input('respostas', sql.NVarChar(sql.MAX), JSON.stringify(respostas))
                .input('fotos', sql.NVarChar(sql.MAX), JSON.stringify(fotos || []))
                .query(`
                    INSERT INTO formulario_extensionista (
                        protocolo, municipio, unidade_emater, territorio,
                        identificador_iniciais, timestamp_inicio, timestamp_fim,
                        duracao_minutos, latitude, longitude, precisao, geo_erro,
                        status, respostas, fotos
                    ) VALUES (
                        @protocolo, @municipio, @unidade_emater, @territorio,
                        @identificador_iniciais, @timestamp_inicio, @timestamp_fim,
                        @duracao_minutos, @latitude, @longitude, @precisao, @geo_erro,
                        @status, @respostas, @fotos
                    )
                `);
        }

        await pool.close();

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                protocolo: protocolo,
                message: 'Formulário salvo com sucesso'
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
