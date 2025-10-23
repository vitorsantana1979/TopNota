# Especificação do Projeto --- Emissão de NFS-e Goiânia (Multiempresa/Multiloja)

**Objetivo:** Entregar uma plataforma web (frontend React + API .NET 8) que permita a gestão multiempresa/multiloja e o ciclo completo de emissão, consulta e divulgação de NFS-e do município de Goiânia, com suporte a certificados A1, envio de e-mails e integrações auxiliares de dados cadastrais.

------------------------------------------------------------------------

## 1) Escopo Funcional

### 1.1 Multiempresa / Multiloja
- Cadastro, listagem e seleção de empresas (`/api/v1/tenants`) com identificação por CNPJ e suporte a upload de logotipo corporativo (armazenado em `tenants.logo` e utilizado nos PDFs).
- Cadastro e manutenção de lojas (`/api/v1/stores`) vinculadas a uma empresa, com CNPJ, Inscrição Municipal e código IBGE; atualização controlada por papéis `EmpresaAdmin` / `LojaGestor`.
- Sequenciamento de RPS por loja e série (`rps_sequences`) reaproveitado tanto pelo endpoint dedicado (`/api/v1/rps/allocate`) quanto pelo fluxo de emissão.
- O contexto ativo (empresa/loja) é transportado pelos headers `X-Tenant-Id` e `X-Store-Id`, consumido em regras de autorização e filtros de dados no backend e persistido no frontend via `TenantStoreSelector`.

### 1.2 Usuários, Autenticação e Perfis
- Autenticação JWT (`POST /api/v1/auth/login`) com hashing de senha + salt (PBKDF via `PasswordHasher`) e bootstrap do primeiro usuário/administrador (`POST /auth/bootstrap`).
- Gestão completa de usuários (`/api/v1/users`): criação, listagem, ativação/desativação, reset de senha e atribuição de roles.
- Modelagem de papéis com escopo (`Admin`, `EmpresaAdmin`, `LojaGestor`, `Operador`, `Auditor`) usando `ScopedRoleRequirement` e `MultiScopedRolesRequirement`, garantindo acesso condicionado ao tenant/loja presente nos headers.
- Troca de senha pelo próprio usuário autenticado (`POST /auth/change-password`) com verificação da senha atual.

### 1.3 Configuração de E-mail
- Configuração hierárquica de SMTP (`/api/v1/email-settings`): preferencialmente por loja, com fallback para configurações da empresa.
- Persistência segura de credenciais (senha criptografada com AES e armazenada em `email_settings.password_encrypted`).
- API e UI para testar envio (`POST /api/v1/email-settings/test`), reutilizando a mesma infraestrutura de envio utilizada pelo fluxo de NFS-e.
- Sinalização do escopo efetivo (tenant ou loja) para o usuário final na interface.

### 1.4 Certificados Digitais A1
- Upload e atualização de certificados `.pfx` por loja (`/api/v1/stores/{id}/certificates`) com validação da senha e extração de metadados (thumbprint, subject, validade).
- Criptografia do arquivo e da senha no banco (AES via `AesEncryptionService`), com único certificado ativo por loja.
- Exibição na UI dos metadados e do status de validade para acompanhamento operacional.

### 1.5 Tomadores (Clientes)
- Cadastro e manutenção de tomadores por empresa (`/api/v1/customers`), com validação de CPF/CNPJ único por tenant e campos adicionais (e-mail, telefone, endereço).
- Pesquisa dinâmica por razão social ou documento durante a emissão, permitindo selecionar tomadores existentes.
- Criação rápida de tomador diretamente pela tela de emissão ou via módulo dedicado “Tomadores”.
- Relação 1:N entre empresas e tomadores; notas fiscais referenciam o tomador por meio de `customer_id`.

### 1.6 Catálogo de Serviços e Tributação
- Cadastro de serviços (`/api/v1/services`) em nível de empresa ou loja, com informações de item da lista de serviço, código de tributação municipal, CNAE e alíquotas (ISS, PIS, COFINS, CSLL, IRRF).
- Utilização das configurações de serviço para preencher automaticamente dados fiscais durante a emissão, mantendo possibilidade de overrides por nota.
- Interface dedicada para manutenção, com filtros por escopo e indicadores visuais de retenção.

### 1.7 Emissão de NFS-e
- Interface de emissão (`/nfse`) permite montar o RPS, definir tomador, itens e tributos, além de pré-visualizar o PDF antes do envio.
- Backend (`NfseController.Emitir`) aloca número de RPS de forma transacional, persiste `invoices` e `invoice_items`, resolve regras fiscais do serviço selecionado, assina o XML com o certificado da loja e envia para o web service oficial (`INfseGynSoapClient`).
- Resposta do SOAP é armazenada, status da nota atualizado (`authorized`, `pending` ou `error`) e número/código de verificação preenchidos quando retornados.
- Geração de PDF oficial com logotipo da empresa via QuestPDF (`InvoicePdfGenerator`) imediatamente após autorização.

### 1.8 Consulta e Pós-emissão
- Listagem de notas emitidas (`GET /api/v1/nfse`) filtrada por loja e período, com download de PDF e XML de envio/retorno.
- Consulta por número da NFSe (`GET /api/v1/nfse/por-nfse`) com fallback para consulta remota caso não exista registro local.
- Reenvio de e-mail da nota (`POST /api/v1/nfse/{id}/reenviar-email`) com anexos configuráveis (PDF e/ou XML) reutilizando as configurações SMTP efetivas.

### 1.9 Logs e Auditoria
- Registro de requisições SOAP (`soap_logs`) com payload mascarado e metadados (status code, duração, data de criação).
- Interface administrativa (página “Logs”) para pesquisa por sistema/ação e inspeção detalhada dos requests/responses.
- Logging HTTP estruturado no backend via Serilog.

### 1.10 Integrações Auxiliares
- Consulta de CEP via ViaCEP com cache em memória.
- Consulta de CNPJ via BrasilAPI.
- Catálogo de UF/Municípios via IBGE com fallback para BrasilAPI e cache com expiração programada.
- Configuração centralizada de `HttpClientFactory` com base URLs oficiais e tratamento de falhas.

### 1.11 Portal Web (Frontend)
- SPA em React + Ant Design com roteamento protegido, alternância de tema claro/escuro e seletor persistido de empresa/loja.
- Gestão de URL base da API diretamente pelo usuário, facilitando apontamento para ambientes distintos.
- Páginas dedicadas: Tenants, Stores, Services, NFSe (emissão + listagem), Email Settings, Certificates, Logs e Users.

### 1.12 Limitações e Escopo Fora do Sistema
- Cancelamento de NFS-e continua externo (portal da prefeitura); o sistema apenas registra status manualmente.
- Não há ainda conciliação automática de retorno assíncrono ou processamento em lote.
- Relatórios analíticos além da listagem básica ainda não foram implementados.

------------------------------------------------------------------------

## 2) Requisitos Não Funcionais

### 2.1 Segurança
- Criptografia simétrica (AES/CBC) para certificados e senhas SMTP; chaves controladas por `CRYPTO_KEY`.
- Hashing de senhas de usuário com salt dedicado, mitigando ataques de dicionário.
- Autorização baseada em papéis com escopo, exigindo headers de contexto válidos e permitindo bypass apenas para administradores globais.
- JWT configurado com expiração curta (8h) e assinatura HMAC-SHA256 usando `JWT_SECRET`.
- Controle de tamanho para uploads (logo até 5 MB, certificado até 20 MB) e validação de conteúdo antes de persistência.

### 2.2 Resiliência e Performance
- Uso de caches em memória para CEP e dados do IBGE, reduzindo latência e chamada aos serviços externos.
- Fallback automático para provedores alternativos (BrasilAPI) quando integrações principais estão indisponíveis.
- Serialização e assinatura de XML otimizadas para evitar round-trips desnecessários.
- Geração de PDF in-memory, eliminando dependências em disco.

### 2.3 Observabilidade e Auditoria
- Serilog configurado para console com enriquecimento de contexto HTTP.
- Tabela `soap_logs` como trilha de auditoria das interações com a prefeitura.
- Endpoint dedicado para inspeção de logs, permitindo rastreabilidade de falhas operacionais.

### 2.4 Privacidade e LGPD
- Armazena apenas dados necessários para emissão fiscal (CNPJ/CPF, razão social, endereço derivado de CEP).
- Não há replicação de dados sensíveis de tomadores além do exigido pelo layout da NFS-e.
- Permite desativação de usuários e remoção de escopos para revogação de acesso.

### 2.5 Qualidade e Manutenibilidade
- Código dividido em camadas (`Api`, `Application`, `Domain`, `Infrastructure`) com DI explícita.
- Uso de `HttpClientFactory` para evitar socket exhaustion.
- Base de dados versionada via scripts `db/migrations`, facilitando reprodução em ambientes.

------------------------------------------------------------------------

## 3) Arquitetura e Tecnologias

### 3.1 Front-end
- React 19 + Vite, com Ant Design 5 para componentes UI.
- Provedor de API (`ApiProvider`) encapsula axios, inclui headers de autenticação e contexto, e trata automaticamente 401.
- Suporte a tema claro/escuro (`ThemeProvider`) e a persistência de preferências no `localStorage`.
- Integração com páginas SPA protegidas por `ProtectedLayout` e menu lateral condicional.

### 3.2 Back-end (API .NET)
- ASP.NET Core 8 com controllers REST organizados por domínio.
- Dapper para acesso ao SQL Server, conectando-se via `SqlConnectionFactory`.
- Assinatura XML via `System.Security.Cryptography.Xml` e envio SOAP por `HttpClient`.
- Envio de e-mail usando MailKit (SMTP), reaproveitando configurações criptografadas.
- Serilog + Swagger configurados; políticas de autorização personalizadas para RBAC com escopo.
- Geração de PDFs por QuestPDF (`InvoicePdfGenerator`) com logotipo da empresa.

### 3.3 Banco de Dados
- SQL Server como banco principal, com scripts versionados (`db/migrations`) cobrindo criação e evolução das tabelas.
- Estruturas principais: `tenants`, `stores`, `certificates`, `email_settings`, `services`, `users/roles/user_roles`, `rps_sequences`, `invoices`, `invoice_items`, `soap_logs`.
- Índices e constraints garantem unicidade por escopo e integridade referencial.

### 3.4 Integrações Externas
- Clientes HTTP nomeados (`brasilapi`, `viacep`, `ibge`, `nfse`) com base URLs e headers default.
- `INfseGynSoapClient` encapsula a montagem do envelope SOAP 1.1 para as operações `GerarNfse` e `ConsultarNfseRps`.
- Fallbacks implementados no controller de IBGE para manter disponibilidade.

### 3.5 Organização do Repositório
- `backend/` com solução .NET (`GynNota.sln`) e projetos `Api`, `Application`, `Domain`, `Infrastructure`.
- `frontend/` com projeto Vite, dependências npm e build TypeScript.
- `db/` com migrations e seeds (atualmente vazios) executáveis via `sqlcmd`.

------------------------------------------------------------------------

## 4) Fluxos Operacionais Principais

### 4.1 Onboarding de Empresa
1. Administrador global autentica e cadastra a empresa em “Empresas”.
2. Cadastra lojas relacionadas e define CNPJ/IM/código IBGE.
3. Faz upload do logotipo corporativo (opcional) usado em documentos e UI.
4. Configura SMTP em nível de empresa e testa o envio.
5. Cria usuários necessários e atribui roles escopadas conforme responsabilidade.
6. Para cada loja, envia o certificado A1 e (se necessário) sobrepõe configuração de e-mail específica.

### 4.2 Emissão de NFS-e
1. Operador seleciona empresa e loja no seletor global.
2. Na tela “Emitir NFS-e”, seleciona um tomador cadastrado (com busca por nome/documento), escolhe um serviço e ajusta tributos/itens conforme necessário.
3. Pré-visualiza o PDF para validação interna.
4. Confirma a emissão; o backend aloca RPS, envia ao web service, atualiza status e retorna número/código quando autorizado.
5. Em caso de pendência, operador pode consultar por RPS posteriormente para verificar processamento.

### 4.3 Pós-emissão e Atendimento
1. Tela “Notas Emitidas” permite filtro por período, download de PDF/XML e reenvio de e-mail ao cliente.
2. Logs SOAP possibilitam investigar falhas de integração com a prefeitura.
3. Usuário auditor pode exportar XMLs para conciliação manual quando necessário.

### 4.4 Administração Contínua
- Ajustes em serviços e tributação realizados pela área fiscal.
- Gestão contínua de usuários/roles e revisão de acessos.
- Monitoramento periódico de validade de certificados via tela de certificados.

------------------------------------------------------------------------

## 5) API --- Endpoints Principais

- **Auth (`/api/v1/auth`)**: `POST /login`, `POST /bootstrap`, `POST /change-password`.
- **Usuários (`/api/v1/users`)**: `GET /`, `POST /`, `GET /{id}`, `PUT /{id}`, `POST /{id}/reset-password`, `GET /roles`, `GET /{id}/roles`, `POST /{id}/roles`, `DELETE /{id}/roles`.
- **Empresas (`/api/v1/tenants`)**: `GET /`, `POST /`, `GET /{id}`, `POST /{id}/logo`, `GET /{id}/logo`.
- **Lojas (`/api/v1/stores`)**: `GET /` (com filtro `tenantId`), `POST /`, `GET /{id}`, `PUT /{id}`.
- **Serviços (`/api/v1/services`)**: `GET /`, `POST /`, `GET /{id}`, `PUT /{id}`, `DELETE /{id}`.
- **Tomadores (`/api/v1/customers`)**: `GET /` (com busca), `GET /{id}`, `POST /`, `PUT /{id}`, `DELETE /{id}`.
- **Configuração de E-mail (`/api/v1/email-settings`)**: `GET /`, `POST /`, `POST /test`.
- **Certificados (`/api/v1/stores/{storeId}/certificates`)**: `GET /`, `POST /`.
- **NFS-e (`/api/v1/nfse`)**: `POST /emitir`, `POST /preview-pdf`, `GET /` (listagem), `GET /por-nfse`, `GET /{id}/pdf`, `GET /{id}/xml`, `POST /{id}/reenviar-email`.
- **RPS (`/api/v1/rps/allocate`)**: reserva manual de número para integrações externas.
- **Integrações auxiliares**: `GET /api/v1/cep/{cep}`, `GET /api/v1/cnpj/{cnpj}`, `GET /api/v1/ibge/ufs`, `GET /api/v1/ibge/municipios`.
- **Logs (`/api/v1/logs/soap`)**: `GET /` (filtro por sistema/ação/período) e `GET /{id}` (detalhe).

------------------------------------------------------------------------

## 6) Modelo de Dados (Resumo)

| Tabela | Finalidade |
|--------|------------|
| `tenants` | Empresas, com CNPJ, timestamps e logotipo opcional. |
| `stores` | Lojas vinculadas, com CNPJ, IM, código IBGE e timestamps. |
| `certificates` | Certificados A1 criptografados por loja, com metadados de validade. |
| `email_settings` | Configurações SMTP por empresa/loja (únicas por escopo). |
| `customers` | Tomadores de serviço cadastrados por empresa (nome, documento, contato). |
| `users` / `roles` / `user_roles` | Autenticação e autorização com suporte a escopo por tenant/loja. |
| `services` | Catálogo fiscal com alíquotas e indicador de retenção. |
| `rps_sequences` | Controle de numeração de RPS por loja e série. |
| `invoices` | Notas emitidas (referenciam tomador via `customer_id`, armazenam status, número NFSe, valores). |
| `invoice_items` | Itens de serviço detalhando descrição, quantidade e valor unitário. |
| `soap_logs` | Auditoria das requisições SOAP (request/response mascarados). |

------------------------------------------------------------------------

## 7) Monitoramento e Operação

- Serilog registra requisições HTTP e eventos relevantes no console; `appsettings` pode direcionar para outros sinks.
- Tela de Logs concentra operações SOAP e permite diagnóstico rápido de falhas com a prefeitura.
- Falhas em integrações externas retornam mensagens claras ao usuário (ex.: `cep não encontrado`, `certificado não configurado`).
- Estratégia de cache reduz dependência contínua de serviços de CEP/IBGE, mitigando indisponibilidades temporárias.
- Recomenda-se configurar alertas para validade de certificados (dados já expostos via API/UI).

------------------------------------------------------------------------

## 8) Configuração e Deploy

### 8.1 Variáveis de Ambiente (Backend)
- `DB_CONNECTION_STRING`: string completa de conexão SQL Server.
- `JWT_SECRET`: chave HMAC para assinatura do token.
- `CRYPTO_KEY`: segredo usado na criptografia AES dos certificados/senhas SMTP.
- `NFSE_GYN_ENDPOINT`: URL base do serviço SOAP da prefeitura (prod/homolog).
- `ASPNETCORE_ENVIRONMENT`: seleção de perfil de configuração (Development, Production).
- Opcional: parâmetros SMTP podem ser mantidos nos registros `email_settings`.

### 8.2 Banco de Dados via `sqlcmd`
```
# Dados de Conexão SQL Server (Preencher na implantação)

- **Servidor:sql.vsantana.com.br,1279** 
- **Database:gynnota** 
- **Usuário:gynnota** 
- **Senha:QK9uwbgkRNGllWkd** 
- **String de conexão completa:Server=sql.vsantana.com.br,1279;Database=gynnota;User Id=gynnota;Password=QK9uwbgkRNGllWkd;TrustServerCertificate=True;**
```
- Aplicar todas as migrations em ordem (`db/migrations/*.sql`) usando `sqlcmd -S <servidor> -d <database> -U <usuario> -P <senha> -i arquivo.sql`.
- Seeds podem ser adicionados em `db/seeds` conforme necessidade (atualmente vazio).

### 8.3 Backend
- Restore/build: `dotnet restore && dotnet build backend/GynNota.sln`.
- Execução local: `dotnet run --project backend/src/GynNota.Api/GynNota.Api.csproj`.
- Swagger disponível em `/swagger` em ambiente Development.

### 8.4 Frontend
- Instalação: `npm install` em `frontend/`.
- Desenvolvimento: `npm run dev` (utiliza `VITE_API_BASE` ou o valor configurado no seletor da UI).
- Build: `npm run build` gera artefatos em `frontend/dist`.

### 8.5 Logging e Observabilidade
- Ajustar sinks Serilog via `appsettings.json`/variáveis de ambiente.
- Considerar direcionar `soap_logs` para ferramenta externa (ex.: dashboard SQL ou DataDog) em produção.

------------------------------------------------------------------------

## 9) Pendências e Próximos Passos Sugeridos

- Implementar fluxo de cancelamento da NFS-e (via portal com registro interno ou integração futura, caso a prefeitura disponibilize).
- Notificar automaticamente sobre certificados próximos da expiração.
- Adicionar testes automatizados (unit/integration) para serviços críticos (emissão, assinatura, autorização).
- Evoluir para mensageria ou jobs periódicos caso seja necessário reprocessar lotes ou conciliar notas pendentes.
- Expandir relatórios fiscal/gerenciais (ex.: exportação CSV, dashboards por período).
- Hardenizar logs mascarando também dados pessoais nos XMLs armazenados, se requerido por compliance.

**Fim da especificação (versão atualizada com o funcionamento implementado).**
