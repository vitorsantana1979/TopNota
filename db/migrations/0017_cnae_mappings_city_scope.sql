-- 0017_cnae_mappings_city_scope.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.cnae_mappings', 'city_ibge_code') IS NULL
BEGIN
    ALTER TABLE dbo.cnae_mappings ADD city_ibge_code NVARCHAR(7) NULL;
    UPDATE dbo.cnae_mappings SET city_ibge_code = '0000000' WHERE city_ibge_code IS NULL;
    ALTER TABLE dbo.cnae_mappings ALTER COLUMN city_ibge_code NVARCHAR(7) NOT NULL;

    DECLARE @pkName NVARCHAR(128);
    SELECT @pkName = kc.name
    FROM sys.key_constraints kc
    WHERE kc.parent_object_id = OBJECT_ID(N'dbo.cnae_mappings') AND kc.type = 'PK';

    IF @pkName IS NOT NULL
    BEGIN
        DECLARE @dropSql NVARCHAR(400);
        SET @dropSql = N'ALTER TABLE dbo.cnae_mappings DROP CONSTRAINT ' + QUOTENAME(@pkName) + ';';
        EXEC sp_executesql @dropSql;
    END

    ALTER TABLE dbo.cnae_mappings ADD CONSTRAINT PK_cnae_mappings PRIMARY KEY (city_ibge_code, cnae);

    IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_cnae_mappings_item_codigo' AND object_id = OBJECT_ID(N'dbo.cnae_mappings'))
    BEGIN
        DROP INDEX IX_cnae_mappings_item_codigo ON dbo.cnae_mappings;
    END

    CREATE INDEX IX_cnae_mappings_city_item_codigo ON dbo.cnae_mappings(city_ibge_code, item_codigo);
END
