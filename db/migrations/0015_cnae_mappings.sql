-- 0015_cnae_mappings.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[cnae_mappings]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.cnae_mappings (
        cnae NVARCHAR(20) NOT NULL PRIMARY KEY,
        atividade NVARCHAR(500) NOT NULL,
        item_codigo NVARCHAR(10) NOT NULL,
        item_descricao NVARCHAR(500) NOT NULL,
        aliquota_iss DECIMAL(7,4) NULL,
        retencao_obrigatoria BIT NULL,
        observacao NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
    CREATE INDEX IX_cnae_mappings_item_codigo ON dbo.cnae_mappings(item_codigo);
END
