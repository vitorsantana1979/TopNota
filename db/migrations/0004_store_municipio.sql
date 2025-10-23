-- 0004_store_municipio.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.stores','codigo_municipio_ibge') IS NULL
BEGIN
  ALTER TABLE dbo.stores ADD codigo_municipio_ibge VARCHAR(7) NULL;
END

