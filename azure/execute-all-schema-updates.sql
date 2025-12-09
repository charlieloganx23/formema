-- ========================================
-- SCRIPT CONSOLIDADO DE ATUALIZAÇÃO DO SCHEMA
-- Formulário: Extensionistas
-- Banco de dados: db-ematech
-- Servidor: srv-db-cxtce.database.windows.net
-- Data: 2025
-- ========================================

-- Este script combina todas as atualizações de schema para os Eixos A, B e E
-- Executar em uma única transação para garantir integridade

SET NOCOUNT ON;
GO

BEGIN TRANSACTION;
GO

BEGIN TRY
    PRINT '========================================';
    PRINT 'INICIANDO ATUALIZAÇÃO DO SCHEMA';
    PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT '========================================';
    PRINT '';

    -- ========================================
    -- EIXO A: Metodologias e Ferramentas
    -- ========================================
    PRINT 'ATUALIZANDO EIXO A: Metodologias e Ferramentas...';
    PRINT '';

    -- 1. metodos_frequentes
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'metodos_frequentes'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD metodos_frequentes NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo metodos_frequentes adicionado';
    END
    ELSE PRINT '  - Campo metodos_frequentes já existe';

    -- 2. metodos_frequentes_outro
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'metodos_frequentes_outro'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD metodos_frequentes_outro NVARCHAR(500) NULL;
        PRINT '  ✓ Campo metodos_frequentes_outro adicionado';
    END
    ELSE PRINT '  - Campo metodos_frequentes_outro já existe';

    -- 3. metodos_melhores_resultados
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'metodos_melhores_resultados'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD metodos_melhores_resultados NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo metodos_melhores_resultados adicionado';
    END
    ELSE PRINT '  - Campo metodos_melhores_resultados já existe';

    -- 4. metodos_melhores_resultados_outro
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'metodos_melhores_resultados_outro'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD metodos_melhores_resultados_outro NVARCHAR(500) NULL;
        PRINT '  ✓ Campo metodos_melhores_resultados_outro adicionado';
    END
    ELSE PRINT '  - Campo metodos_melhores_resultados_outro já existe';

    -- 5-11. Dificuldades (Likert 1-5)
    DECLARE @dificuldade_fields TABLE (field_name NVARCHAR(100));
    INSERT INTO @dificuldade_fields VALUES 
        ('dificuldade_falta_tempo'),
        ('dificuldade_falta_recursos'),
        ('dificuldade_resistencia_produtores'),
        ('dificuldade_falta_capacitacao'),
        ('dificuldade_metodos_inadequados'),
        ('dificuldade_falta_apoio_gestao'),
        ('dificuldade_comunicacao_equipe');

    DECLARE @field NVARCHAR(100);
    DECLARE dificuldade_cursor CURSOR FOR SELECT field_name FROM @dificuldade_fields;
    OPEN dificuldade_cursor;
    FETCH NEXT FROM dificuldade_cursor INTO @field;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT * FROM sys.columns 
            WHERE object_id = OBJECT_ID('formulario_extensionista') 
            AND name = @field
        )
        BEGIN
            DECLARE @sql NVARCHAR(MAX) = 'ALTER TABLE formulario_extensionista ADD ' + @field + ' INT NULL CHECK (' + @field + ' BETWEEN 1 AND 5);';
            EXEC sp_executesql @sql;
            PRINT '  ✓ Campo ' + @field + ' adicionado';
        END
        ELSE PRINT '  - Campo ' + @field + ' já existe';

        FETCH NEXT FROM dificuldade_cursor INTO @field;
    END

    CLOSE dificuldade_cursor;
    DEALLOCATE dificuldade_cursor;

    -- 12. comentario_eixo_a
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'comentario_eixo_a'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD comentario_eixo_a NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo comentario_eixo_a adicionado';
    END
    ELSE PRINT '  - Campo comentario_eixo_a já existe';

    PRINT '';
    PRINT 'EIXO A: Concluído (12 campos)';
    PRINT '';

    -- ========================================
    -- EIXO B: Equidade e Inclusão
    -- ========================================
    PRINT 'ATUALIZANDO EIXO B: Equidade e Inclusão...';
    PRINT '';

    -- 1. priorizacao_atendimentos
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'priorizacao_atendimentos'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD priorizacao_atendimentos NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo priorizacao_atendimentos adicionado';
    END
    ELSE PRINT '  - Campo priorizacao_atendimentos já existe';

    -- 2. priorizacao_atendimentos_outro
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'priorizacao_atendimentos_outro'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD priorizacao_atendimentos_outro NVARCHAR(500) NULL;
        PRINT '  ✓ Campo priorizacao_atendimentos_outro adicionado';
    END
    ELSE PRINT '  - Campo priorizacao_atendimentos_outro já existe';

    -- 3. nivel_equidade
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'nivel_equidade'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD nivel_equidade INT NULL CHECK (nivel_equidade BETWEEN 1 AND 5);
        PRINT '  ✓ Campo nivel_equidade adicionado';
    END
    ELSE PRINT '  - Campo nivel_equidade já existe';

    -- 4. instrumentos_formais
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'instrumentos_formais'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD instrumentos_formais NVARCHAR(100) NULL;
        PRINT '  ✓ Campo instrumentos_formais adicionado';
    END
    ELSE PRINT '  - Campo instrumentos_formais já existe';

    -- 5. exemplo_instrumento_formal
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'exemplo_instrumento_formal'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD exemplo_instrumento_formal NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo exemplo_instrumento_formal adicionado';
    END
    ELSE PRINT '  - Campo exemplo_instrumento_formal já existe';

    -- 6. comentario_eixo_b
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'comentario_eixo_b'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD comentario_eixo_b NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo comentario_eixo_b adicionado';
    END
    ELSE PRINT '  - Campo comentario_eixo_b já existe';

    PRINT '';
    PRINT 'EIXO B: Concluído (6 campos)';
    PRINT '';

    -- ========================================
    -- EIXO E: Indicadores, Relatórios e Avaliação
    -- ========================================
    PRINT 'ATUALIZANDO EIXO E: Indicadores e Avaliação...';
    PRINT '';

    -- 1. instrumentos_acompanhamento
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'instrumentos_acompanhamento'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD instrumentos_acompanhamento NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo instrumentos_acompanhamento adicionado';
    END
    ELSE PRINT '  - Campo instrumentos_acompanhamento já existe';

    -- 2. instrumentos_acompanhamento_outro
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'instrumentos_acompanhamento_outro'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD instrumentos_acompanhamento_outro NVARCHAR(500) NULL;
        PRINT '  ✓ Campo instrumentos_acompanhamento_outro adicionado';
    END
    ELSE PRINT '  - Campo instrumentos_acompanhamento_outro já existe';

    -- 3. freq_uso_indicadores
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'freq_uso_indicadores'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD freq_uso_indicadores NVARCHAR(50) NULL;
        PRINT '  ✓ Campo freq_uso_indicadores adicionado';
    END
    ELSE PRINT '  - Campo freq_uso_indicadores já existe';

    -- 4. principais_indicadores
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'principais_indicadores'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD principais_indicadores NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo principais_indicadores adicionado';
    END
    ELSE PRINT '  - Campo principais_indicadores já existe';

    -- 5. avaliacao_ajuda_indicadores
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'avaliacao_ajuda_indicadores'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD avaliacao_ajuda_indicadores INT NULL CHECK (avaliacao_ajuda_indicadores BETWEEN 1 AND 5);
        PRINT '  ✓ Campo avaliacao_ajuda_indicadores adicionado';
    END
    ELSE PRINT '  - Campo avaliacao_ajuda_indicadores já existe';

    -- 6. comentario_eixo_e
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'comentario_eixo_e'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD comentario_eixo_e NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo comentario_eixo_e adicionado';
    END
    ELSE PRINT '  - Campo comentario_eixo_e já existe';

    -- 7. comentario_final
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('formulario_extensionista') 
        AND name = 'comentario_final'
    )
    BEGIN
        ALTER TABLE formulario_extensionista ADD comentario_final NVARCHAR(MAX) NULL;
        PRINT '  ✓ Campo comentario_final adicionado';
    END
    ELSE PRINT '  - Campo comentario_final já existe';

    PRINT '';
    PRINT 'EIXO E: Concluído (7 campos)';
    PRINT '';

    -- ========================================
    -- CRIAR/ATUALIZAR VIEWS ANALÍTICAS
    -- ========================================
    PRINT 'ATUALIZANDO VIEWS ANALÍTICAS...';
    PRINT '';

    -- Views do Eixo A
    IF OBJECT_ID('vw_analise_metodos_ater', 'V') IS NOT NULL DROP VIEW vw_analise_metodos_ater;
    EXEC('CREATE VIEW vw_analise_metodos_ater AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater, f.territorio,
        f.metodos_frequentes, f.metodos_melhores_resultados,
        f.dificuldade_falta_tempo, f.dificuldade_falta_recursos,
        f.dificuldade_resistencia_produtores, f.dificuldade_falta_capacitacao,
        CASE 
            WHEN f.dificuldade_falta_tempo >= 4 OR f.dificuldade_falta_recursos >= 4 THEN ''Alta''
            WHEN f.dificuldade_falta_tempo >= 3 OR f.dificuldade_falta_recursos >= 3 THEN ''Média''
            ELSE ''Baixa''
        END AS intensidade_dificuldade_recursos
    FROM formulario_extensionista f WHERE f.status = ''completo'';');
    PRINT '  ✓ View vw_analise_metodos_ater criada';

    IF OBJECT_ID('vw_metodos_por_municipio', 'V') IS NOT NULL DROP VIEW vw_metodos_por_municipio;
    EXEC('CREATE VIEW vw_metodos_por_municipio AS
    SELECT 
        f.municipio, f.territorio,
        COUNT(*) AS total_respostas,
        AVG(CAST(f.dificuldade_falta_tempo AS FLOAT)) AS media_dificuldade_tempo,
        AVG(CAST(f.dificuldade_falta_recursos AS FLOAT)) AS media_dificuldade_recursos,
        AVG(CAST(f.dificuldade_falta_capacitacao AS FLOAT)) AS media_dificuldade_capacitacao
    FROM formulario_extensionista f WHERE f.status = ''completo''
    GROUP BY f.municipio, f.territorio;');
    PRINT '  ✓ View vw_metodos_por_municipio criada';

    IF OBJECT_ID('vw_dificuldades_criticas', 'V') IS NOT NULL DROP VIEW vw_dificuldades_criticas;
    EXEC('CREATE VIEW vw_dificuldades_criticas AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater,
        f.dificuldade_falta_tempo, f.dificuldade_falta_recursos,
        f.dificuldade_resistencia_produtores, f.dificuldade_falta_capacitacao,
        f.comentario_eixo_a, f.created_at
    FROM formulario_extensionista f
    WHERE f.status = ''completo''
      AND (f.dificuldade_falta_tempo >= 4 OR f.dificuldade_falta_recursos >= 4 
           OR f.dificuldade_resistencia_produtores >= 4 OR f.dificuldade_falta_capacitacao >= 4);');
    PRINT '  ✓ View vw_dificuldades_criticas criada';

    -- Views do Eixo B
    IF OBJECT_ID('vw_analise_equidade_priorizacao', 'V') IS NOT NULL DROP VIEW vw_analise_equidade_priorizacao;
    EXEC('CREATE VIEW vw_analise_equidade_priorizacao AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater, f.territorio,
        f.priorizacao_atendimentos, f.nivel_equidade, f.instrumentos_formais,
        CASE 
            WHEN f.nivel_equidade >= 4 THEN ''Alta equidade''
            WHEN f.nivel_equidade = 3 THEN ''Moderada equidade''
            ELSE ''Baixa equidade''
        END AS classificacao_equidade,
        CASE 
            WHEN f.instrumentos_formais = ''sim_uso'' THEN ''Usa instrumentos formais''
            WHEN f.instrumentos_formais = ''nao_mas_conheco'' THEN ''Conhece mas não usa''
            ELSE ''Não conhece''
        END AS situacao_instrumentos
    FROM formulario_extensionista f WHERE f.status = ''completo'';');
    PRINT '  ✓ View vw_analise_equidade_priorizacao criada';

    IF OBJECT_ID('vw_criterios_por_municipio', 'V') IS NOT NULL DROP VIEW vw_criterios_por_municipio;
    EXEC('CREATE VIEW vw_criterios_por_municipio AS
    SELECT 
        f.municipio, f.territorio, COUNT(*) AS total_respostas,
        AVG(CAST(f.nivel_equidade AS FLOAT)) AS media_nivel_equidade,
        SUM(CASE WHEN f.instrumentos_formais = ''sim_uso'' THEN 1 ELSE 0 END) AS qtd_usa_instrumentos,
        SUM(CASE WHEN f.instrumentos_formais = ''nao_mas_conheco'' THEN 1 ELSE 0 END) AS qtd_conhece_nao_usa,
        SUM(CASE WHEN f.instrumentos_formais = ''nao_conheco'' THEN 1 ELSE 0 END) AS qtd_nao_conhece
    FROM formulario_extensionista f WHERE f.status = ''completo''
    GROUP BY f.municipio, f.territorio;');
    PRINT '  ✓ View vw_criterios_por_municipio criada';

    IF OBJECT_ID('vw_diagnostico_equidade_critica', 'V') IS NOT NULL DROP VIEW vw_diagnostico_equidade_critica;
    EXEC('CREATE VIEW vw_diagnostico_equidade_critica AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater, f.nivel_equidade,
        f.instrumentos_formais, f.priorizacao_atendimentos, f.comentario_eixo_b
    FROM formulario_extensionista f
    WHERE f.status = ''completo''
      AND (f.nivel_equidade <= 2 OR f.instrumentos_formais = ''nao_conheco'');');
    PRINT '  ✓ View vw_diagnostico_equidade_critica criada';

    -- Views do Eixo E
    IF OBJECT_ID('vw_analise_instrumentos_indicadores', 'V') IS NOT NULL DROP VIEW vw_analise_instrumentos_indicadores;
    EXEC('CREATE VIEW vw_analise_instrumentos_indicadores AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater, f.territorio,
        f.instrumentos_acompanhamento, f.freq_uso_indicadores,
        f.avaliacao_ajuda_indicadores, f.principais_indicadores,
        CASE 
            WHEN f.freq_uso_indicadores IN (''sempre'', ''frequentemente'') THEN ''Alto''
            WHEN f.freq_uso_indicadores = ''as_vezes'' THEN ''Médio''
            ELSE ''Baixo''
        END AS nivel_uso,
        CASE 
            WHEN f.avaliacao_ajuda_indicadores >= 4 THEN ''Alta utilidade''
            WHEN f.avaliacao_ajuda_indicadores = 3 THEN ''Moderada utilidade''
            ELSE ''Baixa utilidade''
        END AS classificacao_utilidade
    FROM formulario_extensionista f WHERE f.status = ''completo'';');
    PRINT '  ✓ View vw_analise_instrumentos_indicadores criada';

    IF OBJECT_ID('vw_instrumentos_por_municipio', 'V') IS NOT NULL DROP VIEW vw_instrumentos_por_municipio;
    EXEC('CREATE VIEW vw_instrumentos_por_municipio AS
    SELECT 
        f.municipio, f.territorio, COUNT(*) AS total_respostas,
        AVG(CAST(f.avaliacao_ajuda_indicadores AS FLOAT)) AS media_avaliacao_ajuda,
        SUM(CASE WHEN f.freq_uso_indicadores IN (''sempre'', ''frequentemente'') THEN 1 ELSE 0 END) AS alto_uso,
        SUM(CASE WHEN f.freq_uso_indicadores = ''as_vezes'' THEN 1 ELSE 0 END) AS medio_uso,
        SUM(CASE WHEN f.freq_uso_indicadores IN (''raramente'', ''nunca'') THEN 1 ELSE 0 END) AS baixo_uso
    FROM formulario_extensionista f WHERE f.status = ''completo''
    GROUP BY f.municipio, f.territorio;');
    PRINT '  ✓ View vw_instrumentos_por_municipio criada';

    IF OBJECT_ID('vw_diagnostico_baixo_uso_indicadores', 'V') IS NOT NULL DROP VIEW vw_diagnostico_baixo_uso_indicadores;
    EXEC('CREATE VIEW vw_diagnostico_baixo_uso_indicadores AS
    SELECT 
        f.protocolo, f.municipio, f.unidade_emater,
        f.freq_uso_indicadores, f.avaliacao_ajuda_indicadores,
        f.instrumentos_acompanhamento, f.comentario_eixo_e,
        CASE 
            WHEN f.freq_uso_indicadores = ''nunca'' AND f.avaliacao_ajuda_indicadores <= 2 
                THEN ''CRÍTICO: Não usa e não vê utilidade''
            WHEN f.freq_uso_indicadores IN (''nunca'', ''raramente'') 
                THEN ''ALERTA: Baixo uso de indicadores''
            WHEN f.avaliacao_ajuda_indicadores <= 2 
                THEN ''ATENÇÃO: Baixa percepção de utilidade''
        END AS diagnostico
    FROM formulario_extensionista f
    WHERE f.status = ''completo''
      AND (f.freq_uso_indicadores IN (''nunca'', ''raramente'') 
           OR f.avaliacao_ajuda_indicadores <= 2);');
    PRINT '  ✓ View vw_diagnostico_baixo_uso_indicadores criada';

    PRINT '';
    PRINT 'VIEWS: Concluídas (9 views analíticas)';
    PRINT '';

    -- ========================================
    -- CRIAR ÍNDICES
    -- ========================================
    PRINT 'CRIANDO ÍNDICES DE PERFORMANCE...';
    PRINT '';

    -- Índices Eixo A
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_metodos_frequentes' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_metodos_frequentes ON formulario_extensionista(metodos_frequentes(255)) 
        INCLUDE (municipio, unidade_emater);
        PRINT '  ✓ Índice idx_metodos_frequentes criado';
    END
    ELSE PRINT '  - Índice idx_metodos_frequentes já existe';

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_dificuldade_falta_tempo' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_dificuldade_falta_tempo ON formulario_extensionista(dificuldade_falta_tempo) 
        INCLUDE (municipio, dificuldade_falta_recursos);
        PRINT '  ✓ Índice idx_dificuldade_falta_tempo criado';
    END
    ELSE PRINT '  - Índice idx_dificuldade_falta_tempo já existe';

    -- Índices Eixo B
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_nivel_equidade' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_nivel_equidade ON formulario_extensionista(nivel_equidade) 
        INCLUDE (municipio, unidade_emater);
        PRINT '  ✓ Índice idx_nivel_equidade criado';
    END
    ELSE PRINT '  - Índice idx_nivel_equidade já existe';

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_instrumentos_formais' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_instrumentos_formais ON formulario_extensionista(instrumentos_formais) 
        INCLUDE (municipio, nivel_equidade);
        PRINT '  ✓ Índice idx_instrumentos_formais criado';
    END
    ELSE PRINT '  - Índice idx_instrumentos_formais já existe';

    -- Índices Eixo E
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_freq_uso_indicadores' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_freq_uso_indicadores ON formulario_extensionista(freq_uso_indicadores) 
        INCLUDE (municipio, unidade_emater, avaliacao_ajuda_indicadores);
        PRINT '  ✓ Índice idx_freq_uso_indicadores criado';
    END
    ELSE PRINT '  - Índice idx_freq_uso_indicadores já existe';

    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_avaliacao_ajuda_indicadores' AND object_id = OBJECT_ID('formulario_extensionista'))
    BEGIN
        CREATE INDEX idx_avaliacao_ajuda_indicadores ON formulario_extensionista(avaliacao_ajuda_indicadores) 
        INCLUDE (municipio, freq_uso_indicadores);
        PRINT '  ✓ Índice idx_avaliacao_ajuda_indicadores criado';
    END
    ELSE PRINT '  - Índice idx_avaliacao_ajuda_indicadores já existe';

    PRINT '';
    PRINT 'ÍNDICES: Concluídos (6 índices)';
    PRINT '';

    -- ========================================
    -- VERIFICAÇÃO FINAL
    -- ========================================
    PRINT '========================================';
    PRINT 'VERIFICANDO ESTRUTURA FINAL DA TABELA';
    PRINT '========================================';
    PRINT '';

    SELECT 
        'formulario_extensionista' AS tabela,
        COUNT(*) AS total_colunas
    FROM sys.columns 
    WHERE object_id = OBJECT_ID('formulario_extensionista');

    PRINT '';
    PRINT '========================================';
    PRINT 'RESUMO DA ATUALIZAÇÃO';
    PRINT '========================================';
    PRINT '';
    PRINT 'CAMPOS ADICIONADOS:';
    PRINT '  • Eixo A: 12 campos (metodologias, dificuldades)';
    PRINT '  • Eixo B: 6 campos (equidade, priorização)';
    PRINT '  • Eixo E: 7 campos (indicadores, avaliação)';
    PRINT '  TOTAL: 25 novos campos';
    PRINT '';
    PRINT 'VIEWS ANALÍTICAS: 9 views criadas';
    PRINT 'ÍNDICES: 6 índices de performance criados';
    PRINT '';
    PRINT '========================================';
    PRINT 'ATUALIZAÇÃO CONCLUÍDA COM SUCESSO!';
    PRINT 'Timestamp: ' + CONVERT(VARCHAR, GETDATE(), 120);
    PRINT '========================================';

    COMMIT TRANSACTION;
    PRINT '';
    PRINT '✓ TRANSAÇÃO COMMITADA';
    
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT '';
    PRINT '✗ ERRO DURANTE ATUALIZAÇÃO!';
    PRINT 'Erro: ' + ERROR_MESSAGE();
    PRINT 'Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'TRANSAÇÃO REVERTIDA (ROLLBACK)';
    THROW;
END CATCH;
GO
