prompt ________________________________________________
prompt 
prompt Removing Scanworks Core Table Keys
prompt ________________________________________________

prompt ------------------------------------------------

prompt Removing Scanworks Menu System Tables Keys

prompt ------------------------------------------------

prompt Removing Menu Items Table
ALTER TABLE ESI_SW_MENU_ITEMS_TAB
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_FK5
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_FK4
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_FK3
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_FK2 
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_FK1
  DROP 	CONSTRAINT 		SW_MENU_ITEMS_PK;

prompt Removing Users Table Keys
ALTER TABLE ESI_SW_USERS_TAB
  DROP 	CONSTRAINT 		SW_USERS_FK1
  DROP 	CONSTRAINT 		SW_USERS_PK;

prompt Removing Menu Icons Table Keys
ALTER TABLE ESI_SW_ICONS_TAB
  DROP 	CONSTRAINT 		SW_ICONS_PK;
  
prompt Removing Menus Table Keys
ALTER TABLE ESI_SW_MENUS_TAB
  DROP 	CONSTRAINT 		SW_MENUS_PK;

prompt ------------------------------------------------

prompt Removing Scanworks Printing System Tables

prompt ------------------------------------------------

prompt Removing Labels Table Keys
ALTER TABLE ESI_SW_LABELS_TAB
  DROP 	CONSTRAINT 		SW_LABELS_FK2
  DROP 	CONSTRAINT 		SW_LABELS_FK1	
  DROP 	CONSTRAINT 		SW_LABELS_PK;
  
prompt Removing Label Names Table Keys
ALTER TABLE ESI_SW_LABEL_NAMES_TAB
  DROP 	CONSTRAINT 		SW_LABEL_NAMES_FK1
  DROP 	CONSTRAINT 		SW_LABEL_NAMES_PK;
  
prompt Removing Label Printers Table Keys
ALTER TABLE ESI_SW_PRINTERS_TAB
  DROP 	CONSTRAINT 		SW_PRINTERS_FK1
  DROP 	CONSTRAINT 		SW_PRINTERS_PK;
  
prompt Removing Label Print Sites Table Keys
ALTER TABLE ESI_SW_PRINT_SITES_TAB
  DROP 	CONSTRAINT 		SW_PRINT_SITES_PK;

prompt ------------------------------------------------

prompt Removing Scanworks Transaction System Tables

prompt ------------------------------------------------

prompt Removing Transaction History Table
ALTER TABLE ESI_SW_TRANSACTION_LOG_TAB
  DROP 	CONSTRAINT 		SW_TRANSACTION_LOG_PK;

prompt Removing Transaction Fields Table Keys
ALTER TABLE ESI_SW_FIELDS_TAB
  DROP 	CONSTRAINT 		SW_FIELDS_FK1	
  DROP 	CONSTRAINT 		SW_FIELDS_PK;

prompt Removing Transactions Table Keys
ALTER TABLE ESI_SW_TRANSACTIONS_TAB
  DROP CONSTRAINT SW_TRANSACTIONS_PK;  