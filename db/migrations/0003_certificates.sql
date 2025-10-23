-- 0003_certificates.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[certificates]') AND type in (N'U'))
BEGIN
    CREATE TABLE dbo.certificates (
        id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
        store_id UNIQUEIDENTIFIER NOT NULL,
        name NVARCHAR(200) NULL,
        pfx_encrypted VARBINARY(MAX) NOT NULL,
        password_encrypted VARBINARY(MAX) NULL,
        thumbprint NVARCHAR(100) NULL,
        subject NVARCHAR(500) NULL,
        not_before DATETIME2 NULL,
        not_after DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        updated_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
        CONSTRAINT FK_certificates_store FOREIGN KEY (store_id) REFERENCES dbo.stores(id)
    );
    CREATE UNIQUE INDEX UX_certificates_store ON dbo.certificates(store_id);
END

