// Netlify Function: Salvar formulário de GERENTES
// Path: /.netlify/functions/salvar-gerentes.js

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
    console.log('📥 Netlify Function: salvar-gerentes iniciada');
    
    // CORS headers
    const headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
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
    if (event.httpMethod !== 'POST') {
        return {
            statusCode: 405,
            headers,
            body: JSON.stringify({ error: 'Método não permitido. Use POST.' })
        };
    }

    try {
        // Parse do body
        const dados = JSON.parse(event.body);
        console.log('📋 Dados recebidos:', {
            protocolo: dados.protocolo,
            municipio: dados.municipio,
            escritorio: dados.escritorioLocal
        });

        // Validação básica
        if (!dados.protocolo) {
            return {
                statusCode: 400,
                headers,
                body: JSON.stringify({ 
                    success: false, 
                    error: 'Protocolo é obrigatório' 
                })
            };
        }

        // Conectar ao banco
        console.log('🔌 Conectando ao SQL Azure...');
        const pool = await sql.connect(config);
        console.log('✅ Conectado ao banco de dados');

        // Helper para converter arrays em JSON
        const toJSON = (value) => {
            if (!value) return null;
            if (Array.isArray(value)) return JSON.stringify(value);
            return value;
        };

        // Helper para garantir valor numérico ou NULL
        const toInt = (value) => {
            if (value === null || value === undefined || value === '') return null;
            const num = parseInt(value);
            return isNaN(num) ? null : num;
        };

        // Calcular duração
        const duracao = dados.timestamp_inicio && dados.timestamp_fim
            ? Math.round((new Date(dados.timestamp_fim) - new Date(dados.timestamp_inicio)) / 60000)
            : null;

        // Preparar query de inserção
        const query = `
            INSERT INTO formulario_gerentes (
                protocolo,
                municipio,
                escritorio_local,
                tempo_gerente,
                nome_completo,
                
                -- Eixo A
                resultados_relevantes,
                resultados_relevantes_outro,
                impacto_aumento_produtividade,
                impacto_aumento_comercializacao,
                impacto_inclusao_programas,
                impacto_implementacao_tecnologias,
                impacto_fortalecimento_organizacoes,
                impacto_capacitacao_produtores,
                impacto_reducao_perdas,
                desafio_fatores_externos,
                desafio_falta_pessoal,
                desafio_falta_veiculos,
                desafio_falta_orcamento,
                desafio_baixa_organizacao,
                desafio_falta_dados,
                desafio_resistencia_produtores,
                desafio_burocracia,
                estrategias,
                estrategias_outro,
                estrategia_mais_efetiva,
                
                -- Eixo B
                criterios_priorizacao,
                criterios_priorizacao_outro,
                documento_formal_criterios,
                instrumentos_priorizacao,
                exemplo_instrumento,
                plano_anual,
                participantes_plano,
                suficiencia_pessoal,
                suficiencia_veiculo,
                suficiencia_estrutura,
                suficiencia_equipamentos,
                efeitos_carencia,
                efeitos_carencia_outro,
                comentario_b,
                
                -- Eixo C
                parceiros_relevantes,
                parceiros_relevantes_outro,
                levantamento_pnae,
                instrumentos_pnae,
                frequencia_foruns,
                natureza_participacao,
                quantidade_proposicoes,
                efetividade_proposicoes,
                comentario_c,
                
                -- Eixo D
                diagnostico_demanda,
                instrumentos_diagnostico,
                instrumentos_diagnostico_outro,
                apoio_comercializacao,
                apoio_comercializacao_outro,
                relacionamento_compradores,
                barreiras_relacionamento,
                barreiras_relacionamento_outro,
                comentario_d,
                
                -- Eixo E
                indicadores_desempenho,
                indicadores_desempenho_outro,
                indicadores_formalizados,
                indicadores_efetividade,
                indicadores_efetividade_quais,
                frequencia_influencia,
                capacidade_acompanhamento,
                limitacoes_acompanhamento,
                comentario_e,
                
                -- Metadados
                timestamp_inicio,
                timestamp_fim,
                duracao_minutos,
                status,
                sincronizado,
                dados_json
            )
            VALUES (
                @protocolo,
                @municipio,
                @escritorio_local,
                @tempo_gerente,
                @nome_completo,
                
                -- Eixo A
                @resultados_relevantes,
                @resultados_relevantes_outro,
                @impacto_aumento_produtividade,
                @impacto_aumento_comercializacao,
                @impacto_inclusao_programas,
                @impacto_implementacao_tecnologias,
                @impacto_fortalecimento_organizacoes,
                @impacto_capacitacao_produtores,
                @impacto_reducao_perdas,
                @desafio_fatores_externos,
                @desafio_falta_pessoal,
                @desafio_falta_veiculos,
                @desafio_falta_orcamento,
                @desafio_baixa_organizacao,
                @desafio_falta_dados,
                @desafio_resistencia_produtores,
                @desafio_burocracia,
                @estrategias,
                @estrategias_outro,
                @estrategia_mais_efetiva,
                
                -- Eixo B
                @criterios_priorizacao,
                @criterios_priorizacao_outro,
                @documento_formal_criterios,
                @instrumentos_priorizacao,
                @exemplo_instrumento,
                @plano_anual,
                @participantes_plano,
                @suficiencia_pessoal,
                @suficiencia_veiculo,
                @suficiencia_estrutura,
                @suficiencia_equipamentos,
                @efeitos_carencia,
                @efeitos_carencia_outro,
                @comentario_b,
                
                -- Eixo C
                @parceiros_relevantes,
                @parceiros_relevantes_outro,
                @levantamento_pnae,
                @instrumentos_pnae,
                @frequencia_foruns,
                @natureza_participacao,
                @quantidade_proposicoes,
                @efetividade_proposicoes,
                @comentario_c,
                
                -- Eixo D
                @diagnostico_demanda,
                @instrumentos_diagnostico,
                @instrumentos_diagnostico_outro,
                @apoio_comercializacao,
                @apoio_comercializacao_outro,
                @relacionamento_compradores,
                @barreiras_relacionamento,
                @barreiras_relacionamento_outro,
                @comentario_d,
                
                -- Eixo E
                @indicadores_desempenho,
                @indicadores_desempenho_outro,
                @indicadores_formalizados,
                @indicadores_efetividade,
                @indicadores_efetividade_quais,
                @frequencia_influencia,
                @capacidade_acompanhamento,
                @limitacoes_acompanhamento,
                @comentario_e,
                
                -- Metadados
                @timestamp_inicio,
                @timestamp_fim,
                @duracao_minutos,
                @status,
                @sincronizado,
                @dados_json
            )
        `;

        const request = pool.request();
        
        // Parâmetros - Identificação
        request.input('protocolo', sql.NVarChar(50), dados.protocolo);
        request.input('municipio', sql.NVarChar(100), dados.municipio || null);
        request.input('escritorio_local', sql.NVarChar(100), dados.escritorioLocal || null);
        request.input('tempo_gerente', sql.NVarChar(20), dados.tempoGerente || null);
        request.input('nome_completo', sql.NVarChar(200), dados.nomeCompleto || null);
        
        // Eixo A - Resultados e Desafios
        request.input('resultados_relevantes', sql.NVarChar(sql.MAX), toJSON(dados.resultadosRelevantes));
        request.input('resultados_relevantes_outro', sql.NVarChar(500), dados.resultadosRelevantesOutro || null);
        request.input('impacto_aumento_produtividade', sql.Int, toInt(dados.impacto_aumento_produtividade));
        request.input('impacto_aumento_comercializacao', sql.Int, toInt(dados.impacto_aumento_comercializacao));
        request.input('impacto_inclusao_programas', sql.Int, toInt(dados.impacto_inclusao_programas));
        request.input('impacto_implementacao_tecnologias', sql.Int, toInt(dados.impacto_implementacao_tecnologias));
        request.input('impacto_fortalecimento_organizacoes', sql.Int, toInt(dados.impacto_fortalecimento_organizacoes));
        request.input('impacto_capacitacao_produtores', sql.Int, toInt(dados.impacto_capacitacao_produtores));
        request.input('impacto_reducao_perdas', sql.Int, toInt(dados.impacto_reducao_perdas));
        request.input('desafio_fatores_externos', sql.Int, toInt(dados.desafio_fatores_externos));
        request.input('desafio_falta_pessoal', sql.Int, toInt(dados.desafio_falta_pessoal));
        request.input('desafio_falta_veiculos', sql.Int, toInt(dados.desafio_falta_veiculos));
        request.input('desafio_falta_orcamento', sql.Int, toInt(dados.desafio_falta_orcamento));
        request.input('desafio_baixa_organizacao', sql.Int, toInt(dados.desafio_baixa_organizacao));
        request.input('desafio_falta_dados', sql.Int, toInt(dados.desafio_falta_dados));
        request.input('desafio_resistencia_produtores', sql.Int, toInt(dados.desafio_resistencia_produtores));
        request.input('desafio_burocracia', sql.Int, toInt(dados.desafio_burocracia));
        request.input('estrategias', sql.NVarChar(sql.MAX), toJSON(dados.estrategias));
        request.input('estrategias_outro', sql.NVarChar(500), dados.estrategiasOutro || null);
        request.input('estrategia_mais_efetiva', sql.NVarChar(100), dados.estrategiaMaisEfetiva || null);
        
        // Eixo B - Planejamento e Recursos
        request.input('criterios_priorizacao', sql.NVarChar(sql.MAX), toJSON(dados.criteriosPriorizacao));
        request.input('criterios_priorizacao_outro', sql.NVarChar(500), dados.criteriosPriorizacaoOutro || null);
        request.input('documento_formal_criterios', sql.Int, toInt(dados.documentoFormalCriterios));
        request.input('instrumentos_priorizacao', sql.NVarChar(20), dados.instrumentosPriorizacao || null);
        request.input('exemplo_instrumento', sql.NVarChar(sql.MAX), dados.exemploInstrumento || null);
        request.input('plano_anual', sql.NVarChar(20), dados.planoAnual || null);
        request.input('participantes_plano', sql.NVarChar(sql.MAX), toJSON(dados.participantesPlano));
        request.input('suficiencia_pessoal', sql.Int, toInt(dados.suficiencia_pessoal));
        request.input('suficiencia_veiculo', sql.Int, toInt(dados.suficiencia_veiculo));
        request.input('suficiencia_estrutura', sql.Int, toInt(dados.suficiencia_estrutura));
        request.input('suficiencia_equipamentos', sql.Int, toInt(dados.suficiencia_equipamentos));
        request.input('efeitos_carencia', sql.NVarChar(sql.MAX), toJSON(dados.efeitosCarencia));
        request.input('efeitos_carencia_outro', sql.NVarChar(500), dados.efeitosCarenciaOutro || null);
        request.input('comentario_b', sql.NVarChar(sql.MAX), dados.comentarioB || null);
        
        // Eixo C - Parcerias e Fóruns
        request.input('parceiros_relevantes', sql.NVarChar(sql.MAX), toJSON(dados.parceirosRelevantes));
        request.input('parceiros_relevantes_outro', sql.NVarChar(500), dados.parceirosRelevantesOutro || null);
        request.input('levantamento_pnae', sql.NVarChar(20), dados.levantamentoPNAE || null);
        request.input('instrumentos_pnae', sql.NVarChar(sql.MAX), dados.instrumentosPNAE || null);
        request.input('frequencia_foruns', sql.NVarChar(20), dados.frequenciaForuns || null);
        request.input('natureza_participacao', sql.NVarChar(sql.MAX), toJSON(dados.naturezaParticipacao));
        request.input('quantidade_proposicoes', sql.NVarChar(20), dados.quantidadeProposicoes || null);
        request.input('efetividade_proposicoes', sql.NVarChar(20), dados.efetividadeProposicoes || null);
        request.input('comentario_c', sql.NVarChar(sql.MAX), dados.comentarioC || null);
        
        // Eixo D - Produção, Demanda e Mercado
        request.input('diagnostico_demanda', sql.NVarChar(20), dados.diagnosticoDemanda || null);
        request.input('instrumentos_diagnostico', sql.NVarChar(sql.MAX), toJSON(dados.instrumentosDiagnostico));
        request.input('instrumentos_diagnostico_outro', sql.NVarChar(500), dados.instrumentosDiagnosticoOutro || null);
        request.input('apoio_comercializacao', sql.NVarChar(sql.MAX), toJSON(dados.apoioComercializacao));
        request.input('apoio_comercializacao_outro', sql.NVarChar(500), dados.apoioComercializacaoOutro || null);
        request.input('relacionamento_compradores', sql.Int, toInt(dados.relacionamentoCompradores));
        request.input('barreiras_relacionamento', sql.NVarChar(sql.MAX), toJSON(dados.barreirasRelacionamento));
        request.input('barreiras_relacionamento_outro', sql.NVarChar(500), dados.barreirasRelacionamentoOutro || null);
        request.input('comentario_d', sql.NVarChar(sql.MAX), dados.comentarioD || null);
        
        // Eixo E - Monitoramento e Avaliação
        request.input('indicadores_desempenho', sql.NVarChar(sql.MAX), toJSON(dados.indicadoresDesempenho));
        request.input('indicadores_desempenho_outro', sql.NVarChar(500), dados.indicadoresDesempenhoOutro || null);
        request.input('indicadores_formalizados', sql.NVarChar(20), dados.indicadoresFormalizados || null);
        request.input('indicadores_efetividade', sql.NVarChar(20), dados.indicadoresEfetividade || null);
        request.input('indicadores_efetividade_quais', sql.NVarChar(sql.MAX), dados.indicadoresEfetividadeQuais || null);
        request.input('frequencia_influencia', sql.NVarChar(20), dados.frequenciaInfluencia || null);
        request.input('capacidade_acompanhamento', sql.Int, toInt(dados.capacidadeAcompanhamento));
        request.input('limitacoes_acompanhamento', sql.NVarChar(sql.MAX), dados.limitacoesAcompanhamento || null);
        request.input('comentario_e', sql.NVarChar(sql.MAX), dados.comentarioE || null);
        
        // Metadados
        request.input('timestamp_inicio', sql.DateTime2, dados.timestamp_inicio || null);
        request.input('timestamp_fim', sql.DateTime2, dados.timestamp_fim || new Date().toISOString());
        request.input('duracao_minutos', sql.Int, duracao);
        request.input('status', sql.NVarChar(20), 'completo');
        request.input('sincronizado', sql.Bit, true);
        request.input('dados_json', sql.NVarChar(sql.MAX), JSON.stringify(dados));

        // Executar query
        console.log('💾 Salvando no banco de dados...');
        await request.query(query);
        
        console.log('✅ Formulário salvo com sucesso!');
        
        // Fechar conexão
        await pool.close();

        return {
            statusCode: 200,
            headers,
            body: JSON.stringify({
                success: true,
                message: 'Formulário salvo com sucesso',
                protocolo: dados.protocolo
            })
        };

    } catch (error) {
        console.error('❌ Erro ao salvar formulário:', error);
        
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
