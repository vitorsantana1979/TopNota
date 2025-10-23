-- 0002_nfse_init.sql
-- RPS sequences and basic NFSe tables

SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[rps_sequences]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.rps_sequences (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        store_id UNIQUEIDENTIFIER NOT NULL,
        serie NVARCHAR(10) NOT NULL,
        proximo_numero INT NOT NULL DEFAULT 1,
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_rps_sequences_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id)
    );
    CREATE UNIQUE INDEX UX_rps_sequences_store_serie ON dbo.rps_sequences(store_id, serie);
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[invoices]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.invoices (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        tenant_id UNIQUEIDENTIFIER NOT NULL,
        store_id UNIQUEIDENTIFIER NOT NULL,
        rps_serie NVARCHAR(10) NOT NULL,
        rps_numero INT NOT NULL,
        status NVARCHAR(30) NOT NULL,
        numero_nfse NVARCHAR(50) NULL,
        codigo_verificacao NVARCHAR(50) NULL,
        tomador_documento NVARCHAR(20) NULL,
        tomador_nome NVARCHAR(200) NULL,
        valor_servico DECIMAL(18,2) NULL,
        xml_envio NVARCHAR(MAX) NULL,
        xml_retorno NVARCHAR(MAX) NULL,
        data_emissao DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_invoices_tenant FOREIGN KEY (tenant_id) REFERENCES dbo.tenants(id),
        CONSTRAINT FK_invoices_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id)
    );
    CREATE UNIQUE INDEX UX_invoices_store_rps ON dbo.invoices(store_id, rps_serie, rps_numero);
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[invoice_items]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.invoice_items (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        invoice_id UNIQUEIDENTIFIER NOT NULL,
        descricao NVARCHAR(500) NOT NULL,
        quantidade DECIMAL(18,2) NOT NULL,
        valor_unit DECIMAL(18,2) NOT NULL,
        valor_total AS (ROUND(quantidade * valor_unit, 2)) PERSISTED,
        CONSTRAINT FK_invoice_items_invoice FOREIGN KEY (invoice_id) REFERENCES dbo.invoices(id)
    );
    CREATE INDEX IX_invoice_items_invoice ON dbo.invoice_items(invoice_id);
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[soap_logs]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.soap_logs (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        system NVARCHAR(50) NOT NULL,
        action NVARCHAR(50) NOT NULL,
        status_code INT NULL,
        duration_ms INT NULL,
        request_masked NVARCHAR(MAX) NULL,
        response_masked NVARCHAR(MAX) NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
    );
END

