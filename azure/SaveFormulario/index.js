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
    context.log('Azure Function: Salvando formulário...');

    // CORS headers
    context.res = {
        headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST, OPTIONS',
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
        const formulario = req.body;

        if (!formulario || !formulario.protocolo) {
            context.res.status = 400;
            context.res.body = {
                success: false,
                error: 'Dados inválidos: protocolo é obrigatório'
            };
            return;
        }

        // Conectar ao SQL Azure
        const pool = await sql.connect(config);

        // Extrair dados do formulário
        const {
            protocolo,
            respostas,
            fotos,
            geolocalizacao,
            timestampInicio,
            timestampFim,
            duracaoMinutos,
            status
        } = formulario;

        const municipio = respostas?.municipio || null;
        const unidade_emater = respostas?.unidade_emater || null;
        const territorio = respostas?.territorio || null;
        const identificador_iniciais = respostas?.identificador_iniciais || null;

        // Geolocalização
        const geo = geolocalizacao || {};
        const latitude = geo.latitude || null;
        const longitude = geo.longitude || null;
        const precisao = geo.precisao || null;
        const geo_erro = geo.erro || null;

        // Verificar se já existe
        const checkResult = await pool.request()
            .input('protocolo', sql.NVarChar(50), protocolo)
            .query('SELECT id FROM formularios WHERE protocolo = @protocolo');

        let result;
        if (checkResult.recordset.length > 0) {
            // Atualizar existente
            result = await pool.request()
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
                    UPDATE formularios SET
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

            context.log(`✅ Formulário ${protocolo} atualizado`);
        } else {
            // Inserir novo
            result = await pool.request()
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
                    INSERT INTO formularios (
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

            context.log(`✅ Formulário ${protocolo} inserido`);
        }

        context.res.status = 200;
        context.res.body = {
            success: true,
            protocolo: protocolo,
            message: 'Formulário salvo com sucesso'
        };

    } catch (error) {
        context.log.error('❌ Erro ao salvar formulário:', error);
        context.res.status = 500;
        context.res.body = {
            success: false,
            error: error.message
        };
    }
};
