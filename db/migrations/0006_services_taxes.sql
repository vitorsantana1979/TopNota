-- 0006_services_taxes.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.services','aliquota_pis') IS NULL
BEGIN
  ALTER TABLE dbo.services ADD aliquota_pis DECIMAL(7,4) NULL;
END
IF COL_LENGTH('dbo.services','aliquota_cofins') IS NULL
BEGIN
  ALTER TABLE dbo.services ADD aliquota_cofins DECIMAL(7,4) NULL;
END
IF COL_LENGTH('dbo.services','aliquota_csll') IS NULL
BEGIN
  ALTER TABLE dbo.services ADD aliquota_csll DECIMAL(7,4) NULL;
END
IF COL_LENGTH('dbo.services','aliquota_irrf') IS NULL
BEGIN
  ALTER TABLE dbo.services ADD aliquota_irrf DECIMAL(7,4) NULL;
END

