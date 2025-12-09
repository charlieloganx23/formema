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
        console.log('📝 Recebido formulário:', formulario.protocolo);
        
        // Conectar ao SQL Azure
        console.log('🔌 Conectando ao SQL Azure...');
        const pool = await sql.connect(config);
        console.log('✅ Conectado ao SQL Azure');

        // Extrair protocolo
        const protocolo = formulario.protocolo;
        
        // Suportar dois formatos:
        // 1. Estruturado: {respostas: {...}, fotos: [], geolocalizacao: {}}
        // 2. Flat: {municipio: "...", latitude: ..., ...} (dados soltos no root)
        
        let respostas, fotos, geolocalizacao, municipio, unidade_emater, territorio, identificador_iniciais;
        let latitude, longitude, precisao, geo_erro, timestampInicio, timestampFim, duracaoMinutos, status;
        
        // Novos campos do Eixo A - Métodos de ATER
        let metodosFrequentes, metodosFrequentesOutro, metodosMelhoresResultados, metodosMelhoresResultadosOutro;
        let dificuldadeFaltaTempo, dificuldadeNumTecnicos, dificuldadeDistancia, dificuldadeBaixaAdesao;
        let dificuldadeRecursos, dificuldadeDemandasAdmin, dificuldadeMetas, comentarioEixoA;
        
        // Novos campos do Eixo B - Critérios de Priorização e Equidade
        let priorizacaoAtendimentos, priorizacaoAtendimentosOutro, nivelEquidade;
        let instrumentosFormais, exemploInstrumentoFormal, comentarioEixoB;
        
        // Novos campos do Eixo E - Indicadores e Avaliação
        let instrumentosAcompanhamento, instrumentosAcompanhamentoOutro, freqUsoIndicadores;
        let principaisIndicadores, avaliacaoAjudaIndicadores, comentarioEixoE, comentarioFinal;


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
            
            // Extrair novos campos do Eixo A
            metodosFrequentes = respostas.metodosFrequentes ? JSON.stringify(respostas.metodosFrequentes) : null;
            metodosFrequentesOutro = respostas.metodosFrequentesOutro || null;
            metodosMelhoresResultados = respostas.metodosMelhoresResultados ? JSON.stringify(respostas.metodosMelhoresResultados) : null;
            metodosMelhoresResultadosOutro = respostas.metodosMelhoresResultadosOutro || null;
            dificuldadeFaltaTempo = respostas.dificuldade_falta_tempo ? parseInt(respostas.dificuldade_falta_tempo) : null;
            dificuldadeNumTecnicos = respostas.dificuldade_num_tecnicos ? parseInt(respostas.dificuldade_num_tecnicos) : null;
            dificuldadeDistancia = respostas.dificuldade_distancia ? parseInt(respostas.dificuldade_distancia) : null;
            dificuldadeBaixaAdesao = respostas.dificuldade_baixa_adesao ? parseInt(respostas.dificuldade_baixa_adesao) : null;
            dificuldadeRecursos = respostas.dificuldade_recursos ? parseInt(respostas.dificuldade_recursos) : null;
            dificuldadeDemandasAdmin = respostas.dificuldade_demandas_admin ? parseInt(respostas.dificuldade_demandas_admin) : null;
            dificuldadeMetas = respostas.dificuldade_metas ? parseInt(respostas.dificuldade_metas) : null;
            comentarioEixoA = respostas.comentario_eixo_a || null;
            
            // Extrair novos campos do Eixo B
            priorizacaoAtendimentos = respostas.priorizacao_atendimentos ? 
                (Array.isArray(respostas.priorizacao_atendimentos) ? JSON.stringify(respostas.priorizacao_atendimentos) : respostas.priorizacao_atendimentos) : null;
            priorizacaoAtendimentosOutro = respostas.priorizacao_atendimentos_outro || null;
            nivelEquidade = respostas.nivel_equidade ? parseInt(respostas.nivel_equidade) : null;
            instrumentosFormais = respostas.instrumentos_formais || null;
            exemploInstrumentoFormal = respostas.exemplo_instrumento_formal || null;
            comentarioEixoB = respostas.comentario_eixo_b || null;
            
            // Extrair novos campos do Eixo E
            instrumentosAcompanhamento = respostas.instrumentos_acompanhamento ? 
                (Array.isArray(respostas.instrumentos_acompanhamento) ? JSON.stringify(respostas.instrumentos_acompanhamento) : respostas.instrumentos_acompanhamento) : null;
            instrumentosAcompanhamentoOutro = respostas.instrumentos_acompanhamento_outro || null;
            freqUsoIndicadores = respostas.freq_uso_indicadores || null;
            principaisIndicadores = respostas.principais_indicadores || null;
            avaliacaoAjudaIndicadores = respostas.avaliacao_ajuda_indicadores ? parseInt(respostas.avaliacao_ajuda_indicadores) : null;
            comentarioEixoE = respostas.comentario_eixo_e || null;
            comentarioFinal = respostas.comentario_final || null;
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
            
            // Extrair novos campos do Eixo A (formato flat)
            metodosFrequentes = formulario.metodosFrequentes ? JSON.stringify(formulario.metodosFrequentes) : null;
            metodosFrequentesOutro = formulario.metodosFrequentesOutro || null;
            metodosMelhoresResultados = formulario.metodosMelhoresResultados ? JSON.stringify(formulario.metodosMelhoresResultados) : null;
            metodosMelhoresResultadosOutro = formulario.metodosMelhoresResultadosOutro || null;
            dificuldadeFaltaTempo = formulario.dificuldade_falta_tempo ? parseInt(formulario.dificuldade_falta_tempo) : null;
            dificuldadeNumTecnicos = formulario.dificuldade_num_tecnicos ? parseInt(formulario.dificuldade_num_tecnicos) : null;
            dificuldadeDistancia = formulario.dificuldade_distancia ? parseInt(formulario.dificuldade_distancia) : null;
            dificuldadeBaixaAdesao = formulario.dificuldade_baixa_adesao ? parseInt(formulario.dificuldade_baixa_adesao) : null;
            dificuldadeRecursos = formulario.dificuldade_recursos ? parseInt(formulario.dificuldade_recursos) : null;
            dificuldadeDemandasAdmin = formulario.dificuldade_demandas_admin ? parseInt(formulario.dificuldade_demandas_admin) : null;
            dificuldadeMetas = formulario.dificuldade_metas ? parseInt(formulario.dificuldade_metas) : null;
            comentarioEixoA = formulario.comentario_eixo_a || null;
            
            // Extrair novos campos do Eixo B (formato flat)
            priorizacaoAtendimentos = formulario.priorizacao_atendimentos ? 
                (Array.isArray(formulario.priorizacao_atendimentos) ? JSON.stringify(formulario.priorizacao_atendimentos) : formulario.priorizacao_atendimentos) : null;
            priorizacaoAtendimentosOutro = formulario.priorizacao_atendimentos_outro || null;
            nivelEquidade = formulario.nivel_equidade ? parseInt(formulario.nivel_equidade) : null;
            instrumentosFormais = formulario.instrumentos_formais || null;
            exemploInstrumentoFormal = formulario.exemplo_instrumento_formal || null;
            comentarioEixoB = formulario.comentario_eixo_b || null;
            
            // Extrair novos campos do Eixo E (formato flat)
            instrumentosAcompanhamento = formulario.instrumentos_acompanhamento ? 
                (Array.isArray(formulario.instrumentos_acompanhamento) ? JSON.stringify(formulario.instrumentos_acompanhamento) : formulario.instrumentos_acompanhamento) : null;
            instrumentosAcompanhamentoOutro = formulario.instrumentos_acompanhamento_outro || null;
            freqUsoIndicadores = formulario.freq_uso_indicadores || null;
            principaisIndicadores = formulario.principais_indicadores || null;
            avaliacaoAjudaIndicadores = formulario.avaliacao_ajuda_indicadores ? parseInt(formulario.avaliacao_ajuda_indicadores) : null;
            comentarioEixoE = formulario.comentario_eixo_e || null;
            comentarioFinal = formulario.comentario_final || null;
        }

        console.log('🔍 Verificando se formulário já existe:', protocolo);
        
        // Verificar se já existe
        const checkResult = await pool.request()
            .input('protocolo', sql.NVarChar, protocolo)
            .query('SELECT protocolo FROM formulario_extensionista WHERE protocolo = @protocolo');

        if (checkResult.recordset.length > 0) {
            console.log('🔄 Atualizando formulário existente');
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
                .input('metodos_frequentes', sql.NVarChar(sql.MAX), metodosFrequentes)
                .input('metodos_frequentes_outro', sql.NVarChar(500), metodosFrequentesOutro)
                .input('metodos_melhores_resultados', sql.NVarChar(sql.MAX), metodosMelhoresResultados)
                .input('metodos_melhores_resultados_outro', sql.NVarChar(500), metodosMelhoresResultadosOutro)
                .input('dificuldade_falta_tempo', sql.Int, dificuldadeFaltaTempo)
                .input('dificuldade_num_tecnicos', sql.Int, dificuldadeNumTecnicos)
                .input('dificuldade_distancia', sql.Int, dificuldadeDistancia)
                .input('dificuldade_baixa_adesao', sql.Int, dificuldadeBaixaAdesao)
                .input('dificuldade_recursos', sql.Int, dificuldadeRecursos)
                .input('dificuldade_demandas_admin', sql.Int, dificuldadeDemandasAdmin)
                .input('dificuldade_metas', sql.Int, dificuldadeMetas)
                .input('comentario_eixo_a', sql.NVarChar(sql.MAX), comentarioEixoA)
                .input('priorizacao_atendimentos', sql.NVarChar(sql.MAX), priorizacaoAtendimentos)
                .input('priorizacao_atendimentos_outro', sql.NVarChar(500), priorizacaoAtendimentosOutro)
                .input('nivel_equidade', sql.Int, nivelEquidade)
                .input('instrumentos_formais', sql.NVarChar(100), instrumentosFormais)
                .input('exemplo_instrumento_formal', sql.NVarChar(sql.MAX), exemploInstrumentoFormal)
                .input('comentario_eixo_b', sql.NVarChar(sql.MAX), comentarioEixoB)
                .input('instrumentos_acompanhamento', sql.NVarChar(sql.MAX), instrumentosAcompanhamento)
                .input('instrumentos_acompanhamento_outro', sql.NVarChar(500), instrumentosAcompanhamentoOutro)
                .input('freq_uso_indicadores', sql.NVarChar(50), freqUsoIndicadores)
                .input('principais_indicadores', sql.NVarChar(sql.MAX), principaisIndicadores)
                .input('avaliacao_ajuda_indicadores', sql.Int, avaliacaoAjudaIndicadores)
                .input('comentario_eixo_e', sql.NVarChar(sql.MAX), comentarioEixoE)
                .input('comentario_final', sql.NVarChar(sql.MAX), comentarioFinal)
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
                        metodos_frequentes = @metodos_frequentes,
                        metodos_frequentes_outro = @metodos_frequentes_outro,
                        metodos_melhores_resultados = @metodos_melhores_resultados,
                        metodos_melhores_resultados_outro = @metodos_melhores_resultados_outro,
                        dificuldade_falta_tempo = @dificuldade_falta_tempo,
                        dificuldade_num_tecnicos = @dificuldade_num_tecnicos,
                        dificuldade_distancia = @dificuldade_distancia,
                        dificuldade_baixa_adesao = @dificuldade_baixa_adesao,
                        dificuldade_recursos = @dificuldade_recursos,
                        dificuldade_demandas_admin = @dificuldade_demandas_admin,
                        dificuldade_metas = @dificuldade_metas,
                        comentario_eixo_a = @comentario_eixo_a,
                        priorizacao_atendimentos = @priorizacao_atendimentos,
                        priorizacao_atendimentos_outro = @priorizacao_atendimentos_outro,
                        nivel_equidade = @nivel_equidade,
                        instrumentos_formais = @instrumentos_formais,
                        exemplo_instrumento_formal = @exemplo_instrumento_formal,
                        comentario_eixo_b = @comentario_eixo_b,
                        instrumentos_acompanhamento = @instrumentos_acompanhamento,
                        instrumentos_acompanhamento_outro = @instrumentos_acompanhamento_outro,
                        freq_uso_indicadores = @freq_uso_indicadores,
                        principais_indicadores = @principais_indicadores,
                        avaliacao_ajuda_indicadores = @avaliacao_ajuda_indicadores,
                        comentario_eixo_e = @comentario_eixo_e,
                        comentario_final = @comentario_final,
                        updated_at = GETUTCDATE()
                    WHERE protocolo = @protocolo
                `);
            console.log('✅ Formulário atualizado com sucesso');
        } else {
            console.log('➕ Inserindo novo formulário');
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
                .input('metodos_frequentes', sql.NVarChar(sql.MAX), metodosFrequentes)
                .input('metodos_frequentes_outro', sql.NVarChar(500), metodosFrequentesOutro)
                .input('metodos_melhores_resultados', sql.NVarChar(sql.MAX), metodosMelhoresResultados)
                .input('metodos_melhores_resultados_outro', sql.NVarChar(500), metodosMelhoresResultadosOutro)
                .input('dificuldade_falta_tempo', sql.Int, dificuldadeFaltaTempo)
                .input('dificuldade_num_tecnicos', sql.Int, dificuldadeNumTecnicos)
                .input('dificuldade_distancia', sql.Int, dificuldadeDistancia)
                .input('dificuldade_baixa_adesao', sql.Int, dificuldadeBaixaAdesao)
                .input('dificuldade_recursos', sql.Int, dificuldadeRecursos)
                .input('dificuldade_demandas_admin', sql.Int, dificuldadeDemandasAdmin)
                .input('dificuldade_metas', sql.Int, dificuldadeMetas)
                .input('comentario_eixo_a', sql.NVarChar(sql.MAX), comentarioEixoA)
                .input('priorizacao_atendimentos', sql.NVarChar(sql.MAX), priorizacaoAtendimentos)
                .input('priorizacao_atendimentos_outro', sql.NVarChar(500), priorizacaoAtendimentosOutro)
                .input('nivel_equidade', sql.Int, nivelEquidade)
                .input('instrumentos_formais', sql.NVarChar(100), instrumentosFormais)
                .input('exemplo_instrumento_formal', sql.NVarChar(sql.MAX), exemploInstrumentoFormal)
                .input('comentario_eixo_b', sql.NVarChar(sql.MAX), comentarioEixoB)
                .input('instrumentos_acompanhamento', sql.NVarChar(sql.MAX), instrumentosAcompanhamento)
                .input('instrumentos_acompanhamento_outro', sql.NVarChar(500), instrumentosAcompanhamentoOutro)
                .input('freq_uso_indicadores', sql.NVarChar(50), freqUsoIndicadores)
                .input('principais_indicadores', sql.NVarChar(sql.MAX), principaisIndicadores)
                .input('avaliacao_ajuda_indicadores', sql.Int, avaliacaoAjudaIndicadores)
                .input('comentario_eixo_e', sql.NVarChar(sql.MAX), comentarioEixoE)
                .input('comentario_final', sql.NVarChar(sql.MAX), comentarioFinal)
                .query(`
                    INSERT INTO formulario_extensionista (
                        protocolo, municipio, unidade_emater, territorio,
                        identificador_iniciais, timestamp_inicio, timestamp_fim,
                        duracao_minutos, latitude, longitude, precisao, geo_erro,
                        status, respostas, fotos,
                        metodos_frequentes, metodos_frequentes_outro,
                        metodos_melhores_resultados, metodos_melhores_resultados_outro,
                        dificuldade_falta_tempo, dificuldade_num_tecnicos,
                        dificuldade_distancia, dificuldade_baixa_adesao,
                        dificuldade_recursos, dificuldade_demandas_admin,
                        dificuldade_metas, comentario_eixo_a,
                        priorizacao_atendimentos, priorizacao_atendimentos_outro,
                        nivel_equidade, instrumentos_formais,
                        exemplo_instrumento_formal, comentario_eixo_b,
                        instrumentos_acompanhamento, instrumentos_acompanhamento_outro,
                        freq_uso_indicadores, principais_indicadores,
                        avaliacao_ajuda_indicadores, comentario_eixo_e, comentario_final
                    ) VALUES (
                        @protocolo, @municipio, @unidade_emater, @territorio,
                        @identificador_iniciais, @timestamp_inicio, @timestamp_fim,
                        @duracao_minutos, @latitude, @longitude, @precisao, @geo_erro,
                        @status, @respostas, @fotos,
                        @metodos_frequentes, @metodos_frequentes_outro,
                        @metodos_melhores_resultados, @metodos_melhores_resultados_outro,
                        @dificuldade_falta_tempo, @dificuldade_num_tecnicos,
                        @dificuldade_distancia, @dificuldade_baixa_adesao,
                        @dificuldade_recursos, @dificuldade_demandas_admin,
                        @dificuldade_metas, @comentario_eixo_a,
                        @priorizacao_atendimentos, @priorizacao_atendimentos_outro,
                        @nivel_equidade, @instrumentos_formais,
                        @exemplo_instrumento_formal, @comentario_eixo_b,
                        @instrumentos_acompanhamento, @instrumentos_acompanhamento_outro,
                        @freq_uso_indicadores, @principais_indicadores,
                        @avaliacao_ajuda_indicadores, @comentario_eixo_e, @comentario_final
                    )
                `);
            console.log('✅ Formulário inserido com sucesso');
        }

        console.log('🔒 Fechando conexão SQL');
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
        console.error('❌ Erro detalhado:', {
            message: error.message,
            stack: error.stack,
            name: error.name,
            code: error.code,
            number: error.number,
            state: error.state,
            class: error.class,
            serverName: error.serverName,
            procName: error.procName,
            lineNumber: error.lineNumber
        });
        return {
            statusCode: 500,
            headers,
            body: JSON.stringify({
                success: false,
                error: error.message,
                details: error.code || error.number || 'Erro desconhecido',
                timestamp: new Date().toISOString()
            })
        };
    }
};
