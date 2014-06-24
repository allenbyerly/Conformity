prompt ________________________________________________
prompt 
prompt Creating Tosoh Custom System Tables
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Tosoh Delivery System Tables

prompt ------------------------------------------------

prompt Creating Verify Delivery Table
CREATE TABLE ESI_SW_DELIVERY_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  DELNOTE_NO        	VARCHAR2(60) 								NOT NULL,
  STATUS        		VARCHAR2(10) 		DEFAULT 'NEW'			NOT NULL,
  ROWVERSION  			DATE 				DEFAULT SYSDATE
);

prompt Creating Verify Delivery Item Fields Table
CREATE TABLE ESI_SW_DELIVERY_ITEM_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  DELNOTE_NO        	VARCHAR2(60) 								NOT NULL,
  PART_NO   			VARCHAR2(25) 								NOT NULL,
  SERIAL_NO     		VARCHAR2(200) 								NOT NULL,
  LOT_BATCH_NO      	VARCHAR2(80) 								NOT NULL,
  QTY_SHIPPED     		NUMBER							 			NOT NULL,
  VERIFIED  			NUMBER										NOT NULL,
  VERIFIED_BY        	VARCHAR2(20),
  ROWVERSION       		DATE 				DEFAULT SYSDATE
);

prompt Creating Verify Delivery Item Fields Table
CREATE TABLE ESI_SW_DELIVERY_COMPLETED_TAB
(
  CONTRACT        		VARCHAR2(5) 								NOT NULL,
  DELNOTE_NO        	VARCHAR2(60) 								NOT NULL,
  PART_NO   			VARCHAR2(25) 								NOT NULL,
  SERIAL_NO     		VARCHAR2(200) 								NOT NULL,
  LOT_BATCH_NO      	VARCHAR2(80) 								NOT NULL,
  QTY_SHIPPED     		NUMBER							 			NOT NULL,
  VERIFIED  			NUMBER										NOT NULL,
  VERIFIED_BY        	VARCHAR2(20),
  ROWVERSION       		DATE 				DEFAULT SYSDATE
);