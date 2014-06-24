CREATE OR REPLACE PACKAGE ESI_SW_SHOP_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
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
END ESI_SW_SHOP_ORDER_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_SHOP_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks BVI Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS CO API's
  -- Additionally this implements custom ESI delivery functionality
-----------------------------------------------------------------------------------------
FUNCTION VERSION RETURN VARCHAR2
IS
BEGIN
  RETURN '7.3.0.0';
END;

FUNCTION PACKAGE RETURN VARCHAR2
IS
BEGIN
  RETURN 'BVI';
END;


PROCEDURE RECEIVE(
   out_attr_ OUT VARCHAR2,
   in_attr_ IN VARCHAR2) IS

  userid_      inventory_transaction_hist.userid%TYPE;

  v_contract    inventory_part_in_stock.contract%TYPE;
  v_part_no    inventory_part_in_stock.part_no%TYPE;
  v_location_no    inventory_part_in_stock.location_no%TYPE;
  v_lot_batch_no    inventory_part_in_stock.lot_batch_no%TYPE;
  v_serial_no    inventory_part_in_stock.serial_no%TYPE;
  v_eng_chg_level    inventory_part_in_stock.eng_chg_level%TYPE;
  v_waiv_dev_rej_no  inventory_part_in_stock.waiv_dev_rej_no%TYPE;
  v_quantity    inventory_part_in_stock.qty_onhand%TYPE;
  v_activity_seq    inventory_part_in_stock.activity_seq%TYPE;
  v_project_id    shop_ord.project_id%TYPE;
  v_expiration_date  VARCHAR2(20);
  v_configuration_id  inventory_part_in_stock.configuration_id%TYPE;
        v_serial_no_warning  VARCHAR2(200);
  serial_no_warning  VARCHAR2(2000);
  v_condition_code  SHOP_ORD_TAB.condition_code%TYPE;

         v_catch_quantity  MATERIAL_HISTORY_TAB.catch_qty%TYPE;
   v_input_qty     MATERIAL_HISTORY_TAB.input_qty%TYPE;
       v_input_uom    MATERIAL_HISTORY_TAB.input_uom%TYPE;
        v_input_value    MATERIAL_HISTORY_TAB.input_value%TYPE;

  v_line_item_no    MANUFACTURED_PART_TAB.line_item_no%TYPE;
  v_auto      VARCHAR2(10);
  v_backflush             VARCHAR2(10);
  retval       BOOLEAN;

  ptr_                     NUMBER;
     name_                    VARCHAR2(30);
     value_                   VARCHAR2(2000);

     order_no            VARCHAR2(12);
     sequence_no         VARCHAR2(4);
     release_no          VARCHAR2(4);
     expir_date    DATE;

  info_      VARCHAR2(2000);
  objid_      shop_ord.objid%TYPE;
  objversion_    shop_ord.objversion%TYPE;
   issue_attr_    VARCHAR2(2000);

  CURSOR c_shop_ord(p_order shop_ord.order_no%TYPE,p_release shop_ord.release_no%TYPE,p_sequence shop_ord.sequence_no%TYPE) IS
     SELECT objid,objversion
     FROM   shop_ord
     WHERE  p_order = order_no
     AND    p_release = release_no
     AND    p_sequence = sequence_no;
BEGIN

   ptr_ := NULL;
   WHILE (Client_SYS.Get_Next_From_Attr(in_attr_, ptr_, name_, value_)) LOOP

      IF (name_ = 'ORDER_NO') THEN
         order_no := value_;
      ELSIF (name_ = 'RELEASE_NO') THEN
         release_no := value_;
      ELSIF (name_ = 'SEQUENCE_NO') THEN
         sequence_no := value_;
      ELSIF (name_ = 'CONTRACT') THEN
         v_contract := value_;
      ELSIF (name_ = 'PART_NO') THEN
         v_part_no := value_;
      ELSIF (name_ = 'LOCATION_NO') THEN
         v_location_no := value_;
      ELSIF (name_ = 'LOT_BATCH_NO') THEN
         v_lot_batch_no := value_;
      ELSIF (name_ = 'SERIAL_NO') THEN
         v_serial_no := value_;
      ELSIF (name_ = 'ENG_CHG_LEVEL') THEN
         v_eng_chg_level := value_;
      ELSIF (name_ = 'WAIV_DEV_REJ_NO') THEN
         v_waiv_dev_rej_no := value_;
      ELSIF (name_ = 'PROJECT_ID') THEN
         v_project_id := value_;
      ELSIF (name_ = 'ACTIVITY_SEQ') THEN
         v_activity_seq := value_;
      ELSIF (name_ = 'QUANTITY') THEN
         v_quantity := value_;
      ELSIF (name_ = 'EXPIRATION_DATE') THEN
         v_expiration_date := value_;
      ELSIF (name_ = 'CATCH_WEIGHT') THEN
         v_catch_quantity := value_;
      ELSIF (name_ = 'INPUT_QUANTITY') THEN
         v_input_qty := value_;
      ELSIF (name_ = 'INPUT_UNIT_MEAS') THEN
         v_input_uom := value_;
      ELSIF (name_ = 'INPUT_VALUES') THEN
         v_input_value := value_;
      ELSIF (name_ = 'CONDITION_CODE') THEN
         v_condition_code := value_;
      END IF;
   END LOOP;

   v_auto := 'Yes';
   v_backflush := 'Yes';

   expir_date := TO_DATE(v_expiration_date, 'YYYY-MM-DD HH24:MI:SS');

   client_sys.clear_info;

   v_configuration_id := Shop_Ord_API.get_configuration_id(order_no, release_no, sequence_no);

   retval := INVENTORY_PART_IN_STOCK_API.CHECK_EXIST(v_contract, v_part_no, v_configuration_id, v_location_no, v_lot_batch_no, v_serial_no, v_eng_chg_level, v_waiv_dev_rej_no,v_activity_seq);

--   IF (v_backflush = 'Yes') THEN
--    info_:= '';
--  OPEN c_shop_ord(order_no,release_no,sequence_no);
--  FETCH c_shop_ord
--  INTO objid_,objversion_;
--  CLOSE c_shop_ord;
--
--  Client_SYS.Clear_Attr(issue_attr_);
--  Client_SYS.Add_To_Attr('ISSUE_ALL', 'Yes', issue_attr_);
--  Client_SYS.Add_To_Attr('ISSUE_BACKORD', 'Yes', issue_attr_);
--  Client_SYS.Add_To_Attr('TRUE_BACKFLUSH', 'No', issue_attr_);
--  Client_SYS.Add_To_Attr('PARENT_QTY', '', issue_attr_);
--  Client_SYS.Add_To_Attr('OPERATION_NO', '', issue_attr_);
--
--  SHOP_ORD_API.ISSUE__(info_,objid_,objversion_,issue_attr_,'DO');
--
--  v_backflush := 'No';
--   END IF;

   IF (retval) THEN
     Shop_Ord_API.Receive_Part_To_Existing__( serial_no_warning,
                  expir_date,
                order_no,
                       release_no,
                      sequence_no,
                                 v_contract,
                                 v_part_no,
                                 v_location_no,
                                 v_lot_batch_no,
                                 v_serial_no,
                                 v_eng_chg_level,
                                 v_waiv_dev_rej_no,
                                 v_activity_seq,
                                 v_quantity,
                                 v_auto,
                                 v_backflush,
                                 RECEIVED_PART_SOURCE_API.Encode('Shop Order'),
                                 '',
                                 'FALSE',
               v_catch_quantity,
                                 v_input_qty,
                                 v_input_uom,
                          v_input_value,
                     v_condition_code,
              v_line_item_no);

  ELSE
    Shop_Ord_API.Receive_Part__(serial_no_warning,
              order_no,release_no,
              sequence_no,v_contract,
              v_part_no,v_location_no,
              v_lot_batch_no,v_serial_no,
              v_eng_chg_level,
              v_waiv_dev_rej_no,
              v_quantity,v_auto,
              v_backflush,
              RECEIVED_PART_SOURCE_API.Encode('Shop Order'),
              '',
              expir_date,
              v_project_id,
              v_activity_seq,
              v_catch_quantity,
              v_input_qty,
              v_input_uom,
              v_input_value,
              v_condition_code,
              v_line_item_no);

  END IF;
END RECEIVE;


PROCEDURE NEW_RESERVATION(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS


  location_no_           ESI_SHOP_MATERIAL_ALLOC.location_no%TYPE;
  lot_batch_no_          ESI_SHOP_MATERIAL_ALLOC.lot_batch_no%TYPE;
  qty_assigned_          ESI_SHOP_MATERIAL_ALLOC.QTY_ASSIGNED%TYPE;
  serial_no_             ESI_SHOP_MATERIAL_ALLOC.serial_no%TYPE;
  eng_chg_level_         ESI_SHOP_MATERIAL_ALLOC.eng_chg_level%TYPE;
  waiv_dev_rej_no_       ESI_SHOP_MATERIAL_ALLOC.waiv_dev_rej_no%TYPE;
  source_                ESI_SHOP_MATERIAL_ALLOC.source%TYPE;
  activity_seq_          ESI_SHOP_MATERIAL_ALLOC.activity_seq%TYPE;
  order_no_              ESI_SHOP_MATERIAL_ALLOC.order_no%TYPE;
  release_no_            ESI_SHOP_MATERIAL_ALLOC.release_no%TYPE;
  sequence_no_           ESI_SHOP_MATERIAL_ALLOC.sequence_no%TYPE;
  line_item_no_          ESI_SHOP_MATERIAL_ALLOC.line_item_no%TYPE;
  contract_              ESI_SHOP_MATERIAL_ALLOC.contract%TYPE;
  part_no_               ESI_SHOP_MATERIAL_ALLOC.part_no%TYPE;
  order_code_            ESI_SHOP_MATERIAL_ALLOC.order_code%TYPE;

  objid_                 ESI_SHOP_MATERIAL_ALLOC.objid%TYPE;
  objversion_            ESI_SHOP_MATERIAL_ALLOC.objversion%TYPE;

  attr_                  VARCHAR2(2000);
  info_                  VARCHAR2(2000);



BEGIN

  attr_ := in_attr_;

  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  qty_assigned_          := CLIENT_SYS.Get_Item_Value('QUANTITY', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  source_                := CLIENT_SYS.Get_Item_Value('SOURCE', attr_);
  activity_seq_          := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);
  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  release_no_            := CLIENT_SYS.Get_Item_Value('RELEASE_NO', attr_);
  sequence_no_           := CLIENT_SYS.Get_Item_Value('SEQUENCE_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  order_code_            := CLIENT_SYS.Get_Item_Value('ORDER_CODE', attr_);

  CLIENT_SYS.Clear_Attr(attr_);

  CLIENT_SYS.Add_To_Attr('LOCATION_NO', location_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LOT_BATCH_NO', lot_batch_no_, attr_);
  CLIENT_SYS.Add_To_Attr('QTY_ASSIGNED', qty_assigned_, attr_);
  CLIENT_SYS.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
  CLIENT_SYS.Add_To_Attr('ENG_CHG_LEVEL', eng_chg_level_, attr_);
  CLIENT_SYS.Add_To_Attr('WAIV_DEV_REJ_NO', waiv_dev_rej_no_, attr_);
  CLIENT_SYS.Add_To_Attr('SOURCE', source_, attr_);
  CLIENT_SYS.Add_To_Attr('ACTIVITY_SEQ', activity_seq_, attr_);
  CLIENT_SYS.Add_To_Attr('ORDER_NO', order_no_, attr_);
  CLIENT_SYS.Add_To_Attr('RELEASE_NO', release_no_, attr_);
  CLIENT_SYS.Add_To_Attr('SEQUENCE_NO', sequence_no_, attr_);
  CLIENT_SYS.Add_To_Attr('LINE_ITEM_NO', line_item_no_, attr_);
  CLIENT_SYS.Add_To_Attr('CONTRACT', contract_, attr_);
  CLIENT_SYS.Add_To_Attr('PART_NO', part_no_, attr_);
  CLIENT_SYS.Add_To_Attr('ORDER_CODE', order_code_, attr_);

  SHOP_MATERIAL_ASSIGN_API.New__(info_,
                                 objid_,
                                 objversion_,
                                 attr_,
                                 'DO');


  out_attr_ := attr_;

END NEW_RESERVATION;


PROCEDURE MODIFY_RESERVATION(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS


  location_no_           ESI_SHOP_MATERIAL_ALLOC.location_no%TYPE;
  lot_batch_no_          ESI_SHOP_MATERIAL_ALLOC.lot_batch_no%TYPE;
  qty_assigned_          ESI_SHOP_MATERIAL_ALLOC.QTY_ASSIGNED%TYPE;
  quantity_              ESI_SHOP_MATERIAL_ALLOC.QTY_ASSIGNED%TYPE;
  serial_no_             ESI_SHOP_MATERIAL_ALLOC.serial_no%TYPE;
  eng_chg_level_         ESI_SHOP_MATERIAL_ALLOC.eng_chg_level%TYPE;
  waiv_dev_rej_no_       ESI_SHOP_MATERIAL_ALLOC.waiv_dev_rej_no%TYPE;
  source_                ESI_SHOP_MATERIAL_ALLOC.source%TYPE;
  activity_seq_          ESI_SHOP_MATERIAL_ALLOC.activity_seq%TYPE;
  order_no_              ESI_SHOP_MATERIAL_ALLOC.order_no%TYPE;
  release_no_            ESI_SHOP_MATERIAL_ALLOC.release_no%TYPE;
  sequence_no_           ESI_SHOP_MATERIAL_ALLOC.sequence_no%TYPE;
  line_item_no_          ESI_SHOP_MATERIAL_ALLOC.line_item_no%TYPE;
  contract_              ESI_SHOP_MATERIAL_ALLOC.contract%TYPE;
  part_no_               ESI_SHOP_MATERIAL_ALLOC.part_no%TYPE;
  order_code_            ESI_SHOP_MATERIAL_ALLOC.order_code%TYPE;

  attr_                  VARCHAR2(2000);
  info_                  VARCHAR2(2000);

  CURSOR existing_reservations IS
  SELECT *
  FROM   shop_material_assign
  WHERE  part_no = part_no_
  AND    order_no = order_no_
  AND    release_no = release_no_
  AND    sequence_no = sequence_no_
  AND    contract = contract_
  AND    line_item_no = line_item_no_
  AND    part_no = part_no_
  AND    location_no = location_no_
  AND    lot_batch_no = lot_batch_no_
  AND    serial_no = serial_no_
  AND    eng_chg_level = eng_chg_level_
  AND    waiv_dev_rej_no = waiv_dev_rej_no_
  AND    activity_seq = activity_seq_;

BEGIN

  attr_ := in_attr_;

  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  quantity_              := CLIENT_SYS.Get_Item_Value('QUANTITY', attr_);
  qty_assigned_          := CLIENT_SYS.Get_Item_Value('QTY_ASSIGNED', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  activity_seq_          := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);
  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  release_no_            := CLIENT_SYS.Get_Item_Value('RELEASE_NO', attr_);
  sequence_no_           := CLIENT_SYS.Get_Item_Value('SEQUENCE_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);

  qty_assigned_          := qty_assigned_ + quantity_;



  FOR next_ In existing_reservations LOOP

     CLIENT_SYS.Clear_Attr(attr_);

     CLIENT_SYS.Add_To_Attr('QTY_ASSIGNED', qty_assigned_, attr_);

     SHOP_MATERIAL_ASSIGN_API.Modify__(info_,
                                       next_.objid,
                                       next_.objversion,
                                       attr_,
                                       'DO');

  END LOOP;

  out_attr_ := attr_;

END MODIFY_RESERVATION;


PROCEDURE RESERVE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

   contract_    SHOP_MATERIAL_ASSIGN_TAB.contract%TYPE;
   part_no_    SHOP_MATERIAL_ASSIGN_TAB.part_no%TYPE;
   location_no_    SHOP_MATERIAL_ASSIGN_TAB.location_no%TYPE;
   lot_batch_no_  SHOP_MATERIAL_ASSIGN_TAB.lot_batch_no%TYPE;
   serial_no_    SHOP_MATERIAL_ASSIGN_TAB.serial_no%TYPE;
   eng_chg_level_  SHOP_MATERIAL_ASSIGN_TAB.eng_chg_level%TYPE;
   waiv_dev_rej_no_  SHOP_MATERIAL_ASSIGN_TAB.waiv_dev_rej_no%TYPE;
   qty_      SHOP_MATERIAL_ASSIGN_TAB.QTY_ASSIGNED%TYPE;
   order_no_    SHOP_MATERIAL_ASSIGN_TAB.order_no%TYPE;
   release_no_    SHOP_MATERIAL_ASSIGN_TAB.release_no%TYPE;
   sequence_no_    SHOP_MATERIAL_ASSIGN_TAB.sequence_no%TYPE;
   line_item_no_  SHOP_MATERIAL_ASSIGN_TAB.line_item_no%TYPE;
   activity_seq_  SHOP_MATERIAL_ASSIGN_TAB.activity_seq%TYPE;
   source_    SHOP_MATERIAL_ASSIGN_TAB.source%TYPE;
   configuration_id_ SHOP_MATERIAL_ASSIGN_TAB.configuration_id%TYPE;
   order_code_    VARCHAR2(13);

   ptr_                 NUMBER;
   name_                VARCHAR2(30);
   value_               VARCHAR2(2000);

   info_       VARCHAR2(2000);
   objid_      VARCHAR2(2000);
   objversion_ VARCHAR2(2000);

   save_attr_  VARCHAR2(2000);
   attr_       VARCHAR2(2000);

   last_activity_date_  DATE;

   CURSOR c_mat_assign(p_part_no SHOP_MATERIAL_ASSIGN_TAB.part_no%TYPE,
          p_order_no SHOP_MATERIAL_ASSIGN_TAB.order_no%TYPE,
          p_rel_no SHOP_MATERIAL_ASSIGN_TAB.release_no%TYPE,
       p_seq_no SHOP_MATERIAL_ASSIGN_TAB.sequence_no%TYPE,
       p_contract SHOP_MATERIAL_ASSIGN_TAB.contract%TYPE,
       p_line_item_no SHOP_MATERIAL_ASSIGN_TAB.line_item_no%TYPE,
       p_location_no SHOP_MATERIAL_ASSIGN_TAB.location_no%TYPE,
       p_lot_batch_no SHOP_MATERIAL_ASSIGN_TAB.lot_batch_no%TYPE,
       p_serial_no  SHOP_MATERIAL_ASSIGN_TAB.serial_no%TYPE,
       p_eng_chg_level SHOP_MATERIAL_ASSIGN_TAB.eng_chg_level%TYPE,
       p_waiv_dev_rej_no  SHOP_MATERIAL_ASSIGN_TAB.waiv_dev_rej_no%TYPE ) IS
   SELECT objid,objversion
   FROM   shop_material_assign
   WHERE  p_part_no = part_no
   AND    p_order_no = order_no
   AND    p_rel_no = release_no
   AND    p_seq_no = sequence_no
   AND    p_contract = contract
   AND    p_line_item_no = line_item_no
   AND    p_part_no = part_no
   AND    p_location_no = location_no
   AND    p_lot_batch_no = lot_batch_no
   AND    p_serial_no = serial_no
   AND    p_eng_chg_level = eng_chg_level
   AND    p_waiv_dev_rej_no = waiv_dev_rej_no;

BEGIN

   --SetUserID(in_attr_, attr_);

   WHILE (Client_SYS.Get_Next_From_Attr(in_attr_, ptr_, name_, value_)) LOOP

      IF (name_ = 'CONTRACT') THEN
         contract_ := value_;
      ELSIF (name_ = 'ORDER_NO') THEN
         order_no_ := value_;
      ELSIF (name_ = 'PART_NO') THEN
         part_no_ := value_;
      ELSIF (name_ = 'RELEASE_NO') THEN
         release_no_ := value_;
      ELSIF (name_ = 'SEQUENCE_NO') THEN
         sequence_no_ := value_;
      ELSIF (name_ = 'LOCATION_NO') THEN
         location_no_ := value_;
      ELSIF (name_ = 'LOT_BATCH_NO') THEN
         lot_batch_no_ := value_;
      ELSIF (name_ = 'SERIAL_NO') THEN
         serial_no_ := value_;
      ELSIF (name_ = 'ENG_CHG_LEVEL') THEN
         eng_chg_level_ := value_;
      ELSIF (name_ = 'WAIV_DEV_REJ_NO') THEN
         waiv_dev_rej_no_ := value_;
      ELSIF (name_ = 'QTY_ASSIGNED') THEN
         qty_ := value_;
      ELSIF (name_ = 'LINE_ITEM_NO') THEN
         line_item_no_ := value_;
      ELSIF (name_ = 'ORDER_CODE') THEN
         order_code_ := value_;
      ELSIF (name_ = 'ACTIVITY_SEQ') THEN
         activity_seq_ := value_;
      ELSIF (name_ = 'SOURCE') THEN
         source_ := value_;
      ELSIF (name_ = 'CONFIGURATION_ID') THEN
         configuration_id_ := value_;
      END IF;

   END LOOP;

   attr_ := '';
   objid_ := '';
   objversion_ := '';

   OPEN c_mat_assign(part_no_,order_no_,release_no_,sequence_no_,contract_,line_item_no_,location_no_,
                     lot_batch_no_,serial_no_,eng_chg_level_,waiv_dev_rej_no_);
   FETCH  c_mat_assign
   INTO objid_,objversion_;

   IF (c_mat_assign%NOTFOUND) THEN
     Client_Sys.Add_To_Attr('CONTRACT', contract_, attr_);
     Client_Sys.Add_To_Attr('PART_NO', part_no_, attr_);
     Client_Sys.Add_To_Attr('LOCATION_NO', location_no_, attr_);
     Client_Sys.Add_To_Attr('LOT_BATCH_NO', lot_batch_no_, attr_);
     Client_Sys.Add_To_Attr('SERIAL_NO', serial_no_, attr_);
     Client_Sys.Add_To_Attr('ENG_CHG_LEVEL', eng_chg_level_, attr_);
     Client_Sys.Add_To_Attr('WAIV_DEV_REJ_NO', waiv_dev_rej_no_, attr_);
     Client_Sys.Add_To_Attr('QTY_ASSIGNED', qty_, attr_);
     Client_Sys.Add_To_Attr('ORDER_NO', order_no_, attr_);
     Client_Sys.Add_To_Attr('RELEASE_NO', release_no_, attr_);
     Client_Sys.Add_To_Attr('SEQUENCE_NO', sequence_no_, attr_);
     Client_Sys.Add_To_Attr('LINE_ITEM_NO', line_item_no_, attr_);
     Client_Sys.Add_To_Attr('ACTIVITY_SEQ', activity_seq_, attr_);
     Client_Sys.Add_To_Attr('ORDER_CODE', order_code_, attr_);
     Client_Sys.Add_To_Attr('SOURCE', source_, attr_);
     Client_Sys.Add_To_Attr('CONFIGURATION_ID', configuration_id_, attr_);

     save_attr_ := attr_;
  SHOP_MATERIAL_ASSIGN_API.New__(
    info_,
    objid_,
    objversion_,
    attr_,
    'PREPARE');

  SHOP_MATERIAL_ASSIGN_API.New__(
    info_,
    objid_,
    objversion_,
    save_attr_,
    'DO');
   ELSE
     Client_Sys.Add_To_Attr('QTY_ASSIGNED', qty_, attr_);

  SHOP_MATERIAL_ASSIGN_API.Modify__(
    info_,
    objid_,
    objversion_,
    attr_,
    'DO');
   END IF;
   CLOSE c_mat_assign;

--   attr_ := in_attr_;
--   Transaction_SYS.Deferred_Call('ensync_issue.Issue___', in_attr_, lang_indep_ => 'TRUE');

END RESERVE;

PROCEDURE ISSUE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

   ptr_                 NUMBER;
   name_                VARCHAR2(30);
   value_               VARCHAR2(2000);
   attr_                VARCHAR2(2000);

   order_no_    SHOP_MATERIAL_ASSIGN_TAB.order_no%TYPE;
   release_no_    SHOP_MATERIAL_ASSIGN_TAB.release_no%TYPE;
   sequence_no_    SHOP_MATERIAL_ASSIGN_TAB.sequence_no%TYPE;
   line_item_no_  SHOP_MATERIAL_ASSIGN_TAB.line_item_no%TYPE;
   activity_seq_  SHOP_MATERIAL_ASSIGN_TAB.activity_seq%TYPE;
   contract_    SHOP_MATERIAL_ASSIGN_TAB.contract%TYPE;
   location_no_    SHOP_MATERIAL_ASSIGN_TAB.location_no%TYPE;
   lot_batch_no_  SHOP_MATERIAL_ASSIGN_TAB.lot_batch_no%TYPE;
   serial_no_    SHOP_MATERIAL_ASSIGN_TAB.serial_no%TYPE;
   eng_chg_level_  SHOP_MATERIAL_ASSIGN_TAB.eng_chg_level%TYPE;
   waiv_dev_rej_no_  SHOP_MATERIAL_ASSIGN_TAB.waiv_dev_rej_no%TYPE;
   qty_      SHOP_MATERIAL_ASSIGN_TAB.QTY_ASSIGNED%TYPE;
   part_no_    SHOP_MATERIAL_ASSIGN_TAB.part_no%TYPE;
   catch_qty_    MATERIAL_HISTORY_TAB.catch_qty%TYPE;
   input_qty_     MATERIAL_HISTORY_TAB.input_qty%TYPE;
   input_uom_    MATERIAL_HISTORY_TAB.input_uom%TYPE;
   input_value_    MATERIAL_HISTORY_TAB.input_value%TYPE;

BEGIN


   --SetUserID(in_attr_, attr_);

   ptr_ := NULL;

   WHILE (Client_SYS.Get_Next_From_Attr(in_attr_, ptr_, name_, value_)) LOOP

      IF (name_ = 'CONTRACT') THEN
         contract_ := value_;
      ELSIF (name_ = 'PART_NO') THEN
         part_no_ := value_;
      ELSIF (name_ = 'ORDER_NO') THEN
         order_no_ := value_;
      ELSIF (name_ = 'RELEASE_NO') THEN
         release_no_ := value_;
      ELSIF (name_ = 'SEQUENCE_NO') THEN
         sequence_no_ := value_;
      ELSIF (name_ = 'LINE_ITEM_NO') THEN
         line_item_no_ := value_;
      ELSIF (name_ = 'LOCATION_NO') THEN
         location_no_ := value_;
      ELSIF (name_ = 'LOT_BATCH_NO') THEN
         lot_batch_no_ := value_;
      ELSIF (name_ = 'SERIAL_NO') THEN
         serial_no_ := value_;
      ELSIF (name_ = 'ENG_CHG_LEVEL') THEN
         eng_chg_level_ := value_;
      ELSIF (name_ = 'WAIV_DEV_REJ_NO') THEN
         waiv_dev_rej_no_ := value_;
      ELSIF (name_ = 'QTY_ASSIGNED') THEN
         qty_ := value_;
      ELSIF (name_ = 'ACTIVITY_SEQ') THEN
         activity_seq_ := value_;
      ELSIF (name_ = 'CATCH_WEIGHT') THEN
         catch_qty_ := value_;
      ELSIF (name_ = 'INPUT_QUANTITY') THEN
         input_qty_ := value_;
      ELSIF (name_ = 'INPUT_UNIT_MEAS') THEN
         input_uom_ := value_;
      ELSIF (name_ = 'INPUT_VALUES') THEN
         input_value_ := value_;
      END IF;

   END LOOP;

   Shop_Order_Int_API.Manual_Issue(
		order_no_,
		release_no_,
		sequence_no_,
		line_item_no_,
		contract_,
		part_no_,
		location_no_,
		lot_batch_no_,
		serial_no_,
		eng_chg_level_,
		waiv_dev_rej_no_,
		activity_seq_,
		catch_qty_,
		qty_,
		input_qty_,
		input_uom_,
		input_value_);

END ISSUE;

PROCEDURE MANUAL_ISSUE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  order_no_              SHOP_MATERIAL_ALLOC.order_no%TYPE;
  release_no_            SHOP_MATERIAL_ALLOC.release_no%TYPE;
  sequence_no_           SHOP_MATERIAL_ALLOC.sequence_no%TYPE;
  line_item_no_          SHOP_MATERIAL_ALLOC.line_item_no%TYPE;
  contract_              SHOP_MATERIAL_ALLOC.contract%TYPE;
  part_no_               SHOP_MATERIAL_ALLOC.part_no%TYPE;
  location_no_           INVENTORY_PART_IN_STOCK.location_no%TYPE;
  lot_batch_no_          INVENTORY_PART_IN_STOCK.lot_batch_no%TYPE;
  serial_no_             INVENTORY_PART_IN_STOCK.serial_no%TYPE;
  eng_chg_level_         INVENTORY_PART_IN_STOCK.eng_chg_level%TYPE;
  waiv_dev_rej_no_       INVENTORY_PART_IN_STOCK.waiv_dev_rej_no%TYPE;
  activity_seq_          INVENTORY_PART_IN_STOCK.activity_seq%TYPE;
  catch_qty_             INVENTORY_PART_IN_STOCK.catch_qty_onhand%TYPE;
  qty_issued_            INVENTORY_PART_IN_STOCK.qty_onhand%TYPE;
  input_qty_             INVENTORY_PART_IN_STOCK.qty_onhand%TYPE;
  input_uom_             CUSTOMER_ORDER_RESERVATION.input_unit_meas%TYPE;
  input_value_           CUSTOMER_ORDER_RESERVATION.input_variable_values%TYPE;

  attr_ VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  release_no_            := CLIENT_SYS.Get_Item_Value('RELEASE_NO', attr_);
  sequence_no_           := CLIENT_SYS.Get_Item_Value('SEQUENCE_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  activity_seq_          := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);
  catch_qty_             := NULL;
  qty_issued_            := CLIENT_SYS.Get_Item_Value('QTY_ISSUED', attr_);
  input_qty_             := NULL;
  input_uom_             := NULL;
  input_value_           := NULL;



  SHOP_ORDER_INT_API.Manual_Issue(order_no_,
                                  release_no_,
                                  sequence_no_,
                                  line_item_no_,
                                  contract_,
                                  part_no_,
                                  location_no_,
                                  lot_batch_no_,
                                  serial_no_,
                                  eng_chg_level_,
                                  waiv_dev_rej_no_,
                                  activity_seq_,
                                  catch_qty_,
                                  qty_issued_,
                                  input_qty_,
                                  input_uom_,
                                  input_value_);


  out_attr_ := attr_;

END MANUAL_ISSUE;


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

END PICK_RESERVATION;

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


PROCEDURE SO_RECEIVE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  RECEIVE(attr_, attr_);

  out_attr_ := attr_;

END SO_RECEIVE;

PROCEDURE SO_ISSUE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

--  RESERVE(attr_, attr_);
  MANUAL_ISSUE(attr_, attr_);

  out_attr_ := attr_;

END SO_ISSUE;

PROCEDURE SO_RESERVE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS


  order_no_              ESI_SHOP_MATERIAL_ALLOC.order_no%TYPE;
  release_no_            ESI_SHOP_MATERIAL_ALLOC.release_no%TYPE;
  sequence_no_           ESI_SHOP_MATERIAL_ALLOC.sequence_no%TYPE;
  line_item_no_          ESI_SHOP_MATERIAL_ALLOC.line_item_no%TYPE;
  contract_              ESI_SHOP_MATERIAL_ALLOC.contract%TYPE;
  part_no_               ESI_SHOP_MATERIAL_ALLOC.part_no%TYPE;
  location_no_           ESI_SHOP_MATERIAL_ALLOC.location_no%TYPE;
  lot_batch_no_          ESI_SHOP_MATERIAL_ALLOC.lot_batch_no%TYPE;
  serial_no_             ESI_SHOP_MATERIAL_ALLOC.serial_no%TYPE;
  eng_chg_level_         ESI_SHOP_MATERIAL_ALLOC.eng_chg_level%TYPE;
  waiv_dev_rej_no_       ESI_SHOP_MATERIAL_ALLOC.waiv_dev_rej_no%TYPE;
  activity_seq_          ESI_SHOP_MATERIAL_ALLOC.activity_seq%TYPE;

  to_location_no_        ESI_INVENTORY.location_no%TYPE;
  
  attr_                  VARCHAR2(2000);

  assignment_            SHOP_MATERIAL_ASSIGN_API.Public_Rec;

  CURSOR existing_reservations IS
  SELECT *
  FROM   shop_material_assign
  WHERE  order_no = order_no_
  AND    release_no = release_no_
  AND    sequence_no = sequence_no_
  AND    line_item_no = line_item_no_
  AND    contract = contract_
  AND    part_no = part_no_
  AND    location_no = location_no_
  AND    lot_batch_no = lot_batch_no_
  AND    serial_no = serial_no_
  AND    eng_chg_level = eng_chg_level_
  AND    waiv_dev_rej_no = waiv_dev_rej_no_
  AND    activity_seq = activity_seq_;

  existing_reservations_   existing_reservations%ROWTYPE;
BEGIN
  
  to_location_no_                 := CLIENT_SYS.Get_Item_Value('TO_LOCATION_NO' , in_attr_);
  
  IF to_location_no_ is not null THEN
      attr_ := in_attr_;
      MOVE_PART(attr_, attr_);
  END IF;
  
  attr_ := in_attr_;
  IF to_location_no_ is not null THEN
      CLIENT_SYS.Set_Item_Value('LOCATION_NO', to_location_no_, attr_);
  END IF;


  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
  release_no_            := CLIENT_SYS.Get_Item_Value('RELEASE_NO', attr_);
  sequence_no_           := CLIENT_SYS.Get_Item_Value('SEQUENCE_NO', attr_);
  line_item_no_          := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
  contract_              := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
  part_no_               := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
  location_no_           := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
  lot_batch_no_          := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
  serial_no_             := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
  eng_chg_level_         := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
  waiv_dev_rej_no_       := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
  activity_seq_          := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);

  OPEN existing_reservations;
  FETCH  existing_reservations
  INTO   existing_reservations_;

  IF (existing_reservations%NOTFOUND) THEN
     CLOSE existing_reservations;
     NEW_RESERVATION(attr_, attr_);
  ELSE
     CLOSE existing_reservations;
     MODIFY_RESERVATION(attr_, attr_);
  END IF;



  out_attr_ := attr_;

END SO_RESERVE;

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

   IF  transaction_ = 'SO_RECEIVE' THEN SO_RECEIVE(attr_, attr_);

   ELSIF  transaction_ = 'SO_ISSUE' THEN SO_ISSUE(attr_, attr_);

   ELSIF  transaction_ = 'SO_RESERVE' THEN SO_RESERVE(attr_, attr_);

   ELSE RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');

   END IF;

   out_attr_ := attr_;

END TRANSACT;

END ESI_SW_SHOP_ORDER_API;
/
