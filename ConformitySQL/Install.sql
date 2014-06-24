spool install.log
define APPOWNER = &1
define DEFAULT_USER=ENSYNC

@packageinfo.sql

prompt ==================================================
prompt ==================================================
prompt |                                                |
prompt |                                                |
prompt |               Scanworks 7 SQL                  |
prompt |          Clean Installation Routine            |
prompt |                                                |
prompt |                                                |
prompt ==================================================
prompt ==================================================
prompt |                     *****                      |
prompt |          Scanworks Component Removal           |
prompt |                  ***********                   |
prompt |                    STARTED                     |
prompt ==================================================

@RemoveDEMO.sql
@RemoveStandard.sql
@RemoveCore.sql

prompt ==================================================
prompt |                     *****                      |
prompt |          Scanworks Component Removal           |
prompt |                  ***********                   |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt |************************************************|
prompt |************************************************|
prompt |************************************************|
prompt ==================================================
prompt |                     *****                      |
prompt |        Scanworks Component Installation        |
prompt |                  ***********                   |
prompt |                    STARTED                     |
prompt ==================================================

@InstallCore.sql
@InstallStandard.sql
@InstallDEMO.sql

prompt ==================================================
prompt |                     *****                      |
prompt |        Scanworks Component Installation        |
prompt |                  ***********                   |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt ==================================================
prompt |                                                |
prompt |                                                |
prompt |               Scanworks 7 SQL                  |
prompt |          Clean Installation Routine            |
prompt |                                                |
prompt |                                                |
prompt ==================================================
prompt ==================================================
spool off
exit;