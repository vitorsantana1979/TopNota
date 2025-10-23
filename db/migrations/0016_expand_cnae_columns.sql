-- 0016_expand_cnae_columns.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.cnae_mappings', 'atividade') < 2000
BEGIN
    ALTER TABLE dbo.cnae_mappings ALTER COLUMN atividade NVARCHAR(2000) NOT NULL;
END

IF COL_LENGTH('dbo.cnae_mappings', 'item_descricao') < 2000
BEGIN
    ALTER TABLE dbo.cnae_mappings ALTER COLUMN item_descricao NVARCHAR(2000) NOT NULL;
END

IF COL_LENGTH('dbo.cnae_mappings', 'observacao') < 2000
BEGIN
    ALTER TABLE dbo.cnae_mappings ALTER COLUMN observacao NVARCHAR(2000) NULL;
END
