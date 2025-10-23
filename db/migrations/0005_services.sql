-- 0005_services.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[services]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.services (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        tenant_id UNIQUEIDENTIFIER NOT NULL,
        store_id UNIQUEIDENTIFIER NULL,
        item_lista_servico NVARCHAR(10) NOT NULL,
        codigo_tributacao_municipio NVARCHAR(30) NULL,
        descricao NVARCHAR(255) NOT NULL,
        cnae NVARCHAR(20) NULL,
        aliquota_iss DECIMAL(7,4) NULL, -- ex: 0.0200 = 2%
        iss_retido BIT NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_services_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants(id),
        CONSTRAINT FK_services_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id)
    );
    CREATE INDEX IX_services_tenant ON dbo.services(tenant_id);
    CREATE UNIQUE INDEX UX_services_scope_code ON dbo.services(tenant_id, store_id, item_lista_servico);
END

