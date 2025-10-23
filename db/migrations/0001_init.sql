-- 0001_init.sql
-- Base tables: tenants, stores, email_settings

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tenants]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.tenants (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        name NVARCHAR(200) NOT NULL,
        cnpj VARCHAR(14) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[stores]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.stores (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        tenant_id UNIQUEIDENTIFIER NOT NULL,
        name NVARCHAR(200) NOT NULL,
        cnpj VARCHAR(14) NULL,
        im VARCHAR(30) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_stores_tenants FOREIGN KEY (tenant_id) REFERENCES dbo.tenants(id)
    );
    CREATE INDEX IX_stores_tenant_id ON dbo.stores(tenant_id);
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[email_settings]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.email_settings (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        tenant_id UNIQUEIDENTIFIER NULL,
        store_id UNIQUEIDENTIFIER NULL,
        host NVARCHAR(255) NOT NULL,
        port INT NOT NULL,
        username NVARCHAR(255) NULL,
        password_encrypted VARBINARY(MAX) NULL,
        from_name NVARCHAR(255) NOT NULL,
        from_email NVARCHAR(255) NOT NULL,
        use_ssl BIT NOT NULL DEFAULT 1,
        use_starttls BIT NOT NULL DEFAULT 0,
        is_active BIT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_email_settings_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants(id),
        CONSTRAINT FK_email_settings_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id),
        CONSTRAINT CK_email_settings_scope CHECK ((tenant_id IS NOT NULL AND store_id IS NULL) OR (tenant_id IS NOT NULL AND store_id IS NOT NULL))
    );
    -- Garantir unicidade por escopo (requer QUOTED_IDENTIFIER e ANSI_NULLS ON)
    SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;
    CREATE UNIQUE INDEX UX_email_settings_store ON dbo.email_settings(store_id) WHERE store_id IS NOT NULL;
    CREATE UNIQUE INDEX UX_email_settings_tenant ON dbo.email_settings(tenant_id) WHERE store_id IS NULL AND tenant_id IS NOT NULL;
END
