prompt ________________________________________________
prompt 
prompt Removing Scanworks System Tables
prompt ________________________________________________

prompt ------------------------------------------------

prompt Removing Scanworks Menu System Tables

prompt ------------------------------------------------

prompt Removing Menu Items Table
DROP TABLE ESI_SW_MENU_ITEMS_TAB;

prompt Removing Users Table
DROP TABLE ESI_SW_USERS_TAB;

prompt Removing Menu Icons Table
DROP TABLE ESI_SW_ICONS_TAB;

prompt Removing Menus Table
DROP TABLE ESI_SW_MENUS_TAB;

prompt ------------------------------------------------

prompt Removing Scanworks Printing System Tables

prompt ------------------------------------------------

prompt Removing Labels Table
DROP TABLE ESI_SW_LABELS_TAB;

prompt Removing Label Names Table
DROP TABLE ESI_SW_LABEL_NAMES_TAB;

prompt Removing Label Printers Table
DROP TABLE ESI_SW_PRINTERS_TAB;

prompt Removing Label Print Sites Table
DROP TABLE ESI_SW_PRINT_SITES_TAB;

prompt ------------------------------------------------

prompt Removing Scanworks Transaction System Tables

prompt ------------------------------------------------

prompt Removing Transaction History Table
DROP TABLE ESI_SW_TRANSACTION_LOG_TAB;

prompt Removing Transaction Fields Table
DROP TABLE ESI_SW_FIELDS_TAB;

prompt Removing Transactions Table
DROP TABLE ESI_SW_TRANSACTIONS_TAB;


-- prompt Removing ENSYNC Table
-- DROP TABLE ENSYNC.APPOWNER;