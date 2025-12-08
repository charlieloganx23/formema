-- ============================================
-- Script de Criação de Banco de Dados
-- Formulário Emater-RO
-- ============================================

-- Tabela Principal de Respostas
CREATE TABLE Respostas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    protocolo VARCHAR(50) UNIQUE NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    
    -- Identificação
    municipio VARCHAR(100) NOT NULL,
    escritorioLocal VARCHAR(100) NOT NULL,
    tempoEmater VARCHAR(20) NOT NULL,
    nomeCompleto VARCHAR(200) NULL,
    
    -- Dados completos em JSON
    dadosCompletos NVARCHAR(MAX) NOT NULL,
    
    -- Metadados
    ipAddress VARCHAR(45) NULL,
    userAgent VARCHAR(500) NULL,
    sincronizado BIT DEFAULT 0,
    
    -- Índices
    INDEX idx_protocolo (protocolo),
    INDEX idx_timestamp (timestamp),
    INDEX idx_municipio (municipio)
);

-- Tabela de Respostas Detalhadas (para análise)
CREATE TABLE RespostasDetalhadas (
    id INT IDENTITY(1,1) PRIMARY KEY,
    protocolo VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    subcategoria VARCHAR(50) NULL,
    valor VARCHAR(500) NULL,
    valorNumerico INT NULL,
    
    FOREIGN KEY (protocolo) REFERENCES Respostas(protocolo),
    INDEX idx_categoria (categoria),
    INDEX idx_protocolo_cat (protocolo, categoria)
);

-- Tabela de Log de Sincronização
CREATE TABLE LogSincronizacao (
    id INT IDENTITY(1,1) PRIMARY KEY,
    protocolo VARCHAR(50) NOT NULL,
    timestamp DATETIME NOT NULL DEFAULT GETDATE(),
    status VARCHAR(20) NOT NULL, -- 'sucesso', 'erro', 'pendente'
    mensagem NVARCHAR(MAX) NULL,
    
    FOREIGN KEY (protocolo) REFERENCES Respostas(protocolo),
    INDEX idx_timestamp (timestamp)
);

-- View para análise rápida
CREATE VIEW vw_RespostasSumario AS
SELECT 
    r.protocolo,
    r.timestamp,
    r.municipio,
    r.escritorioLocal,
    r.tempoEmater,
    r.nomeCompleto,
    COUNT(DISTINCT rd.categoria) as totalCategorias,
    r.sincronizado
FROM Respostas r
LEFT JOIN RespostasDetalhadas rd ON r.protocolo = rd.protocolo
GROUP BY 
    r.protocolo, r.timestamp, r.municipio, 
    r.escritorioLocal, r.tempoEmater, r.nomeCompleto, r.sincronizado;

-- View para análise de dificuldades (Likert)
CREATE VIEW vw_DificuldadesMedia AS
SELECT 
    rd.categoria,
    AVG(CAST(rd.valorNumerico AS FLOAT)) as media,
    COUNT(*) as total_respostas
FROM RespostasDetalhadas rd
WHERE rd.categoria LIKE 'dif_%'
    AND rd.valorNumerico IS NOT NULL
GROUP BY rd.categoria;

-- View para análise por município
CREATE VIEW vw_RespostasPorMunicipio AS
SELECT 
    municipio,
    COUNT(*) as total_respostas,
    COUNT(CASE WHEN nomeCompleto IS NOT NULL THEN 1 END) as respostas_identificadas,
    MIN(timestamp) as primeira_resposta,
    MAX(timestamp) as ultima_resposta
FROM Respostas
GROUP BY municipio;

-- Procedure para backup de dados
CREATE PROCEDURE sp_BackupRespostas
    @dataInicio DATETIME = NULL,
    @dataFim DATETIME = NULL
AS
BEGIN
    IF @dataInicio IS NULL SET @dataInicio = '2025-01-01';
    IF @dataFim IS NULL SET @dataFim = GETDATE();
    
    SELECT 
        r.*,
        (SELECT categoria, valor, valorNumerico
         FROM RespostasDetalhadas rd
         WHERE rd.protocolo = r.protocolo
         FOR JSON PATH) as detalhes
    FROM Respostas r
    WHERE r.timestamp BETWEEN @dataInicio AND @dataFim
    ORDER BY r.timestamp DESC
    FOR JSON PATH;
END;

-- Trigger para log de sincronização
CREATE TRIGGER trg_AposSalvarResposta
ON Respostas
AFTER INSERT
AS
BEGIN
    INSERT INTO LogSincronizacao (protocolo, status, mensagem)
    SELECT 
        i.protocolo, 
        'sucesso', 
        'Resposta salva via API'
    FROM inserted i;
END;

-- Grants (ajuste conforme necessário)
-- GRANT SELECT, INSERT, UPDATE ON Respostas TO [sua_api_user];
-- GRANT SELECT, INSERT ON RespostasDetalhadas TO [sua_api_user];
-- GRANT SELECT, INSERT ON LogSincronizacao TO [sua_api_user];
