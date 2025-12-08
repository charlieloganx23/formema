-- Schema para banco de dados SQL Azure
-- Database: db-ematech
-- Server: srv-db-cxtce.database.windows.net

-- Tabela principal de formulários dos extensionistas
CREATE TABLE formulario_extensionista (
    id INT IDENTITY(1,1) PRIMARY KEY,
    protocolo NVARCHAR(50) UNIQUE NOT NULL,
    municipio NVARCHAR(100),
    unidade_emater NVARCHAR(100),
    territorio NVARCHAR(100),
    identificador_iniciais NVARCHAR(10),
    
    -- Timestamps
    timestamp_inicio DATETIME2,
    timestamp_fim DATETIME2,
    duracao_minutos INT,
    
    -- Geolocalização
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    precisao DECIMAL(10, 2),
    geo_erro NVARCHAR(500),
    
    -- Status
    status NVARCHAR(20) DEFAULT 'completo',
    sincronizado BIT DEFAULT 1,
    
    -- Dados completos em JSON
    respostas NVARCHAR(MAX), -- JSON com todas as respostas
    fotos NVARCHAR(MAX), -- JSON array com fotos em base64
    
    -- Metadados
    created_at DATETIME2 DEFAULT GETUTCDATE(),
    updated_at DATETIME2 DEFAULT GETUTCDATE(),
    
    -- Índices para performance
    INDEX idx_protocolo (protocolo),
    INDEX idx_municipio (municipio),
    INDEX idx_unidade (unidade_emater),
    INDEX idx_timestamp (timestamp_fim),
    INDEX idx_created (created_at)
);

-- Trigger para atualizar updated_at
CREATE TRIGGER trg_update_timestamp
ON formularios
AFTER UPDATE
AS
BEGIN
    UPDATE formularios
    SET updated_at = GETUTCDATE()
    FROM formularios f
    INNER JOIN inserted i ON f.id = i.id;
END;

-- View para estatísticas rápidas
CREATE VIEW vw_estatisticas AS
SELECT 
    COUNT(*) as total_formularios,
    COUNT(DISTINCT municipio) as total_municipios,
    COUNT(DISTINCT unidade_emater) as total_unidades,
    COUNT(DISTINCT territorio) as total_territorios,
    AVG(duracao_minutos) as media_duracao,
    MAX(timestamp_fim) as ultima_submissao
FROM formularios;

-- View para cobertura por município
CREATE VIEW vw_cobertura_municipios AS
SELECT 
    municipio,
    territorio,
    COUNT(*) as total_formularios,
    MAX(timestamp_fim) as ultima_visita,
    DATEDIFF(day, MAX(timestamp_fim), GETUTCDATE()) as dias_desde_ultima
FROM formularios
WHERE municipio IS NOT NULL
GROUP BY municipio, territorio;

-- View para cobertura por unidade EMATER
CREATE VIEW vw_cobertura_unidades AS
SELECT 
    unidade_emater,
    COUNT(*) as total_visitas,
    MAX(timestamp_fim) as ultima_visita,
    MIN(timestamp_fim) as primeira_visita,
    DATEDIFF(day, MAX(timestamp_fim), GETUTCDATE()) as dias_desde_ultima
FROM formularios
WHERE unidade_emater IS NOT NULL
GROUP BY unidade_emater;
