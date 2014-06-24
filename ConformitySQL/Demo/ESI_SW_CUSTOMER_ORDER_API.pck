CREATE OR REPLACE PACKAGE ESI_SW_CUSTOMER_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.5.0.100
  -- Date:                02/10/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS CO API's
  -- Additionally this implements custom ESI delivery functionality
-----------------------------------------------------------------------------------------


FUNCTION PACKAGE RETURN VARCHAR2;
FUNCTION VERSION RETURN VARCHAR2;

PROCEDURE TRANSACT (in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);
/*
PROCEDURE RECEIVE_WITH_DIFFERENCES(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

PROCEDURE New_Line(
   info_              IN OUT VARCHAR2,
   objid_             IN OUT VARCHAR2,
   objversion_        IN OUT VARCHAR2,
   attr2_              IN OUT VARCHAR2,
   order_no_          IN OUT VARCHAR2,
   part_no_           IN OUT VARCHAR2,
   buy_qty_due_       IN OUT NUMBER,
   buy_unit_price_    IN OUT NUMBER,
   note_text_         IN OUT VARCHAR2,
   consignment_stock_ IN OUT VARCHAR2);
*/
END ESI_SW_CUSTOMER_ORDER_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_CUSTOMER_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.5.0.100
  -- Date:                02/10/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS CO API's
  -- Additionally this implements custom ESI delivery functionality
-----------------------------------------------------------------------------------------
FUNCTION VERSION RETURN VARCHAR2
IS
BEGIN
  RETURN '7.5.0.100';
END;

FUNCTION PACKAGE RETURN VARCHAR2
IS
BEGIN
  RETURN 'Demo';
END;

PROCEDURE PICK_RESERVATION(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  pick_list_no_          CUSTOMER_ORDER_RESERVATION.pick_list_no%TYPE;
  order_no_              CUSTOMER_ORDER_RESERVATION.order_no%TYPE;
  line_no_               CUSTOMER_ORDER_RESERVATION.line_no%TYPE;
  rel_no_                CUSTOMER_ORDER_RESERVATION.rel_no%TYPE;
  line_item_no_          CUSTOMER_ORDER_RESERVATION.line_item_no%TYPE;
  contract_              CUSTOMER_ORDER_RESERVATION.contract%TYPE;
  part_no_               CUSTOMER_ORDER_RESERVATION.part_no%TYPE;
  location_no_           CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
  lot_batch_no_          CUSTOMER_ORDER_RESERVATION.lot_batch_no%TYPE;
  serial_no_             CUSTOMER_ORDER_RESERVATION.serial_no%TYPE;
  eng_chg_level_         CUSTOMER_ORDER_RESERVATION.eng_chg_level%TYPE;
  waiv_dev_rej_no_       CUSTOMER_ORDER_RESERVATION.waiv_dev_rej_no%TYPE;
  configuration_id_      CUSTOMER_ORDER_RESERVATION.configuration_id%TYPE;
  pallet_id_             CUSTOMER_ORDER_RESERVATION.pallet_id%TYPE;
  input_qty_                     CUSTOMER_ORDER_RESERVATION.input_qty%TYPE;
  input_conv_factor_             CUSTOMER_ORDER_RESERVATION.input_conv_factor%TYPE;
  input_unit_meas_               CUSTOMER_ORDER_RESERVATION.input_unit_meas%TYPE;
  input_variable_values_         CUSTOMER_ORDER_RESERVATION.input_variable_values%TYPE;
  catch_qty_to_pick_             CUSTOMER_ORDER_RESERVATION.catch_qty%TYPE;
  qty_to_pick_           CUSTOMER_ORDER_RESERVATION.qty_picked%TYPE;
  ship_location_no_      CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
  activity_seq_          CUSTOMER_ORDER_RESERVATION.activity_seq%TYPE;
  
  over_picked_lines_     VARCHAR2(2000);
  all_reported_          NUMBER;
  closed_lines_          NUMBER;
  line_attr_             VARCHAR2(2000);

  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  pick_list_no_          := CLIENT_SYS.Get_Item_Value('PICK_LIST_NO_PICK', attr_);
  ship_location_no_      := CLIENT_SYS.Get_Item_Value('SHIP_LOCATION_NO', attr_);
  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  line_no_               := CLIENT_SYS.Get_Item_Value('LINE_NO', attr_);
  rel_no_                := CLIENT_SYS.Get_Item_Value('REL_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  configuration_id_      := CLIENT_SYS.Get_Item_Value('CONFIGURATION_ID', attr_);
  activity_seq_           := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);
  pallet_id_              := NULL;
  input_qty_              := NULL;
  input_conv_factor_      := NULL;
  input_unit_meas_        := NULL;
  input_variable_values_  := NULL;
  catch_qty_to_pick_      := NULL;
  qty_to_pick_           := CLIENT_SYS.Get_Item_Value('QTY_TO_PICK', attr_);


  CLIENT_SYS.Clear_Attr(attr_);

  CLIENT_SYS.Add_To_Attr('ORDER_NO', order_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LINE_NO', line_no_, attr_);
  CLIENT_SYS.Add_To_Attr('REL_NO', rel_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LINE_ITEM_NO', line_item_no_, attr_);
  CLIENT_SYS.Add_To_Attr('CONTRACT', contract_, attr_);
  CLIENT_SYS.Add_To_Attr('PART_NO', part_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LOCATION_NO', location_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LOT_BATCH_NO', lot_batch_no_, attr_);
  CLIENT_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
  CLIENT_SYS.Add_To_Attr('ENG_CHG_LEVEL', eng_chg_level_, attr_);
  CLIENT_SYS.Add_To_Attr('WAIV_DEV_REJ_NO', waiv_dev_rej_no_, attr_);
  CLIENT_SYS.Add_To_Attr('CONFIGURATION_ID', configuration_id_, attr_);
  CLIENT_SYS.Add_To_Attr('PALLET_ID', pallet_id_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_QTY', input_qty_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_CONV_FACTOR', input_conv_factor_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_UNIT_MEAS', input_unit_meas_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_VARIABLE_VALUES', input_variable_values_, attr_);
  CLIENT_SYS.Add_To_Attr('CATCH_QTY_TO_PICK', catch_qty_to_pick_, attr_);
  CLIENT_SYS.Add_To_Attr('QTY_TO_PICK', qty_to_pick_, attr_);
  CLIENT_SYS.Add_To_Attr('ACTIVITY_SEQ', activity_seq_, attr_);

  PICK_CUSTOMER_ORDER_API.Pick_Reservations__(all_reported_,
                                              closed_lines_,
                                              line_attr_,
                                              over_picked_lines_,
                                              attr_,
                                              pick_list_no_,
                                              ship_location_no_);

  out_attr_ := attr_;

END PICK_RESERVATION;

PROCEDURE PICK_RESERVED(in_attr_ IN VARCHAR2,   out_attr_  OUT  VARCHAR2)

IS

   order_no_                      CUSTOMER_ORDER_RESERVATION.order_no%TYPE;
   line_no_                       CUSTOMER_ORDER_RESERVATION.line_no%TYPE;
   rel_no_                        CUSTOMER_ORDER_RESERVATION.rel_no%TYPE;
   line_item_no_                  CUSTOMER_ORDER_RESERVATION.line_item_no%TYPE;
   contract_                      CUSTOMER_ORDER_RESERVATION.contract%TYPE;
   part_no_                       CUSTOMER_ORDER_RESERVATION.part_no%TYPE;
   location_no_                   CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
   eng_chg_level_                 CUSTOMER_ORDER_RESERVATION.eng_chg_level%TYPE;
   pick_list_no_                  CUSTOMER_ORDER_RESERVATION.pick_list_no%TYPE;

   pick_list_no_list_             CREATE_PICK_LIST_API.Pick_List_Table;

   pick_performed_                BOOLEAN;
   to_                            NUMBER;
   from_                          NUMBER;

   i_                             NUMBER;

   attr_                          VARCHAR2(2000);

   CURSOR existing_reservations_ IS
   SELECT *
   FROM   customer_order_reservation
   WHERE  order_no      = order_no_
   AND    line_no       = line_no_
   AND    rel_no        = rel_no_
   AND    line_item_no  = line_item_no_
   AND    part_no       = part_no_
   AND    location_no   = location_no_
   AND    eng_chg_level = eng_chg_level_
   AND    qty_assigned - qty_picked > 0
   AND    pick_list_no  = pick_list_no_;

BEGIN


   attr_                   := in_attr_;

   order_no_               := CLIENT_SYS.Get_Item_Value('ORDER_NO' , attr_);
   line_no_                := CLIENT_SYS.Get_Item_Value('LINE_NO' , attr_);
   rel_no_                 := CLIENT_SYS.Get_Item_Value('REL_NO' , attr_);
   line_item_no_           := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO' , attr_);
   part_no_                := CLIENT_SYS.Get_Item_Value('PART_NO' , attr_);
   location_no_            := CLIENT_SYS.Get_Item_Value('LOCATION_NO' , attr_);
   eng_chg_level_          := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL' , attr_);

   --Create PickList and get a pick list report
   CREATE_PICK_LIST_API.Create_Pick_List__(pick_list_no_list_, order_no_);


   IF (pick_list_no_list_.COUNT>0) THEN
      FOR i_ IN pick_list_no_list_.FIRST .. pick_list_no_list_.LAST LOOP

              attr_                   := in_attr_;
              pick_list_no_           := pick_list_no_list_(i_);

          -- PICK_LIST_NO was passed in this attribute string already, use a different name
          CLIENT_SYS.Add_To_Attr('PICK_LIST_NO_PICK', pick_list_no_, attr_);

           --Perform Pick
          PICK_RESERVATION(attr_, attr_);

      END LOOP;

   END IF;

   out_attr_ := attr_;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END PICK_RESERVED;

/*
PROCEDURE Pick_Lists_To_Tmp_Tbl___ (
   pick_list_no_list_ IN OUT CREATE_PICK_LIST_API.Pick_List_Table )
IS
   i_    NUMBER;
BEGIN

   DELETE FROM PICK_LIST_NO_LIST_TMP_TAB;
   IF (pick_list_no_list_.COUNT>0) THEN
      FORALL i_ IN pick_list_no_list_.FIRST .. pick_list_no_list_.LAST
         INSERT INTO PICK_LIST_NO_LIST_TMP_TAB
         VALUES (pick_list_no_list_(i_));
   END IF;
END Pick_Lists_To_Tmp_Tbl___;
*/
PROCEDURE CREATE_PICKLIST(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  pick_list_no_          CUSTOMER_ORDER_RESERVATION.pick_list_no%TYPE;
  order_no_              CUSTOMER_ORDER_RESERVATION.order_no%TYPE;
  line_no_               CUSTOMER_ORDER_RESERVATION.line_no%TYPE;
  rel_no_                CUSTOMER_ORDER_RESERVATION.rel_no%TYPE;
  line_item_no_          CUSTOMER_ORDER_RESERVATION.line_item_no%TYPE;
  contract_              CUSTOMER_ORDER_RESERVATION.contract%TYPE;
  part_no_               CUSTOMER_ORDER_RESERVATION.part_no%TYPE;
  location_no_           CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
  lot_batch_no_          CUSTOMER_ORDER_RESERVATION.lot_batch_no%TYPE;
  serial_no_             CUSTOMER_ORDER_RESERVATION.serial_no%TYPE;
  eng_chg_level_         CUSTOMER_ORDER_RESERVATION.eng_chg_level%TYPE;
  waiv_dev_rej_no_       CUSTOMER_ORDER_RESERVATION.waiv_dev_rej_no%TYPE;
  configuration_id_      CUSTOMER_ORDER_RESERVATION.configuration_id%TYPE;
  pallet_id_             CUSTOMER_ORDER_RESERVATION.pallet_id%TYPE;
  input_qty_                     CUSTOMER_ORDER_RESERVATION.input_qty%TYPE;
  input_conv_factor_             CUSTOMER_ORDER_RESERVATION.input_conv_factor%TYPE;
  input_unit_meas_               CUSTOMER_ORDER_RESERVATION.input_unit_meas%TYPE;
  input_variable_values_         CUSTOMER_ORDER_RESERVATION.input_variable_values%TYPE;
  catch_qty_to_pick_             CUSTOMER_ORDER_RESERVATION.catch_qty%TYPE;
  qty_to_pick_           CUSTOMER_ORDER_RESERVATION.qty_picked%TYPE;
  ship_location_no_      CUSTOMER_ORDER_RESERVATION.location_no%TYPE;

  over_picked_lines_     VARCHAR2(2000);
  all_reported_          NUMBER;
  closed_lines_          NUMBER;
  line_attr_             VARCHAR2(2000);

  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  pick_list_no_          := CLIENT_SYS.Get_Item_Value('PICK_LIST_NO', attr_);
  ship_location_no_      := CLIENT_SYS.Get_Item_Value('SHIP_LOCATION_NO', attr_);
  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  line_no_               := CLIENT_SYS.Get_Item_Value('LINE_NO', attr_);
  rel_no_                := CLIENT_SYS.Get_Item_Value('REL_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  configuration_id_      := CLIENT_SYS.Get_Item_Value('CONFIGURATION_ID', attr_);
  pallet_id_              := NULL;
  input_qty_              := NULL;
  input_conv_factor_      := NULL;
  input_unit_meas_        := NULL;
  input_variable_values_  := NULL;
  catch_qty_to_pick_      := NULL;
  qty_to_pick_           := CLIENT_SYS.Get_Item_Value('QTY_TO_PICK', attr_);


  CLIENT_SYS.Clear_Attr(attr_);

  CLIENT_SYS.Add_To_Attr('ORDER_NO', order_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LINE_NO', line_no_, attr_);
  CLIENT_SYS.Add_To_Attr('REL_NO', rel_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LINE_ITEM_NO', line_item_no_, attr_);
  CLIENT_SYS.Add_To_Attr('CONTRACT', contract_, attr_);
  CLIENT_SYS.Add_To_Attr('PART_NO', part_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LOCATION_NO', location_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LOT_BATCH_NO', lot_batch_no_, attr_);
  CLIENT_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
  CLIENT_SYS.Add_To_Attr('ENG_CHG_LEVEL', eng_chg_level_, attr_);
  CLIENT_SYS.Add_To_Attr('WAIV_DEV_REJ_NO', waiv_dev_rej_no_, attr_);
  CLIENT_SYS.Add_To_Attr('CONFIGURATION_ID', configuration_id_, attr_);
  CLIENT_SYS.Add_To_Attr('PALLET_ID', pallet_id_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_QTY', input_qty_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_CONV_FACTOR', input_conv_factor_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_UNIT_MEAS', input_unit_meas_, attr_);
  CLIENT_SYS.Add_To_Attr('INPUT_VARIABLE_VALUES', input_variable_values_, attr_);
  CLIENT_SYS.Add_To_Attr('CATCH_QTY_TO_PICK', catch_qty_to_pick_, attr_);
  CLIENT_SYS.Add_To_Attr('QTY_TO_PICK', qty_to_pick_, attr_);

  PICK_CUSTOMER_ORDER_API.Pick_Reservations__(all_reported_,
                                              closed_lines_,
                                              line_attr_,
                                              over_picked_lines_,
                                              attr_,
                                              pick_list_no_,
                                              ship_location_no_);

  out_attr_ := attr_;

END CREATE_PICKLIST;



PROCEDURE RESERVE(in_attr_ IN VARCHAR2,   out_attr_  OUT  VARCHAR2)

IS

   order_no_                      CUSTOMER_ORDER_RESERVATION.order_no%TYPE;
   line_no_                       CUSTOMER_ORDER_RESERVATION.line_no%TYPE;
   rel_no_                        CUSTOMER_ORDER_RESERVATION.rel_no%TYPE;
   line_item_no_                  CUSTOMER_ORDER_RESERVATION.line_item_no%TYPE;
   contract_                      CUSTOMER_ORDER_RESERVATION.contract%TYPE;
   part_no_                       CUSTOMER_ORDER_RESERVATION.part_no%TYPE;
   location_no_                   CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
   lot_batch_no_                  CUSTOMER_ORDER_RESERVATION.lot_batch_no%TYPE;
   serial_no_                     CUSTOMER_ORDER_RESERVATION.serial_no%TYPE;
   eng_chg_level_                 CUSTOMER_ORDER_RESERVATION.eng_chg_level%TYPE;
   waiv_dev_rej_no_               CUSTOMER_ORDER_RESERVATION.waiv_dev_rej_no%TYPE;
   pallet_id_                     CUSTOMER_ORDER_RESERVATION.pallet_id%TYPE;
   activity_seq_                  CUSTOMER_ORDER_RESERVATION.activity_seq%TYPE;
   qty_to_reserve_                CUSTOMER_ORDER_RESERVATION.qty_to_deliver%TYPE;
   input_qty_                     CUSTOMER_ORDER_RESERVATION.input_qty%TYPE;
   input_unit_meas_               CUSTOMER_ORDER_RESERVATION.input_unit_meas%TYPE;
   input_conv_factor_             CUSTOMER_ORDER_RESERVATION.input_conv_factor%TYPE;
   input_variable_values_         CUSTOMER_ORDER_RESERVATION.input_variable_values%TYPE;


   attr_                          VARCHAR2(2000);
   info_                          VARCHAR2(2000);
   state_                         VARCHAR2(2000);


BEGIN


   attr_                   := in_attr_;

   order_no_               := CLIENT_SYS.Get_Item_Value('ORDER_NO' , attr_);
   line_no_                := CLIENT_SYS.Get_Item_Value('LINE_NO' , attr_);
   rel_no_                 := CLIENT_SYS.Get_Item_Value('REL_NO' , attr_);
   line_item_no_           := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO' , attr_);
   contract_               := CLIENT_SYS.Get_Item_Value('CONTRACT' , attr_);
   part_no_                := CLIENT_SYS.Get_Item_Value('PART_NO' , attr_);
   location_no_            := CLIENT_SYS.Get_Item_Value('LOCATION_NO' , attr_);
   lot_batch_no_           := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO' , attr_);
   serial_no_              := CLIENT_SYS.Get_Item_Value('SERIAL_NO' , attr_);
   eng_chg_level_          := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL' , attr_);
   waiv_dev_rej_no_        := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO' , attr_);
   pallet_id_              := CLIENT_SYS.Get_Item_Value('PALLET_ID' , attr_);
   activity_seq_           := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ' , attr_);
   IF activity_seq_ is null THEN
     activity_seq_ := 0;
   END IF;
   -- we are reserving to perform a pick, so qty_to_reserve = qty_to_pick
   qty_to_reserve_         := CLIENT_SYS.Get_Item_Value('QTY_TO_PICK' , attr_);
   input_qty_              := CLIENT_SYS.Get_Item_Value('INPUT_QTY' , attr_);
   input_unit_meas_        := CLIENT_SYS.Get_Item_Value('INPUT_UNIT_MEAS' , attr_);
   input_conv_factor_      := CLIENT_SYS.Get_Item_Value('INPUT_CONV_FACTOR' , attr_);
   input_variable_values_  := CLIENT_SYS.Get_Item_Value('INPUT_VARIABLE_VALUES' , attr_);


   Reserve_Customer_Order_Api.Reserve_Manually__(info_,
                                                 state_,
                                                 order_no_,
                                                 line_no_,
                                                 rel_no_,
                                                 line_item_no_,
                                                 contract_,
                                                 part_no_,
                                                 location_no_,
                                                 lot_batch_no_,
                                                 serial_no_,
                                                 eng_chg_level_,
                                                 waiv_dev_rej_no_,
                                                 pallet_id_,
                                                 activity_seq_,
                                                 qty_to_reserve_,
                                                 input_qty_,
                                                 input_unit_meas_,
                                                 input_conv_factor_,
                                                 input_variable_values_);


   out_attr_ := attr_;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END RESERVE;


/*
PROCEDURE CREATE_DELIVERY(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  contract_              ESI_SW_DELIVERY.CONTRACT%TYPE;
  delnote_no_            ESI_SW_DELIVERY.DELNOTE_NO%TYPE;

  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT',   attr_);
  delnote_no_            := CLIENT_SYS.Get_Item_Value('DELNOTE_NO', attr_);

  INSERT INTO ESI_SW_DELIVERY_TAB (CONTRACT,  DELNOTE_NO, STATUS)
  VALUES (contract_, delnote_no_, 'NEW');

  CLIENT_SYS.Set_Item_Value('STATUS', 'NEW', attr_);

  out_attr_ := attr_;

END CREATE_DELIVERY;

PROCEDURE REMOVE_DELIVERY(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  contract_              ESI_SW_DELIVERY.CONTRACT%TYPE;
  delnote_no_            ESI_SW_DELIVERY.DELNOTE_NO%TYPE;

  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT',   attr_);
  delnote_no_            := CLIENT_SYS.Get_Item_Value('DELNOTE_NO', attr_);

  DELETE FROM ESI_SW_DELIVERY_TAB
  WHERE contract = contract_
  AND delnote_no = delnote_no_;

  CLIENT_SYS.Set_Item_Value('STATUS', '', attr_);

  out_attr_ := attr_;

END REMOVE_DELIVERY;

PROCEDURE PROCESS_ITEM(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  contract_              ESI_SW_DELIVERY.CONTRACT%TYPE;
  delnote_no_            ESI_SW_DELIVERY.DELNOTE_NO%TYPE;
  part_no_               ESI_SW_DELIVERY.PART_NO%TYPE;
  serial_no_             ESI_SW_DELIVERY.SERIAL_NO%TYPE;
  lot_batch_no_          ESI_SW_DELIVERY.LOT_BATCH_NO%TYPE;
  fnd_user_              FND_USER_PROPERTY.identity%TYPE;
  status_                ESI_SW_DELIVERY_TAB.STATUS%TYPE;

  CURSOR unverified_items IS
  SELECT *
  FROM ESI_SW_DELIVERY_ITEM_TAB
  WHERE contract = contract_
  AND delnote_no = delnote_no_
  AND verified = '0';

  CURSOR verified_items IS
  SELECT *
  FROM ESI_SW_DELIVERY_ITEM_TAB
  WHERE contract = contract_
  AND delnote_no = delnote_no_
  AND verified = '1';



  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT',   attr_);
  delnote_no_            := CLIENT_SYS.Get_Item_Value('DELNOTE_NO', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  status_                := CLIENT_SYS.Get_Item_Value('STATUS', attr_);
  fnd_user_              := CLIENT_SYS.Get_Item_Value('FND_USER', attr_);

  SELECT status
  INTO status_
  FROM ESI_SW_DELIVERY_TAB
  WHERE contract = contract_
  AND delnote_no = delnote_no_;

  IF status_ = 'NEW' THEN
    status_ := 'STARTED';
  ELSIF status_ = 'STARTED' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Another User is starting this Delivery Note.  Please try again');
  ELSIF status_ = 'IN PROCESS' THEN
    status_ := 'IN PROCESS';
  ELSIF status_ = 'VERIFIED' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Delivery Note Already Verified');
  ELSIF status_ = 'COMPLETED' THEN
    RAISE_APPLICATION_ERROR(-20002, 'Delivery Note Already Completed');
  ELSE
    RAISE_APPLICATION_ERROR(-20002, 'Invalid Delivery Status');
  END IF;

  UPDATE ESI_SW_DELIVERY_TAB
  SET status = status_
  WHERE contract = contract_
  AND delnote_no = delnote_no_;

  UPDATE ESI_SW_DELIVERY_ITEM_TAB
  SET VERIFIED = '1',
      VERIFIED_BY = fnd_user_,
      ROWVERSION = SYSDATE
  WHERE contract = contract_
  AND delnote_no = delnote_no_
  AND part_no = part_no_
  AND serial_no = serial_no_
  AND lot_batch_no = lot_batch_no_;

  status_ := 'VERIFIED';

  FOR next_ IN unverified_items LOOP
    status_ := 'IN PROCESS';
  END LOOP;

  UPDATE ESI_SW_DELIVERY_TAB
  SET status = status_
  WHERE contract = contract_
  AND delnote_no = delnote_no_;

  IF status_ = 'VERIFIED' THEN
    FOR next_ IN verified_items LOOP
      INSERT INTO ESI_SW_DELIVERY_COMPLETED_TAB (
        CONTRACT,
        DELNOTE_NO,
        PART_NO,
        SERIAL_NO,
        LOT_BATCH_NO,
        QTY_SHIPPED,
        VERIFIED,
        VERIFIED_BY,
        ROWVERSION )
      VALUES (
        next_.contract,
        next_.delnote_no,
        next_.part_no,
        next_.serial_no,
        next_.lot_batch_no,
        next_.qty_shipped,
        next_.verified,
        next_.verified_by,
        next_.rowversion );
    END LOOP;

    DELETE FROM ESI_SW_DELIVERY_ITEM_TAB
    WHERE contract = contract_
    AND delnote_no = delnote_no_;

    status_ := 'COMPLETED';

    UPDATE ESI_SW_DELIVERY_TAB
    SET status = status_
    WHERE contract = contract_
    AND delnote_no = delnote_no_;

  END IF;

  CLIENT_SYS.Set_Item_Value('STATUS', status_, attr_);

  out_attr_ := attr_;

END PROCESS_ITEM;
*/

--MODIFIED MAIN PO MOVE TO STOCK API

PROCEDURE CO_PICK(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
   order_no_                      CUSTOMER_ORDER_RESERVATION.order_no%TYPE;
   line_no_                       CUSTOMER_ORDER_RESERVATION.line_no%TYPE;
   rel_no_                        CUSTOMER_ORDER_RESERVATION.rel_no%TYPE;
   line_item_no_                  CUSTOMER_ORDER_RESERVATION.line_item_no%TYPE;
   contract_                      CUSTOMER_ORDER_RESERVATION.contract%TYPE;
   part_no_                       CUSTOMER_ORDER_RESERVATION.part_no%TYPE;
   location_no_                   CUSTOMER_ORDER_RESERVATION.location_no%TYPE;
   eng_chg_level_                 CUSTOMER_ORDER_RESERVATION.eng_chg_level%TYPE;
   pick_list_no_                  CUSTOMER_ORDER_RESERVATION.pick_list_no%TYPE;

   exists_                        number;
   attr_                          VARCHAR2(2000);

CURSOR existing_reservations_ IS
   SELECT *
   FROM   customer_order_reservation
   WHERE  order_no      = order_no_
   AND    line_no       = line_no_
   AND    rel_no        = rel_no_
   AND    line_item_no  = line_item_no_
   AND    part_no       = part_no_
   AND    location_no   = location_no_
   AND    eng_chg_level = eng_chg_level_
   AND    qty_assigned - qty_picked > 0
   AND    pick_list_no  = pick_list_no_;

BEGIN


   attr_                   := in_attr_;

   order_no_               := CLIENT_SYS.Get_Item_Value('ORDER_NO' , attr_);
   line_no_                := CLIENT_SYS.Get_Item_Value('LINE_NO' , attr_);
   rel_no_                 := CLIENT_SYS.Get_Item_Value('REL_NO' , attr_);
   line_item_no_           := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO' , attr_);
   part_no_                := CLIENT_SYS.Get_Item_Value('PART_NO' , attr_);
   location_no_            := CLIENT_SYS.Get_Item_Value('LOCATION_NO' , attr_);
   eng_chg_level_          := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL' , attr_);
   pick_list_no_           := CLIENT_SYS.Get_Item_Value('PICK_LIST_NO' , attr_);

   exists_ := 0;

   FOR next_ IN existing_reservations_ LOOP
       exists_ := 1;
       PICK_RESERVED(attr_, attr_);
   END LOOP;

  IF exists_ = 0 THEN
     RESERVE(attr_, attr_);
     PICK_RESERVED(attr_, attr_);
  END IF;



  out_attr_ := attr_;

END CO_PICK;


PROCEDURE CO_PICKLIST_PICK(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  PICK_RESERVATION(attr_, attr_);

  out_attr_ := attr_;

END CO_PICKLIST_PICK;
--MODIFIED MAIN PO MOVE TO STOCK API

--MODIFIED MAIN PO MOVE TO STOCK API
/*
PROCEDURE CO_VERIFY_DELIVERY(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);
  action_                        VARCHAR2(25);

BEGIN

  attr_ := in_attr_;

  action_                        := CLIENT_SYS.Get_Item_Value('ACTION', attr_);

  IF action_ = 'START' THEN
     CREATE_DELIVERY(attr_, attr_);
  ELSIF action_ = 'CONTINUE' THEN
     PROCESS_ITEM(attr_, attr_);
  ELSIF action_ = 'RESTART' THEN
     REMOVE_DELIVERY(attr_, attr_);
     CREATE_DELIVERY(attr_, attr_);
  END IF;

  out_attr_ := attr_;

END CO_VERIFY_DELIVERY;
*/
--MODIFIED MAIN PO MOVE TO STOCK API

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

   IF  transaction_ = 'CO_PICKLIST_PICK' THEN CO_PICKLIST_PICK(attr_, attr_);

--   ELSIF transaction_ = 'CO_VERIFY_DELIVERY' THEN CO_VERIFY_DELIVERY(attr_, attr_);
   ELSIF transaction_ = 'CO_PICK' THEN CO_PICK(attr_, attr_);

   ELSE RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');

   END IF;

   out_attr_ := attr_;

--EXCEPTION
--   WHEN OTHERS THEN
--      RAISE_APPLICATION_ERROR(SQLCODE,  SQLERRM);
END TRANSACT;

END ESI_SW_CUSTOMER_ORDER_API;
/
