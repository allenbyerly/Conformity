prompt ________________________________________________
prompt 
prompt Installing Scanworks Core Views
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Transaction System Views

prompt ------------------------------------------------

prompt Creating Transactions View
CREATE OR REPLACE VIEW ESI_SW_TRANSACTIONS AS
SELECT DISTINCT TRANS.TRANSACTION                                   TRANSACTION,
                TRANS.TITLE                                         TITLE,
                TRANS.DESCRIPTION                                   DESCRIPTION,
                TRANS.PACKAGE                                       PACKAGE,
                TRANS.API                                           API,
                TRANS.VERSION                                       VERSION
FROM   			ESI_SW_TRANSACTIONS_TAB                             TRANS
ORDER BY 		TRANS.TRANSACTION;

prompt Creating Fields View
CREATE OR REPLACE VIEW ESI_SW_FIELDS AS
SELECT DISTINCT FIELDS.TRANSACTION                  				TRANSACTION,
                FIELDS.HIERARCHY                    				HIERARCHY,
                FIELDS.FIELD_ID                     				FIELD_ID,
                FIELDS.ENABLED                      				ENABLED,
                FIELDS.CONFIGURABLE                 				CONFIGURABLE,
                FIELDS.LOOKUP_TABLE                 				LOOKUP_TABLE,
                FIELDS.PROMPT                       				PROMPT,
                FIELDS.FIELD_NAME                   				FIELD_NAME,
                FIELDS.DEFAULT_VALUE                				DEFAULT_VALUE,
                FIELDS.MAX_LENGTH                   				MAX_LENGTH,
                FIELDS.READ_ONLY                    				READ_ONLY,
                FIELDS.UPPERCASE                    				UPPERCASE,
                FIELDS.HAS_UOM                      				AS_UOM,
                FIELDS.LOV                          				LOV,
                FIELDS.LOV_PROMPT                   				LOV_PROMPT,
                FIELDS.LOV_ON_ENTRY                 				LOV_ON_ENTRY,
                FIELDS.LOV_READ_ONLY                				LOV_READ_ONLY
FROM   			ESI_SW_FIELDS_TAB									FIELDS
ORDER BY 		FIELDS.TRANSACTION, 
				FIELDS.HIERARCHY;

prompt Creating Transaction log View				
CREATE OR REPLACE VIEW ESI_SW_TRANSACTION_LOG AS
SELECT DISTINCT LOG.TRANSACTION_ID                                TRANSACTION_ID,
                LOG.TRANSACTION                                   TRANSACTION,
                LOG.CONTRACT                                      CONTRACT,
                LOG.USER_ID                                       USER_ID,
                LOG.DATE_TIME                                     DATE_TIME,
                LOG.QUANTITY                                      QUANTITY,
                LOG.PART_NUMBER                                   PART_NUMBER,
                LOG.ORDER_NO                                      ORDER_NO,
                LOG.USER1                                         USER1,
                LOG.USER2                                         USER2,
                LOG.USER3                                         USER3
FROM         	ESI_SW_TRANSACTION_LOG_TAB                        LOG
ORDER BY     	LOG.TRANSACTION_ID;
				
prompt Creating Transaction System View
CREATE OR REPLACE VIEW ESI_SW_TRANSACTION_SYSTEM AS
SELECT DISTINCT TRANS.TRANSACTION                                   TRANSACTION,
                TRANS.TITLE                                         TITLE,
                TRANS.DESCRIPTION                                   DESCRIPTION,
                FIELDS.HIERARCHY                                    HIERARCHY,
                FIELDS.FIELD_ID                                     FIELD_ID,
                FIELDS.ENABLED                                      ENABLED,
                FIELDS.CONFIGURABLE                                 CONFIGURABLE,
                FIELDS.LOOKUP_TABLE                                 LOOKUP_TABLE,
                FIELDS.PROMPT                                       PROMPT,
                FIELDS.FIELD_NAME                                   FIELD_NAME,
                FIELDS.DEFAULT_VALUE                                DEFAULT_VALUE,
                FIELDS.MAX_LENGTH                                   MAX_LENGTH,
                FIELDS.READ_ONLY                                    READ_ONLY,
                FIELDS.UPPERCASE                                    UPPERCASE,
                FIELDS.HAS_UOM                                      HAS_UOM,
                FIELDS.LOV                                          LOV,
                FIELDS.LOV_PROMPT                                   LOV_PROMPT,
                FIELDS.LOV_ON_ENTRY                                 LOV_ON_ENTRY,
                FIELDS.LOV_READ_ONLY                                LOV_READ_ONLY,
                TRANS.PACKAGE                                       PACKAGE,
                TRANS.API                                           API,
                TRANS.VERSION                                       VERSION
FROM            ESI_SW_TRANSACTIONS_TAB                             TRANS,
                ESI_SW_FIELDS_TAB                                   FIELDS
WHERE           TRANS.TRANSACTION (+) = FIELDS.TRANSACTION 
ORDER BY 	TRANS.TRANSACTION,
		FIELDS.HIERARCHY;

prompt ------------------------------------------------

prompt Creating Scanworks Printing System Views

prompt ------------------------------------------------

prompt Creating Print Sites View
CREATE OR REPLACE VIEW ESI_SW_PRINT_SITES AS
SELECT DISTINCT SITES.CONTRACT                  					CONTRACT,
                SITES.LABEL_DIRECTORY           					LABEL_DIRECTORY
FROM   			ESI_SW_PRINT_SITES_TAB								SITES
ORDER BY 		SITES.CONTRACT;

prompt Creating Printers View
CREATE OR REPLACE VIEW ESI_SW_PRINTERS AS
SELECT DISTINCT PRINTERS.CONTRACT                  					CONTRACT,
                PRINTERS.PRINTER_NO                					PRINTER_NO,
                PRINTERS.PRINTER_NAME                       PRINTER_NAME,
                PRINTERS.DESCRIPTION                        DESCRIPTION,
                PRINTERS.PRINTER_TYPE                       PRINTER_TYPE
FROM   			    ESI_SW_PRINTERS_TAB									        PRINTERS
ORDER BY 		    PRINTERS.CONTRACT,
				        PRINTERS.PRINTER_NO;


prompt Creating Label Names View
CREATE OR REPLACE VIEW ESI_SW_LABEL_NAMES AS
SELECT DISTINCT NAMES.CONTRACT              						CONTRACT,
                NAMES.LABEL_NAME            						LABEL_NAME
FROM            ESI_SW_LABEL_NAMES_TAB      						NAMES
ORDER BY 		NAMES.CONTRACT, 
				NAMES.LABEL_NAME;

prompt Creating Labels View				
CREATE OR REPLACE VIEW ESI_SW_LABELS AS
SELECT DISTINCT NAMES.CONTRACT              						CONTRACT,
                NAMES.LABEL_NAME            						LABEL_NAME,
                LABELS.TRANSACTION          						TRANSACTION,
                LABELS.PART_NO              						PART_NO,
                LABELS.PART_MAIN_GROUP      						PART_MAIN_GROUP,
                LABELS.NUMBER_OF_LABEL      						NUMBER_OF_LABEL
FROM            ESI_SW_LABEL_NAMES_TAB      						NAMES,
		ESI_SW_LABELS_TAB           						LABELS
WHERE      	NAMES.CONTRACT (+) = LABELS.CONTRACT
AND             NAMES.LABEL_NAME = LABELS.LABEL_NAME
ORDER BY 		NAMES.CONTRACT,
				NAMES.LABEL_NAME,
				LABELS.TRANSACTION,
				LABELS.PART_NO,
				LABELS.PART_MAIN_GROUP;

prompt Creating Print System View				
CREATE OR REPLACE VIEW ESI_SW_PRINT_SYSTEM AS
SELECT DISTINCT SITES.CONTRACT                 						CONTRACT,
                NAMES.LABEL_NAME               						LABEL_NAME,
                LABELS.TRANSACTION             						TRANSACTION,
                LABELS.PART_NO                 						PART_NO,
                LABELS.PART_MAIN_GROUP         						PART_MAIN_GROUP,
                LABELS.NUMBER_OF_LABEL         						NUMBER_OF_LABEL,
                PRINTERS.PRINTER_NO            						PRINTER_NO,
                PRINTERS.PRINTER_NAME          						PRINTER_NAME,
                PRINTERS.DESCRIPTION           						DESCRIPTION,
                PRINTERS.PRINTER_TYPE          						PRINTER_TYPE,
                SITES.LABEL_DIRECTORY          						LABEL_DIRECTORY
FROM            ESI_SW_PRINT_SITES_TAB         						SITES,
	        ESI_SW_LABEL_NAMES_TAB         						NAMES,
		ESI_SW_LABELS_TAB              						LABELS,
		ESI_SW_PRINTERS_TAB            						PRINTERS
WHERE           SITES.CONTRACT (+) = NAMES.CONTRACT       
AND             NAMES.CONTRACT (+) = LABELS.CONTRACT
AND             NAMES.LABEL_NAME = LABELS.LABEL_NAME
ORDER BY        SITES.CONTRACT,
                NAMES.LABEL_NAME,
                LABELS.TRANSACTION,
                LABELS.PART_NO,
                LABELS.PART_MAIN_GROUP,
                PRINTERS.PRINTER_NO;
				
prompt ------------------------------------------------

prompt Creating Scanworks Menu System Views

prompt ------------------------------------------------

prompt Creating Active Users View
CREATE OR REPLACE VIEW ESI_SW_ACTIVE_USERS AS
SELECT DISTINCT SITES.USERID          USERID,
                SITES.CONTRACT        CONTRACT
FROM   FND_USER FND,
       USER_ALLOWED_SITE SITES,
       ESI_SW_MENUS_TAB MENUS
WHERE  FND.ACTIVE = 'TRUE'
AND    FND.IDENTITY = SITES.USERID
AND    SITES.CONTRACT = MENUS.CONTRACT
UNION
SELECT '*', '*'
FROM   DUAL
ORDER BY USERID;

prompt Creating Sites View
CREATE OR REPLACE VIEW ESI_SW_SITES AS
SELECT DISTINCT SITES.CONTRACT                CONTRACT,
                SITES.USERID                  USERID             
FROM            ESI_SW_ACTIVE_USERS           SITES
UNION
SELECT                                        '*',
                                              '*'
FROM            DUAL
ORDER BY        USERID;

prompt Creating Users View
CREATE OR REPLACE VIEW ESI_SW_USERS AS
SELECT DISTINCT USERS.IDENTITY                						IDENTITY,
                USERS.PASSWORD                						PASSWORD,
                USERS.CONTRACT                						CONTRACT,
                USERS.MENU_NAME               						MENU_NAME
FROM            ESI_SW_USERS_TAB              						USERS
ORDER BY        USERS.IDENTITY;

prompt Creating Menus View
CREATE OR REPLACE VIEW ESI_SW_MENUS AS
SELECT DISTINCT MENUS.CONTRACT                  					CONTRACT,
                MENUS.MENU_NAME                 					MENU_NAME
FROM   			ESI_SW_MENUS_TAB									MENUS
UNION
SELECT 			'*',     											
				'*'
FROM 			DUAL
ORDER BY 		CONTRACT, 
				MENU_NAME;

prompt Creating Menu Items View				
CREATE OR REPLACE VIEW ESI_SW_MENU_ITEMS AS
SELECT          ITEMS.CONTRACT                  					CONTRACT,
                ITEMS.MENU_NAME                 					MENU_NAME,
                ITEMS.RANK                      					RANK,
                ITEMS.TRANSACTION               					TRANSACTION,
                ITEMS.SUBMENU                   					SUBMENU,
                ITEMS.PROMPT                    					PROMPT,
                ITEMS.PRINTER_NO                					PRINTER_NO,
                ITEMS.ICON                      					ICON
FROM            ESI_SW_MENU_ITEMS_TAB           					ITEMS
ORDER BY 		ITEMS.CONTRACT, 
				ITEMS.MENU_NAME, 
				ITEMS.RANK;

prompt Creating Icons View
CREATE OR REPLACE VIEW ESI_SW_ICONS AS
SELECT 			ICONS.ICON                  						ICON,
				ICONS.ICON_FILE             						ICON_FILE
FROM   			ESI_SW_ICONS_TAB									ICONS
ORDER BY 		ICONS.ICON;

prompt Creating Menu System View
CREATE OR REPLACE VIEW ESI_SW_MENU_SYSTEM AS
SELECT          MENUS.CONTRACT                  					CONTRACT,
                MENUS.MENU_NAME                 					MENU_NAME,
                ITEMS.RANK                      					RANK,
                ITEMS.TRANSACTION               					TRANSACTION,
                ITEMS.SUBMENU                   					SUBMENU,
                ITEMS.PROMPT                    					PROMPT,
                ITEMS.PRINTER_NO                					PRINTER_NO,
                ICONS.ICON_FILE                 					ICON
FROM            ESI_SW_MENUS_TAB                					MENUS,
	        ESI_SW_MENU_ITEMS_TAB           					ITEMS,
	        ESI_SW_ICONS_TAB 							ICONS 
WHERE           MENUS.CONTRACT (+) = ITEMS.CONTRACT
AND             MENUS.MENU_NAME = ITEMS.MENU_NAME
AND             ITEMS.ICON (+) = ICONS.ICON
ORDER BY 		MENUS.CONTRACT, 
				MENUS.MENU_NAME, 
				ITEMS.RANK;

prompt Creating User Menus View
CREATE OR REPLACE VIEW ESI_SW_USER_MENUS AS
SELECT		USERS.IDENTITY                  					IDENTITY,
                MENUS.CONTRACT                  					CONTRACT,
                MENUS.MENU_NAME                 					MENU_NAME,
                ITEMS.RANK                      					RANK,
                ITEMS.TRANSACTION               					TRANSACTION,
                ITEMS.SUBMENU                   					SUBMENU,
                ITEMS.PROMPT                    					PROMPT,
                ITEMS.PRINTER_NO                					PRINTER_NO,
                ICONS.ICON_FILE                 					ICON
FROM            ESI_SW_USERS_TAB                					USERS,
		ESI_SW_MENUS_TAB                					MENUS,
		ESI_SW_MENU_ITEMS_TAB           					ITEMS,
		ESI_SW_ICONS_TAB                					ICONS
WHERE USERS.CONTRACT (+) = MENUS.CONTRACT
AND USERS.MENU_NAME = MENUS.MENU_NAME
AND MENUS.CONTRACT (+) = ITEMS.CONTRACT
AND MENUS.MENU_NAME = ITEMS.MENU_NAME
AND ITEMS.ICON (+) = ICONS.ICON
ORDER BY USERS.IDENTITY, MENUS.CONTRACT, MENUS.MENU_NAME, ITEMS.RANK;