prompt ________________________________________________
prompt 
prompt Installing Tosoh Delivery Table Keys
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Tosoh Delivery System Table Keys

prompt ------------------------------------------------

prompt Creating Delivery Table Keys
ALTER TABLE ESI_SW_DELIVERY_TAB
  ADD CONSTRAINT SW_DELIVERY_PK 	PRIMARY KEY (CONTRACT, DELNOTE_NO);

prompt Creating Delivery Items Table Keys
ALTER TABLE ESI_SW_DELIVERY_ITEM_TAB
  ADD 	CONSTRAINT 		SW_DELIVERY_ITEMS_PK 		PRIMARY KEY (PART_NO, SERIAL_NO, LOT_BATCH_NO)
  ADD 	CONSTRAINT 		SW_DELIVERY_ITEMS_FK		FOREIGN KEY (CONTRACT, DELNOTE_NO)
		REFERENCES 		ESI_SW_DELIVERY_TAB 					(CONTRACT, DELNOTE_NO)
		ON DELETE 		CASCADE;
		
prompt Creating Delivery Completed Table Keys
ALTER TABLE ESI_SW_DELIVERY_COMPLETED_TAB
  ADD 	CONSTRAINT 		SW_DELIVERY_COMPLETED_PK 		PRIMARY KEY (PART_NO, SERIAL_NO, LOT_BATCH_NO)
  ADD 	CONSTRAINT 		SW_DELIVERY_COMPLETED_FK		FOREIGN KEY (CONTRACT, DELNOTE_NO) 
		REFERENCES 		ESI_SW_DELIVERY_TAB 						(CONTRACT, DELNOTE_NO)
		ON DELETE 		CASCADE;