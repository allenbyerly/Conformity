spool data.log

@packageinfo.sql

prompt ==================================================
prompt ==================================================
prompt |                                                |
prompt |                                                |
prompt |               Scanworks 7 SQL                  |
prompt |          Data Installation Routine             |
prompt |                                                |
prompt |                                                |
prompt ==================================================
prompt ==================================================
prompt |                     *****                      |
prompt |           Scanworks Data Installation          |
prompt |                  ***********                   |
prompt |                    STARTED                     |
prompt ==================================================

@InstallCoreData.sql
@InstallStandardData.sql
@InstallDEMOData.sql

prompt ==================================================
prompt |                     *****                      |
prompt |           Scanworks Data Installation          |
prompt |                  ***********                   |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt ==================================================
prompt |                                                |
prompt |                                                |
prompt |               Scanworks 7 SQL                  |
prompt |           Data Installation Routine            |
prompt |                                                |
prompt |                                                |
prompt ==================================================
prompt ==================================================
spool off
exit;