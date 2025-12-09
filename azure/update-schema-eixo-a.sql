-- ============================================
-- ATUALIZAÇÃO SCHEMA - NOVO EIXO A
-- Métodos de ATER e Resultados Percebidos
-- Data: 09/12/2025
-- ============================================
-- Database: db-ematech
-- Server: srv-db-cxtce.database.windows.net
-- Tabela: formulario_extensionista
-- ============================================

USE [db-ematech];
GO

-- ============================================
-- ADICIONAR NOVAS COLUNAS - EIXO A
-- ============================================

-- QUESTÃO 1: Métodos utilizados com maior frequência (até 3)
ALTER TABLE formulario_extensionista
ADD metodos_frequentes NVARCHAR(MAX) NULL; -- JSON array: ["visitas_tecnicas", "dias_campo", ...]
GO

ALTER TABLE formulario_extensionista
ADD metodos_frequentes_outro NVARCHAR(500) NULL; -- Texto livre se marcou "Outro"
GO

-- QUESTÃO 2: Métodos que geram melhores resultados (até 3)
ALTER TABLE formulario_extensionista
ADD metodos_melhores_resultados NVARCHAR(MAX) NULL; -- JSON array: ["demonstracao_metodo", ...]
GO

ALTER TABLE formulario_extensionista
ADD metodos_melhores_resultados_outro NVARCHAR(500) NULL; -- Texto livre se marcou "Outro"
GO

-- QUESTÃO 3: Principais dificuldades (Likert 1-5)
ALTER TABLE formulario_extensionista
ADD dificuldade_falta_tempo INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_num_tecnicos INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_distancia INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_baixa_adesao INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_recursos INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_demandas_admin INT NULL; -- 1-5
GO

ALTER TABLE formulario_extensionista
ADD dificuldade_metas INT NULL; -- 1-5
GO

-- Campo de comentário aberto
ALTER TABLE formulario_extensionista
ADD comentario_eixo_a NVARCHAR(MAX) NULL; -- Campo livre para comentários
GO

-- ============================================
-- CRIAR ÍNDICES PARA PERFORMANCE
-- ============================================

CREATE INDEX idx_metodos_frequentes ON formulario_extensionista(metodos_frequentes);
GO

CREATE INDEX idx_metodos_melhores ON formulario_extensionista(metodos_melhores_resultados);
GO

-- ============================================
-- VIEW DE ANÁLISE - MÉTODOS MAIS UTILIZADOS
-- ============================================

CREATE OR ALTER VIEW vw_analise_metodos_ater AS
SELECT 
    -- Contagem de métodos frequentes
    SUM(CASE WHEN metodos_frequentes LIKE '%visitas_tecnicas%' THEN 1 ELSE 0 END) as freq_visitas_tecnicas,
    SUM(CASE WHEN metodos_frequentes LIKE '%dias_campo%' THEN 1 ELSE 0 END) as freq_dias_campo,
    SUM(CASE WHEN metodos_frequentes LIKE '%demonstracao_metodo%' THEN 1 ELSE 0 END) as freq_demonstracao,
    SUM(CASE WHEN metodos_frequentes LIKE '%capacitacoes_coletivas%' THEN 1 ELSE 0 END) as freq_capacitacoes,
    SUM(CASE WHEN metodos_frequentes LIKE '%whatsapp_digital%' THEN 1 ELSE 0 END) as freq_whatsapp,
    SUM(CASE WHEN metodos_frequentes LIKE '%planejamento_produtivo%' THEN 1 ELSE 0 END) as freq_planejamento,
    SUM(CASE WHEN metodos_frequentes LIKE '%apoio_programas%' THEN 1 ELSE 0 END) as freq_apoio_programas,
    
    -- Contagem de métodos com melhores resultados
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%visitas_tecnicas%' THEN 1 ELSE 0 END) as result_visitas_tecnicas,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%dias_campo%' THEN 1 ELSE 0 END) as result_dias_campo,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%demonstracao_metodo%' THEN 1 ELSE 0 END) as result_demonstracao,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%capacitacoes_coletivas%' THEN 1 ELSE 0 END) as result_capacitacoes,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%whatsapp_digital%' THEN 1 ELSE 0 END) as result_whatsapp,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%planejamento_produtivo%' THEN 1 ELSE 0 END) as result_planejamento,
    SUM(CASE WHEN metodos_melhores_resultados LIKE '%apoio_programas%' THEN 1 ELSE 0 END) as result_apoio_programas,
    
    -- Médias de dificuldades (Likert 1-5)
    AVG(CAST(dificuldade_falta_tempo AS FLOAT)) as media_dificuldade_tempo,
    AVG(CAST(dificuldade_num_tecnicos AS FLOAT)) as media_dificuldade_tecnicos,
    AVG(CAST(dificuldade_distancia AS FLOAT)) as media_dificuldade_distancia,
    AVG(CAST(dificuldade_baixa_adesao AS FLOAT)) as media_dificuldade_adesao,
    AVG(CAST(dificuldade_recursos AS FLOAT)) as media_dificuldade_recursos,
    AVG(CAST(dificuldade_demandas_admin AS FLOAT)) as media_dificuldade_admin,
    AVG(CAST(dificuldade_metas AS FLOAT)) as media_dificuldade_metas,
    
    -- Totais
    COUNT(*) as total_respostas
FROM formulario_extensionista
WHERE metodos_frequentes IS NOT NULL;
GO

-- ============================================
-- VIEW DE ANÁLISE POR MUNICÍPIO
-- ============================================

CREATE OR ALTER VIEW vw_metodos_por_municipio AS
SELECT 
    municipio,
    territorio,
    COUNT(*) as total_formularios,
    
    -- Métodos mais frequentes
    SUM(CASE WHEN metodos_frequentes LIKE '%visitas_tecnicas%' THEN 1 ELSE 0 END) as uso_visitas_tecnicas,
    SUM(CASE WHEN metodos_frequentes LIKE '%dias_campo%' THEN 1 ELSE 0 END) as uso_dias_campo,
    SUM(CASE WHEN metodos_frequentes LIKE '%demonstracao_metodo%' THEN 1 ELSE 0 END) as uso_demonstracao,
    SUM(CASE WHEN metodos_frequentes LIKE '%whatsapp_digital%' THEN 1 ELSE 0 END) as uso_whatsapp,
    
    -- Médias de dificuldades
    AVG(CAST(dificuldade_falta_tempo AS FLOAT)) as media_dificuldade_tempo,
    AVG(CAST(dificuldade_num_tecnicos AS FLOAT)) as media_dificuldade_tecnicos,
    AVG(CAST(dificuldade_distancia AS FLOAT)) as media_dificuldade_distancia,
    AVG(CAST(dificuldade_recursos AS FLOAT)) as media_dificuldade_recursos
    
FROM formulario_extensionista
WHERE municipio IS NOT NULL
GROUP BY municipio, territorio;
GO

-- ============================================
-- VIEW DE DIFICULDADES CRÍTICAS
-- ============================================

CREATE OR ALTER VIEW vw_dificuldades_criticas AS
SELECT 
    protocolo,
    municipio,
    unidade_emater,
    territorio,
    timestamp_fim,
    
    -- Dificuldades
    dificuldade_falta_tempo,
    dificuldade_num_tecnicos,
    dificuldade_distancia,
    dificuldade_baixa_adesao,
    dificuldade_recursos,
    dificuldade_demandas_admin,
    dificuldade_metas,
    
    -- Calcular média de dificuldades
    (CAST(dificuldade_falta_tempo AS FLOAT) + 
     CAST(dificuldade_num_tecnicos AS FLOAT) + 
     CAST(dificuldade_distancia AS FLOAT) + 
     CAST(dificuldade_baixa_adesao AS FLOAT) + 
     CAST(dificuldade_recursos AS FLOAT) + 
     CAST(dificuldade_demandas_admin AS FLOAT) + 
     CAST(dificuldade_metas AS FLOAT)) / 7.0 as media_dificuldades,
    
    comentario_eixo_a
    
FROM formulario_extensionista
WHERE dificuldade_falta_tempo IS NOT NULL
  AND (
      dificuldade_falta_tempo >= 4 OR
      dificuldade_num_tecnicos >= 4 OR
      dificuldade_distancia >= 4 OR
      dificuldade_baixa_adesao >= 4 OR
      dificuldade_recursos >= 4 OR
      dificuldade_demandas_admin >= 4 OR
      dificuldade_metas >= 4
  );
GO

-- ============================================
-- VALIDAÇÃO: VERIFICAR ESTRUTURA ATUALIZADA
-- ============================================

-- Verificar se as colunas foram adicionadas
SELECT 
    COLUMN_NAME, 
    DATA_TYPE, 
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'formulario_extensionista'
  AND COLUMN_NAME IN (
      'metodos_frequentes',
      'metodos_frequentes_outro',
      'metodos_melhores_resultados',
      'metodos_melhores_resultados_outro',
      'dificuldade_falta_tempo',
      'dificuldade_num_tecnicos',
      'dificuldade_distancia',
      'dificuldade_baixa_adesao',
      'dificuldade_recursos',
      'dificuldade_demandas_admin',
      'dificuldade_metas',
      'comentario_eixo_a'
  )
ORDER BY COLUMN_NAME;
GO

-- Verificar views criadas
SELECT 
    TABLE_NAME as VIEW_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'VIEW'
  AND TABLE_NAME IN (
      'vw_analise_metodos_ater',
      'vw_metodos_por_municipio',
      'vw_dificuldades_criticas'
  );
GO

PRINT '✅ Atualização do schema concluída com sucesso!';
PRINT '✅ 12 novas colunas adicionadas';
PRINT '✅ 3 views de análise criadas';
PRINT '✅ 2 índices criados para performance';
GO
