prompt ==================================================
prompt |       Installing: Scanworks Core Data          |
prompt |                    STARTED                     |
prompt ==================================================

prompt ==================================================
prompt Installing Transaction System Data
prompt ==================================================

@Core\CreateTransactionDefaults.sql

prompt ==================================================
prompt Installing Print System Data
prompt ==================================================

@Core\CreatePrintDefaults.sql

prompt ==================================================
prompt Installing Menu Data
prompt ==================================================

@Core\CreateMenuDefaults.sql

prompt ==================================================
prompt |       Installing: Scanworks Core Data          |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt |************************************************|