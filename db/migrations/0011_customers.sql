-- 0011_customers.sql
SET ANSI_PADDING ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[customers]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.customers (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        tenant_id UNIQUEIDENTIFIER NOT NULL,
        document NVARCHAR(20) NOT NULL,
        name NVARCHAR(200) NOT NULL,
        email NVARCHAR(200) NULL,
        phone NVARCHAR(50) NULL,
        address NVARCHAR(500) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_customers_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants(id)
    );
    CREATE UNIQUE INDEX UX_customers_tenant_document ON dbo.customers(tenant_id, document);
    CREATE INDEX IX_customers_tenant_name ON dbo.customers(tenant_id, name);
END
GO

IF COL_LENGTH('dbo.invoices', 'customer_id') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.invoices ADD customer_id UNIQUEIDENTIFIER NULL');
END
GO

IF COL_LENGTH('dbo.invoices', 'customer_id') IS NOT NULL
    AND COL_LENGTH('dbo.invoices', 'tomador_documento') IS NOT NULL
BEGIN
    DECLARE @sql NVARCHAR(MAX) = N'
    ;WITH src AS (
        SELECT DISTINCT tenant_id, tomador_documento AS document, tomador_nome AS name
        FROM dbo.invoices
        WHERE tomador_documento IS NOT NULL AND LEN(LTRIM(RTRIM(tomador_documento))) > 0
    )
    INSERT INTO dbo.customers (id, tenant_id, document, name)
    SELECT NEWID(), s.tenant_id, s.document, ISNULL(NULLIF(LTRIM(RTRIM(s.name)), ''''), s.document)
    FROM src s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.customers c WHERE c.tenant_id = s.tenant_id AND c.document = s.document
    );

    UPDATE i
    SET customer_id = c.id
    FROM dbo.invoices i
    JOIN dbo.customers c ON c.tenant_id = i.tenant_id AND c.document = i.tomador_documento
    WHERE i.customer_id IS NULL AND i.tomador_documento IS NOT NULL;
    ';
    EXEC sp_executesql @sql;
END
GO

IF COL_LENGTH('dbo.invoices', 'customer_id') IS NOT NULL
    AND NOT EXISTS (SELECT 1 FROM dbo.invoices WHERE customer_id IS NULL)
BEGIN
    EXEC('ALTER TABLE dbo.invoices ALTER COLUMN customer_id UNIQUEIDENTIFIER NOT NULL');
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_invoices_customer'
)
BEGIN
    ALTER TABLE dbo.invoices ADD CONSTRAINT FK_invoices_customer FOREIGN KEY (customer_id) REFERENCES dbo.customers(id);
END
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_invoices_customer_id' AND object_id = OBJECT_ID('dbo.invoices')
)
BEGIN
    CREATE INDEX IX_invoices_customer_id ON dbo.invoices(customer_id);
END
GO

IF COL_LENGTH('dbo.invoices', 'tomador_documento') IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.invoices DROP COLUMN tomador_documento');
END
GO

IF COL_LENGTH('dbo.invoices', 'tomador_nome') IS NOT NULL
BEGIN
    EXEC('ALTER TABLE dbo.invoices DROP COLUMN tomador_nome');
END
GO
