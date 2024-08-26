# Step by step
0 - Instalação do Databricks CLI
1 - Instalação do UCX via databricks CLI 
1.1 - Arquivo de configurações
1.2 - Navegando pelos comandos disponiveis
1.3 - UCX Workflows
1.4 - UCX Dashboards
1.5 - Tabelas do sistema UCX
2 - Configuração das permissões no Databricks CLI
2.1 - Auth profiles
3 - Assessment
3.1 - Dashboard de migração
4 - Criação de dependencias
4.0 - Criação e migração de grupos para o Account
4.1 - Criação e atribuição de Metastore
4.2 - Criação de Access Connector no Azure para Storage Credential
4.3 - Criação de Storage Credential
4.4 - Criação das External Locations
5 - Criação dos Catalogos e Schemas
6 - Criação do Table Mapping - CSV com a relação das tabelas e depara
7 - Migração das tabelas External 
8 - Migração das tabelas Manageds e Tabelas no Mount
9 - Reconciliação de dados
10 - Acompanhamento no Dashboard de Migração
11 - Avaliação e migração de código
12 - Limpeza dos Objetos antigos

# Instalando o Databricks CLI - Mac /  Linux
brew -v

brew tap databricks/tap

brew install databricks

databricks --version

code  ~/.databrickscfg    

# Autenticar Databricks CLI
## Mostrar tabela de privilégio
-- Authenticate on Workspace
-- Workspace DEV
databricks auth login --host adb-xxxxxxxxxxxxxxxxxxxxxx.0.azuredatabricks.net --profile reginaldo-dataside

-- Para instalação demo
databricks auth login --host adb-xxxxxxxxxxxxxxxxxxxxxx.14.azuredatabricks.net --profile reginaldo-dataside-teste

-- Workspace Brasil Migration
databricks auth login --host adb-xxxxxxxxxxxxxxxxxxxxxx.0.azuredatabricks.net --profile reginaldo-dataside-brazil

-- List profiles
databricks auth profiles

-- Autenthicate on Account
databricks auth login --host https://accounts.azuredatabricks.net/ --account-id xxxxxxxxxxxxxxxxxxxxxx

-- List Account Groups to teste connection
databricks account groups list

# Instalando UCX
## Mostrar Pasta no Workspace antes de instalar
## Mostrar Jobs antes e depois de instalar
## Mostrar arquivo de configuração
databricks labs install ucx --profile reginaldo-dataside-teste

databricks labs install ucx --profile reginaldo-dataside-brazil

UCX_FORCE_INSTALL=global databricks labs install ucx

databricks labs show ucx

# List commands
databricks labs ucx

# Atualizando UCX
databricks labs upgrade ucx

# Desinstalando UCX
databricks labs uninstall ucx --profile reginaldo-dataside-brazil
databricks labs uninstall ucx --profile reginaldo-dataside-teste

databricks labs show ucx

# UCX Workflows Jobs
databricks labs ucx workflows

# Listando e atrelando Metastore
databricks labs ucx show-all-metastores

databricks labs ucx assign-metastore --metastore-id xxxxxxxxxxxxxxxxxxxxxx --workspace-id xxxxxxxxxxxxxxxxxxxxxx

# Confirmar que o Assessment foi executado
databricks labs ucx ensure-assessment-run

# Validação de grupos Account vs Workspace
databricks labs ucx validate-groups-membership

databricks labs ucx create-account-groups --workspace-ids xxxxxxxxxxxxxxxxxxxxxx

# Migrar grupos do Workspace para o Account
Disparar job via UI: migrate-groups

Rodar um validate-groups-membership novamente

# Logs from workflows Jobs
databricks labs ucx logs --workflow migrate-groups --debug
--databricks labs ucx repair-run --step migrate-groups

# Validação 
databricks labs ucx validate-external-locations

databricks labs ucx validate-table-locations --debug

databricks labs ucx principal-prefix-access --subscription-id xxxxxxxxxxxxxxxxxxxxxx

databricks labs ucx migrate-credentials --subscription-id xxxxxxxxxxxxxxxxxxxxxx --debug

databricks labs ucx migrate-locations --subscription-id xxxxxxxxxxxxxxxxxxxxxx

# Table migration
databricks labs ucx sync-workspace-info or manual-workspace-info
databricks labs ucx manual-workspace-info

databricks labs ucx create-table-mapping

az account set --subscription xxxxxxxxxxxxxxxxxxxxxx

databricks labs ucx create-catalogs-schemas

databricks labs ucx migrate-tables --debug

databricks labs ucx logs --workflow migrate-tables 

# Avaliar codigos locais Code
cp /Users/reginaldosilva/Downloads/Silver.py /Users/reginaldosilva/.databricks/labs/ucx/lib/src/databricks/labs/ucx/installer/notebooks

cp /Users/reginaldosilva/Downloads/Gold.py /Users/reginaldosilva/.databricks/labs/ucx/lib/src/databricks/labs/ucx/installer/notebooks

databricks labs ucx lint-local-code --path "/Users/reginaldosilva/.databricks/labs/ucx/lib/src/databricks/labs/ucx/installer/notebooks/" 

#databricks labs ucx migrate-local-code