-- 0013_address_ibge_codes.sql - add IBGE codes for tenant/store addresses
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.tenants', 'address_state_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_state_ibge NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_city_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_city_ibge NVARCHAR(7) NULL;
END

IF COL_LENGTH('dbo.stores', 'address_state_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_state_ibge NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_city_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_city_ibge NVARCHAR(7) NULL;
END

-- ensure codigo_municipio_ibge column exists; if not, create it
IF COL_LENGTH('dbo.tenants', 'codigo_municipio_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD codigo_municipio_ibge NVARCHAR(7) NULL;
END
IF COL_LENGTH('dbo.stores', 'codigo_municipio_ibge') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD codigo_municipio_ibge NVARCHAR(7) NULL;
END
