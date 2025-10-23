GynNota — Onboarding Rápido

1) Inicialização (apenas uma vez)
- Se o banco estiver vazio de usuários:
  - POST /api/v1/auth/bootstrap
    - { "username": "admin", "password": "<senha>", "displayName": "Admin" }

2) Login
- POST /api/v1/auth/login
  - { "username": "admin", "password": "<senha>" }
- Copie o token JWT e use no Swagger (Authorize) ou no frontend (/login)

3) Selecionar contexto
- No frontend, ajuste a API Base URL.
- Selecione Empresa e Loja no topo.

4) Certificado e E-mail
- Certificado A1 por loja: /certificados
- E-mail (tenant/store): /email

5) Serviços (catálogo)
- Cadastre item/código e alíquotas (ISS/PIS/COFINS/CSLL/IRRF) em /services

6) Emissão de NFS-e
- Tela /nfse (emissão e pré-visualização de PDF)
- Notas emitidas em /nfse-enviadas (PDF/XML/reenviar e-mail)

7) Logs de Integração
- /logs — ver requests/responses mascarados das integrações SOAP

8) RBAC
- Perfis padrão: Admin, EmpresaAdmin, LojaGestor, Operador, Auditor
- Admin gerencia usuários e atribuições em /usuarios
- Atribuições podem ser Global, por Empresa (X-Tenant-Id) ou por Loja (X-Store-Id)

