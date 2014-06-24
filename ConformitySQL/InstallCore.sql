prompt ==================================================
prompt |      Installing: Scanworks Core Components     |
prompt |                    STARTED                     |
prompt ==================================================

prompt ==================================================
prompt Installing Tables
prompt ==================================================

@Core\CreateTables.sql
@Core\CreateTableKeys.sql

prompt ==================================================
prompt Installing Objects
prompt ==================================================

@Core\CreateTableIndexes.sql
@Core\CreateViews.sql
@Core\CreateTriggers.sql


prompt ==================================================
prompt Installing Packages
prompt ==================================================

@Core\ESI_SW_CORE_API.pck

prompt ==================================================
prompt Installing user grants
prompt ==================================================

@Core\CreateUsers.sql

prompt ==================================================
prompt |      Installing: Scanworks Core Components     |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt |************************************************|