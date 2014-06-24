CREATE OR REPLACE PACKAGE ESI_SW_INVENTORY_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS Inventory API's
-----------------------------------------------------------------------------------------


FUNCTION PACKAGE RETURN VARCHAR2;
FUNCTION VERSION RETURN VARCHAR2;
FUNCTION Get_Default_Floor_Location_No (contract_ IN VARCHAR2, part_no_ IN VARCHAR2 ) RETURN VARCHAR2;

PROCEDURE TRANSACT (in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

END ESI_SW_INVENTORY_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_INVENTORY_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS Inventory API's
-----------------------------------------------------------------------------------------

FUNCTION VERSION RETURN VARCHAR2
IS
BEGIN
  RETURN '7.3.0.0';
END;

FUNCTION PACKAGE RETURN VARCHAR2
IS
BEGIN
  RETURN 'Demo';
END;

FUNCTION Get_Default_Floor_Location_No (
   contract_ IN VARCHAR2,
   part_no_ IN VARCHAR2 ) RETURN VARCHAR2
IS
   temp_ INVENTORY_PART_DEF_LOC_TAB.location_no%TYPE;
   CURSOR get_attr IS
      SELECT location_no
      FROM INVENTORY_PART_DEF_LOC_TAB
      WHERE contract = contract_
      AND   part_no = part_no_
      AND   location_type = 'F';
BEGIN
   OPEN get_attr;
   FETCH get_attr INTO temp_;
   CLOSE get_attr;
   RETURN temp_;
END Get_Default_Floor_Location_No;



PROCEDURE MOVE_PART(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

   pallet_id_list_                VARCHAR2(200);
   contract_                      ESI_INVENTORY.contract%TYPE;
   part_no_                       ESI_INVENTORY.part_no%TYPE;
   configuration_id_              ESI_INVENTORY.configuration_id%TYPE;
   location_no_                   ESI_INVENTORY.location_no%TYPE;
   lot_batch_no_                  ESI_INVENTORY.lot_batch_no%TYPE;
   serial_no_                     ESI_INVENTORY.serial_no%TYPE;
   eng_chg_level_                 ESI_INVENTORY.eng_chg_level%TYPE;
   waiv_dev_rej_no_               ESI_INVENTORY.waiv_dev_rej_no%TYPE;
   expiration_date_               ESI_INVENTORY.expiration_date%TYPE;
   to_contract_                   ESI_INVENTORY.contract%TYPE;
   to_location_no_                ESI_INVENTORY.location_no%TYPE;
   to_destination_                VARCHAR2(40);
   quantity_                      ESI_INVENTORY.qty_onhand%TYPE;
   qty_reserved_                  ESI_INVENTORY.qty_reserved%TYPE;
   move_comment_                  VARCHAR2(200);

   attr_                          VARCHAR2(2000);
   catch_qty_                     NUMBER;

BEGIN

  pallet_id_list_                 := NULL;
  contract_                       := CLIENT_SYS.Get_Item_Value('CONTRACT' , in_attr_);
  part_no_                        := CLIENT_SYS.Get_Item_Value('PART_NO' , in_attr_);
  configuration_id_               := CLIENT_SYS.Get_Item_Value('CONFIGURATION_ID' , in_attr_);
  location_no_                    := CLIENT_SYS.Get_Item_Value('LOCATION_NO' , in_attr_);
  lot_batch_no_                   := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO' , in_attr_);
  serial_no_                      := CLIENT_SYS.Get_Item_Value('SERIAL_NO' , in_attr_);
  eng_chg_level_                  := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL' , in_attr_);
  waiv_dev_rej_no_                := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO' , in_attr_);
  expiration_date_                := TO_DATE(CLIENT_SYS.Get_Item_Value('EXPIRATION_DATE' , in_attr_),'MM/DD/YYYY HH:Mi:SS PM');
  to_contract_                    := CLIENT_SYS.Get_Item_Value('TO_CONTRACT' , in_attr_);
  to_location_no_                 := CLIENT_SYS.Get_Item_Value('TO_LOCATION_NO' , in_attr_);
  to_destination_                 := CLIENT_SYS.Get_Item_Value('TO_DESTINATION' , in_attr_);
  quantity_                       := CLIENT_SYS.Get_Item_Value('QUANTITY' , in_attr_);
  qty_reserved_                   := 0;
  move_comment_                   := NULL;

  to_destination_                 := Inventory_part_Destination_API.Decode(to_destination_);

  INVENTORY_PART_IN_STOCK_API.Move_Part( pallet_id_list_,
                                         catch_qty_,
                                          contract_,
                                          part_no_,
                                          configuration_id_,
                                          location_no_,
                                          lot_batch_no_,
                                          serial_no_,
                                          eng_chg_level_,
                                          waiv_dev_rej_no_,
                                          '0',
                                          expiration_date_,
                                          to_contract_,
                                          to_location_no_,
                                          to_destination_,
                                          quantity_,
                                          qty_reserved_,
                                          move_comment_);

  out_attr_ := in_attr_;

  CLIENT_SYS.Set_Item_Value('LOCATION_NO',         to_location_no_,         out_attr_);

END MOVE_PART;

--MODIFIED MAIN PO MOVE TO STOCK API
PROCEDURE INV_CHANGE_LOCATION(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  MOVE_PART(attr_, attr_);

  out_attr_ := attr_;

END INV_CHANGE_LOCATION;
--MODIFIED MAIN PO MOVE TO STOCK API

PROCEDURE COUNT_REPORT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);
	info_			                     VARCHAR2(2000);
	objid_			                   counting_report_line.objid%TYPE;
	objversion_		                 counting_report_line.objversion%TYPE;
  qty_count1_                    counting_report_line.qty_count1%TYPE;
  
	ptr_                   NUMBER;
	name_                  VARCHAR2(30);
	value_                 VARCHAR2(2000);

	userid_			           inventory_transaction_hist.userid%TYPE;

BEGIN

   Client_SYS.Clear_Attr(attr_);

   ptr_ := NULL;

   WHILE (Client_SYS.Get_Next_From_Attr(in_attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'OBJID') THEN
         objid_ := value_;
      ELSIF (name_ = 'OBJVERSION') THEN
         objversion_ := value_;
      ELSIF (name_ = 'QTY_COUNT1') THEN
         qty_count1_ := value_;
      ELSIF (name_ = 'USERID') THEN
         userid_ := value_;
      END IF;

   END LOOP;

  Client_SYS.Add_To_Attr('QTY_COUNT1', qty_count1_, attr_);
  Client_SYS.Add_To_Attr('USERID', userid_, attr_);
  Client_SYS.Add_To_Attr('LAST_COUNT_DATE', SYSDATE, attr_);
  
  Counting_Report_Line_API.Modify__(info_,
				     objid_,
				     objversion_,
				     attr_,
				     'DO');

  out_attr_ := attr_;

END COUNT_REPORT;

PROCEDURE TRANSACT (in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

   transaction_               VARCHAR2(200);
   fnd_user_                  FND_USER_PROPERTY.identity%TYPE;
   attr_                      VARCHAR2(20000);

BEGIN

   attr_ := in_attr_;

   fnd_user_                  := CLIENT_SYS.Get_Item_Value('FND_USER', attr_);
   transaction_               := CLIENT_SYS.Get_Item_Value('TRANSACTION', attr_);

   FND_SESSION_UTIL_API.Set_Fnd_User_(fnd_user_);
 --FND_SESSION_API.Set_Property('FND_USER', fnd_user_);

   IF  transaction_ = 'INV_CHANGE_LOCATION' THEN INV_CHANGE_LOCATION(attr_, attr_);

   ELSIF  transaction_ = 'COUNT_REPORT' THEN COUNT_REPORT(attr_, attr_);

   ELSE RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');

   END IF;

   out_attr_ := attr_;

--EXCEPTION
--   WHEN OTHERS THEN
--      RAISE_APPLICATION_ERROR(SQLCODE,  SQLERRM);
END TRANSACT;

END ESI_SW_INVENTORY_API;
/
