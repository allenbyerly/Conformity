prompt ==================================================
prompt |       Installing: Scanworks &Package Data      |
prompt |                    STARTED                     |
prompt ==================================================

prompt ==================================================
prompt Installing Transaction System Data
prompt ==================================================

@DEMO\PO_RECEIVE_DATA.SWT
@DEMO\PO_MOVE_TO_STOCK_DATA.SWT
@DEMO\PO_INSPECT_DATA.SWT
@DEMO\INV_CHANGE_LOCATION_DATA.SWT
@DEMO\INV_PRINT_INQUIRY_DATA.SWT
@DEMO\INV_COUNT_REPORT_DATA.SWT
@DEMO\SO_ISSUE_DATA.SWT
@DEMO\SO_RESERVE_DATA.SWT
@DEMO\SO_RECEIVE_DATA.SWT
@DEMO\SO_PICKLIST_ISSUE_DATA.SWT
@DEMO\CO_PICK_DATA.SWT
@DEMO\CO_PICKLIST_PICK_DATA.SWT
@DEMO\TC_CLOCK_IN_DATA.SWT
@DEMO\TC_CLOCK_OUT_DATA.SWT
@DEMO\TC_START_OP_DATA.SWT
@DEMO\TC_STOP_OP_DATA.SWT
@DEMO\TC_STOP_OP_QTY_DATA.SWT
@DEMO\WO_MAT_ISSUE_DATA.SWT
@DEMO\WO_REPORT_TIME_DATA.SWT

prompt ==================================================
prompt Installing Print System Data
prompt ==================================================

prompt ==================================================
prompt Installing Menu Data
prompt ==================================================

@DEMO\CreateMenuDefaults.sql

prompt ==================================================
prompt |       Installing: Scanworks &Package Data      |
prompt |                   COMPLETED                    |
prompt ==================================================
prompt |************************************************|