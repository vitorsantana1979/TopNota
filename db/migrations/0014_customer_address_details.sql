-- 0014_customer_address_details.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.customers', 'address_zip') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_zip VARCHAR(8) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_state') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_state NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_state_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_state_ibge NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_city') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_city NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_city_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_city_ibge NVARCHAR(7) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_district') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_district NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_street') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_street NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_number') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_number NVARCHAR(20) NULL;
END
IF COL_LENGTH('dbo.customers', 'address_complement') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD address_complement NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.customers', 'codigo_municipio_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.customers ADD codigo_municipio_ibge NVARCHAR(7) NULL;
END
