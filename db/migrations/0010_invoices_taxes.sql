-- 0010_invoices_taxes.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.invoices','aliquota_iss') IS NULL
BEGIN
  ALTER TABLE dbo.invoices ADD aliquota_iss DECIMAL(7,4) NULL;
END
IF COL_LENGTH('dbo.invoices','valor_pis') IS NULL
BEGIN
  ALTER TABLE dbo.invoices ADD valor_pis DECIMAL(18,2) NULL;
END
IF COL_LENGTH('dbo.invoices','valor_cofins') IS NULL
BEGIN
  ALTER TABLE dbo.invoices ADD valor_cofins DECIMAL(18,2) NULL;
END
IF COL_LENGTH('dbo.invoices','valor_csll') IS NULL
BEGIN
  ALTER TABLE dbo.invoices ADD valor_csll DECIMAL(18,2) NULL;
END
IF COL_LENGTH('dbo.invoices','valor_irrf') IS NULL
BEGIN
  ALTER TABLE dbo.invoices ADD valor_irrf DECIMAL(18,2) NULL;
END

