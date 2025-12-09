-- Schema SQL para formulário de GERENTES LOCAIS
-- Database: db-ematech
-- Server: srv-db-cxtce.database.windows.net

-- ============================================
-- TABELA: formulario_gerentes
-- ============================================
CREATE TABLE formulario_gerentes (
    id INT IDENTITY(1,1) PRIMARY KEY,
    protocolo NVARCHAR(50) UNIQUE NOT NULL,
    
    -- ====== MÓDULO I: IDENTIFICAÇÃO ======
    municipio NVARCHAR(100),
    escritorio_local NVARCHAR(100),
    tempo_gerente NVARCHAR(20), -- menos1, 1a3, 4a10, mais10
    nome_completo NVARCHAR(200),
    
    -- ====== EIXO A: RESULTADOS E DESAFIOS ======
    -- Q1: Resultados relevantes (max 5)
    resultados_relevantes NVARCHAR(MAX), -- JSON array
    resultados_relevantes_outro NVARCHAR(500),
    
    -- Q1-subquestão: Impactos (Likert 1-5)
    impacto_aumento_produtividade INT,
    impacto_aumento_comercializacao INT,
    impacto_inclusao_programas INT,
    impacto_implementacao_tecnologias INT,
    impacto_fortalecimento_organizacoes INT,
    impacto_capacitacao_produtores INT,
    impacto_reducao_perdas INT,
    
    -- Q2: Desafios (Likert 1-5)
    desafio_fatores_externos INT,
    desafio_falta_pessoal INT,
    desafio_falta_veiculos INT,
    desafio_falta_orcamento INT,
    desafio_baixa_organizacao INT,
    desafio_falta_dados INT,
    desafio_resistencia_produtores INT,
    desafio_burocracia INT,
    
    -- Q3: Estratégias utilizadas
    estrategias NVARCHAR(MAX), -- JSON array
    estrategias_outro NVARCHAR(500),
    estrategia_mais_efetiva NVARCHAR(100),
    
    -- ====== EIXO B: PLANEJAMENTO E RECURSOS ======
    -- Q4: Critérios de priorização
    criterios_priorizacao NVARCHAR(MAX), -- JSON array
    criterios_priorizacao_outro NVARCHAR(500),
    
    -- Q5: Documento formal (Likert 1-5)
    documento_formal_criterios INT,
    
    -- Q6: Instrumentos formais
    instrumentos_priorizacao NVARCHAR(20), -- sim, parcialmente, nao
    exemplo_instrumento NVARCHAR(MAX),
    
    -- Q7: Plano anual
    plano_anual NVARCHAR(20), -- sim_aprovado, sim_elaboracao, nao
    
    -- Q8: Participantes do plano
    participantes_plano NVARCHAR(MAX), -- JSON array
    
    -- Q9: Suficiência de recursos (Likert 1-5)
    suficiencia_pessoal INT,
    suficiencia_veiculo INT,
    suficiencia_estrutura INT,
    suficiencia_equipamentos INT,
    
    -- Q10: Efeitos da carência (max 3)
    efeitos_carencia NVARCHAR(MAX), -- JSON array
    efeitos_carencia_outro NVARCHAR(500),
    
    comentario_b NVARCHAR(MAX),
    
    -- ====== EIXO C: PARCERIAS E FÓRUNS ======
    -- Q11: Parceiros relevantes (max 3)
    parceiros_relevantes NVARCHAR(MAX), -- JSON array
    parceiros_relevantes_outro NVARCHAR(500),
    
    -- Q12: Levantamento PNAE
    levantamento_pnae NVARCHAR(20), -- sim_sistematico, sim_esporadico, nao
    instrumentos_pnae NVARCHAR(MAX),
    
    -- Q13: Frequência fóruns
    frequencia_foruns NVARCHAR(20), -- sempre, frequentemente, as_vezes, raramente, nunca
    
    -- Q14: Natureza participação
    natureza_participacao NVARCHAR(MAX), -- JSON array
    
    -- Q15: Quantidade proposições
    quantidade_proposicoes NVARCHAR(20), -- nenhuma, 1-3, 4-6, mais_6
    
    -- Q16: Efetividade proposições
    efetividade_proposicoes NVARCHAR(20), -- baixa, media, alta
    
    comentario_c NVARCHAR(MAX),
    
    -- ====== EIXO D: PRODUÇÃO, DEMANDA E MERCADO ======
    -- Q17: Diagnóstico demanda
    diagnostico_demanda NVARCHAR(20), -- sim_documentos, sim_informal, nao
    instrumentos_diagnostico NVARCHAR(MAX), -- JSON array
    instrumentos_diagnostico_outro NVARCHAR(500),
    
    -- Q18: Apoio comercialização
    apoio_comercializacao NVARCHAR(MAX), -- JSON array
    apoio_comercializacao_outro NVARCHAR(500),
    
    -- Q19: Relacionamento compradores (Likert 1-5)
    relacionamento_compradores INT,
    
    -- Q20: Barreiras relacionamento (max 3)
    barreiras_relacionamento NVARCHAR(MAX), -- JSON array
    barreiras_relacionamento_outro NVARCHAR(500),
    
    comentario_d NVARCHAR(MAX),
    
    -- ====== EIXO E: MONITORAMENTO E AVALIAÇÃO ======
    -- Q21: Indicadores desempenho
    indicadores_desempenho NVARCHAR(MAX), -- JSON array
    indicadores_desempenho_outro NVARCHAR(500),
    
    -- Q22: Indicadores formalizados
    indicadores_formalizados NVARCHAR(20), -- sim, parcialmente, nao
    
    -- Q23: Indicadores efetividade
    indicadores_efetividade NVARCHAR(20), -- sim, parcialmente, nao
    indicadores_efetividade_quais NVARCHAR(MAX),
    
    -- Q24: Frequência influência
    frequencia_influencia NVARCHAR(20), -- sempre, frequentemente, as_vezes, raramente, nunca
    
    -- Q25: Capacidade acompanhamento (Likert 1-5)
    capacidade_acompanhamento INT,
    
    -- Q26: Limitações acompanhamento
    limitacoes_acompanhamento NVARCHAR(MAX),
    
    comentario_e NVARCHAR(MAX),
    
    -- ====== METADADOS ======
    timestamp_inicio DATETIME2,
    timestamp_fim DATETIME2,
    duracao_minutos INT,
    
    -- Status
    status NVARCHAR(20) DEFAULT 'completo',
    sincronizado BIT DEFAULT 1,
    
    -- Dados JSON completos (backup)
    dados_json NVARCHAR(MAX),
    
    -- Auditoria
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    
    -- Índices para performance
    INDEX idx_protocolo_gerentes (protocolo),
    INDEX idx_municipio_gerentes (municipio),
    INDEX idx_escritorio_gerentes (escritorio_local),
    INDEX idx_timestamp_gerentes (timestamp_fim),
    INDEX idx_created_gerentes (created_at)
);
GO

-- ============================================
-- TRIGGER: Atualizar timestamp
-- ============================================
CREATE TRIGGER trg_update_timestamp_gerentes
ON formulario_gerentes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE formulario_gerentes
    SET updated_at = GETUTCDATE()
    FROM formulario_gerentes f
    INNER JOIN inserted i ON f.id = i.id;
END;
GO

-- ============================================
-- VIEW: Estatísticas gerais
-- ============================================
CREATE VIEW vw_estatisticas_gerentes AS
SELECT 
    COUNT(*) as total_formularios,
    COUNT(DISTINCT municipio) as total_municipios,
    COUNT(DISTINCT escritorio_local) as total_escritorios,
    AVG(duracao_minutos) as media_duracao_minutos,
    MAX(timestamp_fim) as ultima_submissao,
    MIN(timestamp_fim) as primeira_submissao,
    
    -- Tempo como gerente
    SUM(CASE WHEN tempo_gerente = 'menos1' THEN 1 ELSE 0 END) as gerentes_menos_1ano,
    SUM(CASE WHEN tempo_gerente = '1a3' THEN 1 ELSE 0 END) as gerentes_1a3_anos,
    SUM(CASE WHEN tempo_gerente = '4a10' THEN 1 ELSE 0 END) as gerentes_4a10_anos,
    SUM(CASE WHEN tempo_gerente = 'mais10' THEN 1 ELSE 0 END) as gerentes_mais_10anos,
    
    -- Médias de avaliações
    AVG(CAST(suficiencia_pessoal AS FLOAT)) as media_suficiencia_pessoal,
    AVG(CAST(suficiencia_veiculo AS FLOAT)) as media_suficiencia_veiculo,
    AVG(CAST(suficiencia_estrutura AS FLOAT)) as media_suficiencia_estrutura,
    AVG(CAST(suficiencia_equipamentos AS FLOAT)) as media_suficiencia_equipamentos,
    AVG(CAST(relacionamento_compradores AS FLOAT)) as media_relacionamento_compradores,
    AVG(CAST(capacidade_acompanhamento AS FLOAT)) as media_capacidade_acompanhamento
FROM formulario_gerentes;
GO

-- ============================================
-- VIEW: Cobertura por município
-- ============================================
CREATE VIEW vw_cobertura_municipios_gerentes AS
SELECT 
    municipio,
    COUNT(*) as total_gerentes,
    MAX(timestamp_fim) as ultima_submissao,
    MIN(timestamp_fim) as primeira_submissao,
    DATEDIFF(day, MAX(timestamp_fim), GETUTCDATE()) as dias_desde_ultima,
    
    -- Média de suficiência de recursos
    AVG(CAST(suficiencia_pessoal AS FLOAT)) as media_suficiencia_pessoal,
    AVG(CAST(suficiencia_veiculo AS FLOAT)) as media_suficiencia_veiculo,
    
    -- Desafios mais críticos (média > 3)
    AVG(CAST(desafio_falta_pessoal AS FLOAT)) as media_desafio_pessoal,
    AVG(CAST(desafio_falta_veiculos AS FLOAT)) as media_desafio_veiculos
FROM formulario_gerentes
WHERE municipio IS NOT NULL
GROUP BY municipio;
GO

-- ============================================
-- VIEW: Ranking de desafios
-- ============================================
CREATE VIEW vw_ranking_desafios_gerentes AS
SELECT 
    'Fatores Externos' as desafio,
    AVG(CAST(desafio_fatores_externos AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_fatores_externos IS NOT NULL

UNION ALL

SELECT 
    'Falta de Pessoal' as desafio,
    AVG(CAST(desafio_falta_pessoal AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_falta_pessoal IS NOT NULL

UNION ALL

SELECT 
    'Falta de Veículos' as desafio,
    AVG(CAST(desafio_falta_veiculos AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_falta_veiculos IS NOT NULL

UNION ALL

SELECT 
    'Falta de Orçamento' as desafio,
    AVG(CAST(desafio_falta_orcamento AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_falta_orcamento IS NOT NULL

UNION ALL

SELECT 
    'Baixa Organização Produtores' as desafio,
    AVG(CAST(desafio_baixa_organizacao AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_baixa_organizacao IS NOT NULL

UNION ALL

SELECT 
    'Falta de Dados/Sigater' as desafio,
    AVG(CAST(desafio_falta_dados AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_falta_dados IS NOT NULL

UNION ALL

SELECT 
    'Resistência dos Produtores' as desafio,
    AVG(CAST(desafio_resistencia_produtores AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_resistencia_produtores IS NOT NULL

UNION ALL

SELECT 
    'Burocracia Interna' as desafio,
    AVG(CAST(desafio_burocracia AS FLOAT)) as media_impacto,
    COUNT(*) as total_respostas
FROM formulario_gerentes
WHERE desafio_burocracia IS NOT NULL;
GO

-- ============================================
-- VIEW: Análise de planejamento
-- ============================================
CREATE VIEW vw_analise_planejamento_gerentes AS
SELECT 
    plano_anual,
    COUNT(*) as total,
    AVG(CAST(suficiencia_pessoal AS FLOAT)) as media_suficiencia_pessoal,
    AVG(CAST(capacidade_acompanhamento AS FLOAT)) as media_capacidade_acompanhamento
FROM formulario_gerentes
GROUP BY plano_anual;
GO

-- ============================================
-- VIEW: Engajamento em fóruns
-- ============================================
CREATE VIEW vw_engajamento_foruns_gerentes AS
SELECT 
    frequencia_foruns,
    COUNT(*) as total_gerentes,
    quantidade_proposicoes,
    efetividade_proposicoes,
    COUNT(*) as total_por_categoria
FROM formulario_gerentes
WHERE frequencia_foruns IS NOT NULL
GROUP BY frequencia_foruns, quantidade_proposicoes, efetividade_proposicoes;
GO

PRINT '✅ Schema para formulário de GERENTES criado com sucesso!';
PRINT '📊 6 tabelas/views disponíveis:';
PRINT '   - formulario_gerentes (tabela principal)';
PRINT '   - vw_estatisticas_gerentes';
PRINT '   - vw_cobertura_municipios_gerentes';
PRINT '   - vw_ranking_desafios_gerentes';
PRINT '   - vw_analise_planejamento_gerentes';
PRINT '   - vw_engajamento_foruns_gerentes';
