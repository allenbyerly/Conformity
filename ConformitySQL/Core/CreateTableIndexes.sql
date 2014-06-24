prompt ________________________________________________
prompt 
prompt Installing Scanworks Core Table Indexes
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Transaction System Table Indexes

prompt ------------------------------------------------

prompt Creating Transaction Fields Table Indexes
CREATE INDEX ESI_SW_FIELDS_TAB_IX ON ESI_SW_FIELDS_TAB (TRANSACTION);


prompt ------------------------------------------------

prompt Creating Scanworks Printing System Table Indexes

prompt ------------------------------------------------

prompt Creating Labels Table Indexes
CREATE INDEX ESI_SW_LABELS_TAB_IX ON ESI_SW_LABELS_TAB (CONTRACT);

prompt Creating Label Names Table Indexes
CREATE INDEX ESI_SW_LABEL_NAMES_TAB_IX ON ESI_SW_LABEL_NAMES_TAB (CONTRACT);

prompt Creating Label Printers Table Indexes
CREATE INDEX ESI_SW_PRINTERS_TAB_IX ON ESI_SW_PRINTERS_TAB (CONTRACT);
		

prompt ------------------------------------------------

prompt Creating Scanworks Menu System Tables Indexes

prompt ------------------------------------------------

prompt Creating Menu Items Table Indexes
CREATE INDEX ESI_SW_MENU_ITEMS_TAB_IX ON ESI_SW_MENU_ITEMS_TAB (CONTRACT, MENU_NAME);

CREATE INDEX ESI_SW_MENU_ITEMS_TAB_IX2 ON ESI_SW_MENU_ITEMS_TAB (ICON);

prompt Creating Users Table Indexes
CREATE INDEX ESI_SW_USERS_TAB_IX ON ESI_SW_USERS_TAB (CONTRACT, MENU_NAME);