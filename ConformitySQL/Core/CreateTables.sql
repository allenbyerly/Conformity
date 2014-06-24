prompt ________________________________________________
prompt 
prompt Creating Scanworks System Tables
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Transaction System Tables

prompt ------------------------------------------------

prompt Creating Transactions Table
CREATE TABLE ESI_SW_TRANSACTIONS_TAB
(
  TRANSACTION 		VARCHAR2(128) 									NOT NULL,
  TITLE       		VARCHAR2(128),
  DESCRIPTION 		VARCHAR2(2000),
  PACKAGE     		VARCHAR2(128),
  API         		VARCHAR2(2000), 
  VERSION     		VARCHAR2(128),
  ROWVERSION  		DATE 					DEFAULT SYSDATE
);

prompt Creating Transaction Fields Table
CREATE TABLE ESI_SW_FIELDS_TAB
(
  TRANSACTION   		VARCHAR2(128) 								NOT NULL,
  HIERARCHY     		NUMBER 										NOT NULL,
  FIELD_ID      		VARCHAR2(128) 								NOT NULL,
  ENABLED       		CHAR(1) 			DEFAULT 'Y' 			NOT NULL,
  CONFIGURABLE  		CHAR(1) 			DEFAULT 'N' 			NOT NULL,
  PROMPT        		VARCHAR2(128),
  LOOKUP_TABLE  		VARCHAR2(128),
  FIELD_NAME    		VARCHAR2(2000),
  DEFAULT_VALUE 		VARCHAR2(2000),
  MAX_LENGTH    		NUMBER,
  READ_ONLY     		CHAR(1) 			DEFAULT 'N' 			NOT NULL,
  UPPERCASE     		CHAR(1) 			DEFAULT 'Y' 			NOT NULL,
  HAS_UOM       		CHAR(1) 			DEFAULT 'N' 			NOT NULL,
  LOV           		VARCHAR2(2000),
  LOV_PROMPT    		VARCHAR2(128),
  LOV_ON_ENTRY  		CHAR(1) 			DEFAULT 'N' 			NOT NULL,
  LOV_READ_ONLY 		CHAR(1) 			DEFAULT 'N' 			NOT NULL,
  ROWVERSION       		DATE 				DEFAULT SYSDATE
);

prompt Creating Transaction History Table
CREATE TABLE ESI_SW_TRANSACTION_LOG_TAB
(
  TRANSACTION_ID 		NUMBER 										NOT NULL,
  TRANSACTION    		VARCHAR2(35),
  CONTRACT       		VARCHAR2(5),
  USER_ID        		VARCHAR2(30),
  DATE_TIME      		DATE,
  QUANTITY       		NUMBER,
  PART_NUMBER    		VARCHAR2(25),
  ORDER_NO       		VARCHAR2(12),
  USER1          		VARCHAR2(200),
  USER2          		VARCHAR2(200),
  USER3          		VARCHAR2(200),
  ROWVERSION       		DATE 				DEFAULT SYSDATE
);

prompt ------------------------------------------------

prompt Creating Scanworks Printing System Tables

prompt ------------------------------------------------

prompt Creating Label Print Sites Table
CREATE TABLE ESI_SW_PRINT_SITES_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  LABEL_DIRECTORY 		VARCHAR2(80) 								NOT NULL,
  ROWVERSION      		DATE 				DEFAULT SYSDATE
);

prompt Creating Label Printers Table
CREATE TABLE ESI_SW_PRINTERS_TAB
(
  CONTRACT     			VARCHAR2(5) 								NOT NULL,
  PRINTER_NO   			VARCHAR2(5) 								NOT NULL,
  PRINTER_NAME 			VARCHAR2(25) 								NOT NULL,
  DESCRIPTION  			VARCHAR2(30),
  PRINTER_TYPE 			VARCHAR2(50),
  ROWVERSION   			DATE 				DEFAULT SYSDATE 
);

prompt Creating Label Names Table
CREATE TABLE ESI_SW_LABEL_NAMES_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  LABEL_NAME 			VARCHAR2(30) 								NOT NULL,
  ROWVERSION 			DATE 				DEFAULT SYSDATE
);

prompt Creating Labels Table
CREATE TABLE ESI_SW_LABELS_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  TRANSACTION     		VARCHAR2(128) 								NOT NULL,
  PART_NO         		VARCHAR2(25) 								NOT NULL,
  PART_MAIN_GROUP 		VARCHAR2(10) 								NOT NULL,
  LABEL_NAME      		VARCHAR2(30) 								NOT NULL,
  NUMBER_OF_LABEL 		NUMBER 										NOT NULL,
  ROWVERSION      		DATE 				DEFAULT SYSDATE
);

prompt ------------------------------------------------

prompt Creating Scanworks Menu System Tables

prompt ------------------------------------------------

prompt Creating Menus Table
CREATE TABLE ESI_SW_MENUS_TAB
(
  CONTRACT   			VARCHAR2(5) 								NOT NULL,
  MENU_NAME  			VARCHAR2(35) 								NOT NULL,
  ROWVERSION 			DATE 				DEFAULT SYSDATE
);

prompt Menu Icons Table
CREATE TABLE ESI_SW_ICONS_TAB
(
  ICON       			VARCHAR2(100) 		NOT NULL,
  ICON_FILE  			BLOB,
  ROWVERSION 			DATE 				DEFAULT SYSDATE
);

prompt Creating Users Table
CREATE TABLE ESI_SW_USERS_TAB
(
  IDENTITY      		VARCHAR2(30) 								NOT NULL,
  CONTRACT  			VARCHAR2(5) 								NOT NULL,
  MENU_NAME     		VARCHAR2(35),
  PASSWORD      		VARCHAR2(35) 								NOT NULL,
  ROWVERSION    		DATE 				DEFAULT SYSDATE
);

prompt Creating Menu Items Table
CREATE TABLE ESI_SW_MENU_ITEMS_TAB
(
  CONTRACT         		VARCHAR2(5) 								NOT NULL,
  MENU_NAME        		VARCHAR2(35) 								NOT NULL,
  TRANSACTION      		VARCHAR2(128),
  SUBMENU          		VARCHAR2(35),
  RANK             		NUMBER(3) 									NOT NULL,
  PROMPT           		VARCHAR2(35) 								NOT NULL,
  PRINTER_NO       		VARCHAR2(5),
  ICON             		VARCHAR2(100),
  SUBMENU_CONTRACT 		VARCHAR2(5),
  PRINTER_CONTRACT 		VARCHAR2(5),
  ROWVERSION       		DATE 				DEFAULT SYSDATE
);