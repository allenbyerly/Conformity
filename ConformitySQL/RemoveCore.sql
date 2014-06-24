prompt ==================================================
prompt |      Removing: Scanworks Core Components       |
prompt |                    STARTED                     |
prompt ==================================================

prompt ==================================================
prompt Removing Data
prompt ==================================================

prompt ==================================================
prompt Removing Packages
prompt ==================================================

prompt ==================================================
prompt Removing Objects
prompt ==================================================

@Core\DropUsers.sql
@Core\DropTriggers.sql
@Core\DropViews.sql
@Core\DropTableIndexes.sql

prompt ==================================================
prompt Removing Tables
prompt ==================================================

@Core\DropTableKeys.sql
@Core\DropTables.sql

prompt ==================================================
prompt |      Removing: Scanworks Core Components       |
prompt |                   COMPLETED                    |
prompt ==================================================