-- 0008_user_roles_scope.sql
SET ANSI_PADDING ON; SET ANSI_NULLS ON; SET QUOTED_IDENTIFIER ON;

IF COL_LENGTH('dbo.user_roles','tenant_id') IS NULL
BEGIN
  ALTER TABLE dbo.user_roles ADD tenant_id UNIQUEIDENTIFIER NULL, store_id UNIQUEIDENTIFIER NULL;
END

IF NOT EXISTS (
  SELECT 1 FROM sys.indexes WHERE name = 'UX_user_roles_scope' AND object_id = OBJECT_ID('dbo.user_roles')
)
BEGIN
  CREATE UNIQUE INDEX UX_user_roles_scope ON dbo.user_roles(user_id, role_id, tenant_id, store_id);
END

