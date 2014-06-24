prompt ________________________________________________
prompt 
prompt Removing Scanworks Core Table Indexes
prompt ________________________________________________

prompt ------------------------------------------------

prompt Removing Scanworks Menu System Tables Indexes

prompt ------------------------------------------------

prompt Removing Menu Items Table Indexes
DROP INDEX ESI_SW_MENU_ITEMS_TAB_IX;

DROP INDEX ESI_SW_MENU_ITEMS_TAB_IX2;

prompt Removing Users Table Indexes
DROP INDEX ESI_SW_USERS_TAB_IX;


prompt ------------------------------------------------

prompt Removing Scanworks Printing System Tables Indexes

prompt ------------------------------------------------

prompt Removing Labels Table Indexes
DROP INDEX ESI_SW_LABELS_TAB_IX;

prompt Removing Label Names Table Indexes
DROP INDEX ESI_SW_LABEL_NAMES_TAB_IX;
  
prompt Removing Label Printers Table Indexes
DROP INDEX ESI_SW_PRINTERS_TAB_IX;


prompt ------------------------------------------------

prompt Removing Scanworks Transaction System Tables Indexes

prompt ------------------------------------------------

prompt Removing Transaction Fields Table Indexes
DROP INDEX ESI_SW_FIELDS_TAB_IX;
