-- 0012_tenant_store_details.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.tenants', 'responsible_name') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD responsible_name NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.tenants', 'responsible_email') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD responsible_email NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.tenants', 'phone') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD phone NVARCHAR(50) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_zip') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_zip VARCHAR(8) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_state') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_state NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_city') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_city NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_district') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_district NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_street') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_street NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_number') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_number NVARCHAR(20) NULL;
END
IF COL_LENGTH('dbo.tenants', 'address_complement') IS NULL
BEGIN
    ALTER TABLE dbo.tenants ADD address_complement NVARCHAR(100) NULL;
END

IF COL_LENGTH('dbo.stores', 'phone') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD phone NVARCHAR(50) NULL;
END
IF COL_LENGTH('dbo.stores', 'email') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD email NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_zip') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_zip VARCHAR(8) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_state') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_state NVARCHAR(2) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_city') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_city NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_district') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_district NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_street') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_street NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_number') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_number NVARCHAR(20) NULL;
END
IF COL_LENGTH('dbo.stores', 'address_complement') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD address_complement NVARCHAR(100) NULL;
END
IF COL_LENGTH('dbo.stores', 'responsible_name') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD responsible_name NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.stores', 'responsible_email') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD responsible_email NVARCHAR(200) NULL;
END
IF COL_LENGTH('dbo.stores', 'responsible_phone') IS NULL
BEGIN
    ALTER TABLE dbo.stores ADD responsible_phone NVARCHAR(50) NULL;
END
