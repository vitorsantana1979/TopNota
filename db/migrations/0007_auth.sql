-- 0007_auth.sql - basic auth tables
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U'))
BEGIN
  CREATE TABLE dbo.users (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    display_name NVARCHAR(200) NULL,
    password_hash VARBINARY(256) NOT NULL,
    password_salt VARBINARY(128) NOT NULL,
    is_active BIT NOT NULL DEFAULT 1,
    created_at DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME()
  );
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
  CREATE TABLE dbo.roles (
    id UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID() PRIMARY KEY,
    name NVARCHAR(100) NOT NULL UNIQUE
  );
  INSERT INTO dbo.roles (name) VALUES ('Admin'), ('EmpresaAdmin'), ('LojaGestor'), ('Operador'), ('Auditor');
END

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[user_roles]') AND type in (N'U'))
BEGIN
  CREATE TABLE dbo.user_roles (
    user_id UNIQUEIDENTIFIER NOT NULL,
    role_id UNIQUEIDENTIFIER NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT FK_user_roles_user FOREIGN KEY (user_id) REFERENCES dbo.users(id),
    CONSTRAINT FK_user_roles_role FOREIGN KEY (role_id) REFERENCES dbo.roles(id)
  );
END

