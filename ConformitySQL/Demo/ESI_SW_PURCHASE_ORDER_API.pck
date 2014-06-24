CREATE OR REPLACE PACKAGE ESI_SW_PURCHASE_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS PO API's
-----------------------------------------------------------------------------------------


FUNCTION PACKAGE RETURN VARCHAR2;
FUNCTION VERSION RETURN VARCHAR2;

PROCEDURE TRANSACT (in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

END ESI_SW_PURCHASE_ORDER_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_PURCHASE_ORDER_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Tosoh Package
  -- Author:              Allen Byerly
  -- Version:             7.3.0.0
  -- Date:                02/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS PO API's
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

PROCEDURE RECEIVE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

   order_no_                      PURCHASE_RECEIPT.order_no%TYPE;
   line_no_                       PURCHASE_RECEIPT.line_no%TYPE;
   release_no_                    PURCHASE_RECEIPT.release_no%TYPE;
   receipt_no_                    PURCHASE_RECEIPT.receipt_no%TYPE;
   receipt_reference_             PURCHASE_RECEIPT.receipt_reference%TYPE;
   receiver_                      PURCHASE_RECEIPT.receiver%TYPE;
   qty_arrived_                   PURCHASE_RECEIPT.qty_arrived%TYPE;


   qty_to_inspect_                PURCHASE_RECEIPT.qty_to_inspect%TYPE;
   arrival_date_                  PURCHASE_RECEIPT.arrival_date%TYPE;
   receive_case_                  PURCHASE_RECEIPT.receive_case%TYPE;
   qc_code_                       PURCHASE_RECEIPT.qc_code%TYPE;
   contract_                      INVENTORY_PART_IN_STOCK.contract%TYPE;
   part_no_                       INVENTORY_PART_IN_STOCK.part_no%TYPE;
   start_date_                    DATE;
   expiration_date_               DATE;
   inventory_part_                VARCHAR2(6);
   location_no_                   INVENTORY_PART_IN_STOCK.location_no%TYPE;
   lot_batch_no_                  INVENTORY_PART_IN_STOCK.lot_batch_no%TYPE;
   serial_no_                     INVENTORY_PART_IN_STOCK.serial_no%TYPE;
   eng_chg_level_                 INVENTORY_PART_IN_STOCK.eng_chg_level%TYPE;
   waiv_dev_rej_no_               INVENTORY_PART_IN_STOCK.waiv_dev_rej_no%TYPE;
   lot_tracking_code_             PART_CATALOG.lot_tracking_code%TYPE;

   info_                          VARCHAR2(2000);
   arrival_result_keys_           VARCHAR2(2000);
   bar_codes_                     VARCHAR2(2000);
   receipt_info_                  VARCHAR2(2000);
	 ap_invoice_no_                 INVOICE_NUMBER_SERIES.current_value%TYPE;
   message_                       VARCHAR2(2000);
   print_arrival_                 VARCHAR2(5);
   print_bar_codes_               VARCHAR2(5);

BEGIN

  order_no_                      := CLIENT_SYS.Get_Item_Value('ORDER_NO',           in_attr_);
  line_no_                       := CLIENT_SYS.Get_Item_Value('LINE_NO',            in_attr_);
  release_no_                    := CLIENT_SYS.Get_Item_Value('RELEASE_NO',         in_attr_);
  receipt_reference_             := CLIENT_SYS.Get_Item_Value('RECEIPT_REFERENCE',  in_attr_);
  receiver_                      := CLIENT_SYS.Get_Item_Value('RECEIVER',           in_attr_);
  qty_arrived_                   := CLIENT_SYS.Get_Item_Value('QTY_ARRIVED',        in_attr_);


  qty_to_inspect_                := RECEIVE_PURCHASE_ORDER_API.Get_Qty_To_Inspect(order_no_, line_no_, release_no_, qty_arrived_);
  arrival_date_                  := TO_DATE(CLIENT_SYS.Get_Item_Value('ARRIVAL_DATE',       in_attr_), 'MM/DD/YYYY HH:MI:SS AM');
  receive_case_                  := PURCHASE_ORDER_LINE_PART_API.Get_Receive_Case(order_no_, line_no_, release_no_);
  qc_code_                       := PURCHASE_ORDER_LINE_PART_API.Get_Qc_Code(order_no_, line_no_, release_no_);
  contract_                      := CLIENT_SYS.Get_Item_Value('CONTRACT',           in_attr_);
  part_no_                       := CLIENT_SYS.Get_Item_Value('PART_NO',            in_attr_);
--  start_date_                    := TO_DATE(CLIENT_SYS.Get_Item_Value('START_DATE', in_attr_), 'MM/DD/YYYY HH:MI:SS AM');
  expiration_date_               := TO_DATE(CLIENT_SYS.Get_Item_Value('EXPIRATION_DATE', in_attr_), 'DDMMYYYY');
  inventory_part_                := REPLACE(REPLACE(purchase_order_line_api.Is_Inventory_Part(order_no_, line_no_, release_no_), '1', 'TRUE'), 0, 'FALSE');
  location_no_                   := CLIENT_SYS.Get_Item_Value('LOCATION_NO',        in_attr_);
  lot_batch_no_                  := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO',       in_attr_);
  serial_no_                     := CLIENT_SYS.Get_Item_Value('SERIAL_NO',          in_attr_);
  eng_chg_level_                 := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL',      in_attr_);
  waiv_dev_rej_no_               := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO',    in_attr_);

  info_                          := NULL;
  arrival_result_keys_           := NULL;
  bar_codes_                     := NULL;
  message_                       := MESSAGE_SYS.Construct('');
  print_arrival_                 := 'TRUE';
  print_bar_codes_               := 'FALSE';
  lot_tracking_code_             := PART_CATALOG_API.Get_Lot_Tracking_Code(part_no_);

  IF lot_tracking_code_ = 'Order Based' THEN
			lot_batch_no_ := RECEIVE_PURCHASE_ORDER_API.Get_Next_Lot_Batch_No(order_no_, line_no_);
  END IF;

  IF (start_date_ IS NOT NULL) THEN
     expiration_date_ := start_date_ + INVENTORY_PART_API.Get_Durability_Day(contract_, part_no_);
  END IF;

  MESSAGE_SYS.Add_Attribute(message_, 'ORDER_NO',          order_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'LINE_NO',           line_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'RELEASE_NO',        release_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'RECEIPT_REFERENCE', receipt_reference_);
  MESSAGE_SYS.Add_Attribute(message_, 'RECEIVER',          receiver_);
  MESSAGE_SYS.Add_Attribute(message_, 'QTY_ARRIVED',       qty_arrived_);
  MESSAGE_SYS.Add_Attribute(message_, 'QTY_TO_INSPECT',    qty_to_inspect_);
  MESSAGE_SYS.Add_Attribute(message_, 'ARRIVAL_DATE',      arrival_date_);
  MESSAGE_SYS.Add_Attribute(message_, 'RECEIVE_CASE',      receive_case_);
  MESSAGE_SYS.Add_Attribute(message_, 'QC_CODE',           qc_code_);
  MESSAGE_SYS.Add_Attribute(message_, 'CONTRACT',          contract_);
  MESSAGE_SYS.Add_Attribute(message_, 'PART_NO',           part_no_);
--  MESSAGE_SYS.Add_Attribute(message_, 'START_DATE',        start_date_);
  MESSAGE_SYS.Add_Attribute(message_, 'INVENTORY_PART',    inventory_part_);

  IF expiration_date_ IS NOT NULL THEN
     MESSAGE_SYS.Add_Attribute(message_, 'EXPIRATION_DATE',   expiration_date_);
  END IF;

  MESSAGE_SYS.Add_Attribute(message_, 'LOCATION_NO',       location_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'LOT_BATCH_NO',      lot_batch_no_);

  MESSAGE_SYS.Add_Attribute(message_, 'SERIAL_NO',         serial_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'ENG_CHG_LEVEL',     eng_chg_level_);
  MESSAGE_SYS.Add_Attribute(message_, 'CATCH_QTY_ARRIVED', '');
	MESSAGE_SYS.Add_Attribute(message_, 'INPUT_VARIABLE_VALUES', '');
  MESSAGE_SYS.Add_Attribute(message_, 'WAIV_DEV_REJ_NO',   waiv_dev_rej_no_);

  RECEIVE_PURCHASE_ORDER_API.Packed_Arrival__(info_,
                                              arrival_result_keys_,
                                              bar_codes_,
                                              receipt_info_,
                                              ap_invoice_no_,
                                              message_,
                                              print_arrival_,
                                              print_bar_codes_);

 -- MESSAGE_SYS.Get_Attribute(message_, 'RECEIPT_NO', receipt_no_);
  SELECT MAX(RECEIPT_NO)
  INTO receipt_no_
  FROM PURCHASE_RECEIPT_NEW
  WHERE order_no = order_no_
  AND line_no = line_no_
  AND release_no = release_no_
  AND receiver = receiver_;

  out_attr_ := in_attr_;

  CLIENT_SYS.Set_Item_Value('ORDER_NO',            order_no_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('LINE_NO',             line_no_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('RELEASE_NO',          release_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIPT_REFERENCE',   receipt_reference_,   out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIVER',            receiver_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('QTY_ARRIVED',         qty_arrived_,         out_attr_);
  CLIENT_SYS.Set_Item_Value('QTY_TO_INSPECT',      qty_to_inspect_,      out_attr_);
  CLIENT_SYS.Set_Item_Value('ARRIVAL_DATE',        TO_CHAR(arrival_date_, 'DD-MON-YYYY'),        out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIVE_CASE',        receive_case_,        out_attr_);
  CLIENT_SYS.Set_Item_Value('QC_CODE',             qc_code_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('CONTRACT',            contract_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('PART_NO',             part_no_,             out_attr_);
--  CLIENT_SYS.Set_Item_Value('START_DATE',          start_date_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('INVENTORY_PART',      inventory_part_,      out_attr_);
--  CLIENT_SYS.Set_Item_Value('EXPIRATION_DATE',     TO_CHAR(expiration_date_, 'DD-MON-YYYY'),     out_attr_);
  CLIENT_SYS.Set_Item_Value('LOCATION_NO',         location_no_,         out_attr_);
  CLIENT_SYS.Set_Item_Value('LOT_BATCH_NO',        lot_batch_no_,        out_attr_);
  CLIENT_SYS.Set_Item_Value('SERIAL_NO',           serial_no_,           out_attr_);
  CLIENT_SYS.Set_Item_Value('ENG_CHG_LEVEL',       eng_chg_level_,       out_attr_);
  CLIENT_SYS.Set_Item_Value('WAIV_DEV_REJ_NO',     waiv_dev_rej_no_,     out_attr_);

  CLIENT_SYS.Add_To_Attr('RECEIPT_NO',          receipt_no_,          out_attr_);
  CLIENT_SYS.Add_To_Attr('ARRIVAL_RESULT_KEYS', arrival_result_keys_, out_attr_);
  CLIENT_SYS.Add_To_Attr('BAR_CODES',           bar_codes_,           out_attr_);
  CLIENT_SYS.Add_To_Attr('INFO', info_, out_attr_);
 -- CLIENT_SYS.Add_Info('INFO', info_, out_attr_);

END RECEIVE;

--MODIFICATION: Internal Order Receipt
PROCEDURE RECEIVE_WITH_DIFFERENCES(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
  order_no_                      PURCHASE_RECEIPT.order_no%TYPE;
  line_no_                       PURCHASE_RECEIPT.line_no%TYPE;
  release_no_                    PURCHASE_RECEIPT.release_no%TYPE;
  receipt_no_                    PURCHASE_RECEIPT.receipt_no%TYPE;
  receipt_reference_             PURCHASE_RECEIPT.receipt_reference%TYPE;
  receiver_                      PURCHASE_RECEIPT.receiver%TYPE;
  qty_arrived_                   PURCHASE_RECEIPT.qty_arrived%TYPE;
  qty_to_inspect_                PURCHASE_RECEIPT.qty_to_inspect%TYPE;
  arrival_date_                  PURCHASE_RECEIPT.arrival_date%TYPE;
  receive_case_                  PURCHASE_RECEIPT.receive_case%TYPE;
  qc_code_                       PURCHASE_RECEIPT.qc_code%TYPE;

  contract_                      INVENTORY_PART_IN_STOCK.contract%TYPE;
  part_no_                       INVENTORY_PART_IN_STOCK.part_no%TYPE;
  location_no_                   INVENTORY_PART_IN_STOCK.location_no%TYPE;
  lot_batch_no_                  INVENTORY_PART_IN_STOCK.lot_batch_no%TYPE;
  serial_no_                     INVENTORY_PART_IN_STOCK.serial_no%TYPE;
  eng_chg_level_                 INVENTORY_PART_IN_STOCK.eng_chg_level%TYPE;
  start_date_                    DATE;
  expiration_date_               DATE;
  waiv_dev_rej_no_               INVENTORY_PART_IN_STOCK.waiv_dev_rej_no%TYPE;
--  condition_code_id_             INVENTORY_PART_IN_STOCK.condition_code_id%TYPE;

  info_                          VARCHAR2(2000);
  ap_invoice_no_                 INVOICE_NUMBER_SERIES.current_value%TYPE;
  message_                       VARCHAR2(2000);
  arrival_result_keys_           VARCHAR2(2000);
  bar_codes_                     VARCHAR2(2000);

BEGIN

  order_no_                      := CLIENT_SYS.Get_Item_Value('ORDER_NO',          in_attr_);
  line_no_                       := CLIENT_SYS.Get_Item_Value('LINE_NO',           in_attr_);
  release_no_                    := CLIENT_SYS.Get_Item_Value('RELEASE_NO',        in_attr_);
  receipt_reference_             := CLIENT_SYS.Get_Item_Value('RECEIPT_REFERENCE', in_attr_);
  receiver_                      := CLIENT_SYS.Get_Item_Value('RECEIVER',          in_attr_);
  qty_arrived_                   := CLIENT_SYS.Get_Item_Value('QTY_ARRIVED',       in_attr_);
  qty_to_inspect_                := RECEIVE_PURCHASE_ORDER_API.Get_Qty_To_Inspect(order_no_, line_no_, release_no_, qty_arrived_);
  arrival_date_                  := Site_API.Get_Site_Date(User_Default_API.Get_Contract);
  receive_case_                  := PURCHASE_ORDER_LINE_PART_API.Get_Receive_Case(order_no_, line_no_, release_no_);
  qc_code_                       := PURCHASE_ORDER_LINE_PART_API.Get_Qc_Code(order_no_, line_no_, release_no_);

  contract_                      := CLIENT_SYS.Get_Item_Value('CONTRACT',           in_attr_);
  part_no_                       := CLIENT_SYS.Get_Item_Value('PART_NO',            in_attr_);
  location_no_                   := CLIENT_SYS.Get_Item_Value('LOCATION_NO',        in_attr_);
  lot_batch_no_                  := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO',       in_attr_);
  serial_no_                     := CLIENT_SYS.Get_Item_Value('SERIAL_NO',          in_attr_);
  eng_chg_level_                 := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL',      in_attr_);
  start_date_                    := TO_DATE(CLIENT_SYS.Get_Item_Value('START_DATE', in_attr_), 'MM/DD/YYYY');
  expiration_date_               := TO_DATE(CLIENT_SYS.Get_Item_Value('EXPIRATION_DATE', in_attr_), 'MM/DD/YYYY HH:MI:SS AM');
  waiv_dev_rej_no_               := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO',    in_attr_);
 -- condition_code_id_             := CONDITION_CODE_API.Get_Default_Condition_Id;

  RECEIVE_PURCHASE_ORDER_API.Create_New_Receipt(receipt_no_,
                                                order_no_,
                                                line_no_,
                                                release_no_,
                                                receipt_reference_,
                                                receiver_,
                                                qty_arrived_,
                                                0,
                                                qty_to_inspect_,
                                                arrival_date_,
                                                receive_case_,
                                                qc_code_);

  IF (start_date_ IS NOT NULL) THEN
     expiration_date_ := start_date_ + INVENTORY_PART_API.Get_Durability_Day(contract_, part_no_);
  END IF;

  MESSAGE_SYS.Add_Attribute(message_, 'LOCATION_NO',        location_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'LOT_BATCH_NO',       lot_batch_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'SERIAL_NO',          serial_no_);
  MESSAGE_SYS.Add_Attribute(message_, 'ENG_CHG_LEVEL',      eng_chg_level_);
  MESSAGE_SYS.Add_Attribute(message_, 'QTY_IN_STORE',       qty_arrived_);
  MESSAGE_SYS.Add_Attribute(message_, 'START_DATE',         start_date_);
  MESSAGE_SYS.Add_Attribute(message_, 'EXPIRATION_DATE',    expiration_date_);
  MESSAGE_SYS.Add_Attribute(message_, 'WAIV_DEV_REJ_NO',    waiv_dev_rej_no_);
--  MESSAGE_SYS.Add_Attribute(message_, 'CONDITION_CODE_ID',  condition_code_id_);

  RECEIVE_PURCHASE_ORDER_API.Packed_Inventory_Receipt__(info_,
                                                        ap_invoice_no_,
                                                        order_no_,
                                                        line_no_,
                                                        release_no_,
                                                        receipt_no_,
                                                        message_,
                                                        qty_arrived_);

  out_attr_ := in_attr_;

  CLIENT_SYS.Set_Item_Value('ORDER_NO',            order_no_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('LINE_NO',             line_no_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('RELEASE_NO',          release_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIPT_REFERENCE',   receipt_reference_,   out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIVER',            receiver_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('QTY_ARRIVED',         qty_arrived_,         out_attr_);
  CLIENT_SYS.Set_Item_Value('QTY_TO_INSPECT',      qty_to_inspect_,      out_attr_);
  CLIENT_SYS.Set_Item_Value('ARRIVAL_DATE',        TO_CHAR(arrival_date_, 'DD-MON-YYYY'),        out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIVE_CASE',        receive_case_,        out_attr_);
  CLIENT_SYS.Set_Item_Value('QC_CODE',             qc_code_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('START_DATE',          start_date_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('EXPIRATION_DATE',      TO_CHAR(expiration_date_, 'DD-MON-YYYY'),     out_attr_);
  CLIENT_SYS.Set_Item_Value('CONTRACT',            contract_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('PART_NO',             part_no_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('LOCATION_NO',         location_no_,         out_attr_);
  CLIENT_SYS.Set_Item_Value('LOT_BATCH_NO',        lot_batch_no_,        out_attr_);
  CLIENT_SYS.Set_Item_Value('SERIAL_NO',           serial_no_,           out_attr_);
  CLIENT_SYS.Set_Item_Value('ENG_CHG_LEVEL',       eng_chg_level_,       out_attr_);
  CLIENT_SYS.Set_Item_Value('WAIV_DEV_REJ_NO',     waiv_dev_rej_no_,     out_attr_);

  CLIENT_SYS.Add_To_Attr('RECEIPT_NO',             receipt_no_,          out_attr_);
  CLIENT_SYS.Add_To_Attr('ARRIVAL_RESULT_KEYS',    arrival_result_keys_, out_attr_);
  CLIENT_SYS.Add_To_Attr('BAR_CODES',              bar_codes_,           out_attr_);

END RECEIVE_WITH_DIFFERENCES;
--MODIFICATION: Internal Order Receipt

PROCEDURE INSPECT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  order_no_                      PURCHASE_RECEIPT_NEW.order_no%TYPE;
  line_no_                       PURCHASE_RECEIPT_NEW.line_no%TYPE;
  release_no_                    PURCHASE_RECEIPT_NEW.release_no%TYPE;
  receipt_no_                    PURCHASE_RECEIPT_NEW.receipt_reference%TYPE;
  qty_inspected_                 PURCHASE_RECEIPT_NEW.qty_inspected%TYPE;
  no_of_inspections_             NUMBER;
  info_                          VARCHAR2(2000);

BEGIN

  order_no_                      := CLIENT_SYS.Get_Item_Value('ORDER_NO',      in_attr_);
  line_no_                       := CLIENT_SYS.Get_Item_Value('LINE_NO',       in_attr_);
  release_no_                    := CLIENT_SYS.Get_Item_Value('RELEASE_NO',    in_attr_);
  receipt_no_                    := CLIENT_SYS.Get_Item_Value('RECEIPT_NO',    in_attr_);
  qty_inspected_                 := CLIENT_SYS.Get_Item_Value('QTY_INSPECTED', in_attr_);
  no_of_inspections_             := PURCHASE_RECEIPT_API.Get_No_Of_Inspections(order_no_,
                                                                               line_no_,
                                                                               release_no_,
                                                                               receipt_no_) + 1;

  PURCHASE_RECEIPT_API.Modify_Qty_Inspected(order_no_,
                                            line_no_,
                                            release_no_,
                                            receipt_no_,
                                            qty_inspected_,
                                            no_of_inspections_);

  out_attr_ := in_attr_;

  CLIENT_SYS.Set_Item_Value('ORDER_NO',            order_no_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('LINE_NO',             line_no_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('RELEASE_NO',          release_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIPT_NO',          receipt_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('QTY_INSPECTED',       qty_inspected_,       out_attr_);

  CLIENT_SYS.Add_Info('INFO', info_, out_attr_);

END INSPECT;

PROCEDURE MOVE_TO_STOCK(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
  location_no_                   INVENTORY_PART_LOCATION.location_no%TYPE;
  lot_batch_no_                  INVENTORY_PART_LOCATION.lot_batch_no%TYPE;
  serial_no_                     INVENTORY_PART_LOCATION.serial_no%TYPE;
  eng_chg_level_                 INVENTORY_PART_LOCATION.eng_chg_level%TYPE;
  waiv_dev_rej_no_               INVENTORY_PART_LOCATION.waiv_dev_rej_no%TYPE;
  order_no_		                   PURCHASE_RECEIPT.order_no%TYPE;
  line_no_		                   PURCHASE_RECEIPT.line_no%TYPE;
  release_no_		                 PURCHASE_RECEIPT.release_no%TYPE;
  receipt_no_                    PURCHASE_RECEIPT.receipt_no%TYPE;
  to_location_no_                INVENTORY_PART_LOCATION.location_no%TYPE;
  new_lot_batch_no_              INVENTORY_PART_LOCATION.lot_batch_no%TYPE;
  qty_to_move_                   PURCHASE_RECEIPT.qty_arrived%TYPE;
 -- condition_code_id_             INVENTORY_PART_LOCATION.condition_code_id%TYPE;

  info_                          VARCHAR2(2000);
  ap_invoice_no_                 INVOICE_NUMBER_SERIES.current_value%TYPE;

BEGIN

  location_no_                   := CLIENT_SYS.Get_Item_Value('LOCATION_NO',       in_attr_);
  lot_batch_no_                  := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO',      in_attr_);
  serial_no_                     := CLIENT_SYS.Get_Item_Value('SERIAL_NO',         in_attr_);
  eng_chg_level_                 := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL',     in_attr_);
  waiv_dev_rej_no_               := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO',   in_attr_);
  order_no_		                   := CLIENT_SYS.Get_Item_Value('ORDER_NO',          in_attr_);
  line_no_		                   := CLIENT_SYS.Get_Item_Value('LINE_NO',           in_attr_);
  release_no_		                 := CLIENT_SYS.Get_Item_Value('RELEASE_NO',        in_attr_);
  receipt_no_                    := CLIENT_SYS.Get_Item_Value('RECEIPT_NO',        in_attr_);
  to_location_no_                := CLIENT_SYS.Get_Item_Value('TO_LOCATION_NO',    in_attr_);
  new_lot_batch_no_              := CLIENT_SYS.Get_Item_Value('NEW_LOT_BATCH_NO',  in_attr_);
  qty_to_move_                   := CLIENT_SYS.Get_Item_Value('QTY_TO_MOVE',       in_attr_);
 -- condition_code_id_             := CLIENT_SYS.Get_Item_Value('CONDITION_CODE_ID', in_attr_);

  RECEIVE_PURCHASE_ORDER_API.Move_Receipt(info_,
                                          ap_invoice_no_,
                                          location_no_,
                                          lot_batch_no_,
                                          serial_no_,
                                          eng_chg_level_,
                                          waiv_dev_rej_no_,
                                          order_no_,
                                          line_no_,
                                          release_no_,
                                          receipt_no_,
                                          to_location_no_,
                                          new_lot_batch_no_,
                                          qty_to_move_,
                                          0);

  out_attr_ := in_attr_;

  CLIENT_SYS.Set_Item_Value('LOCATION_NO',         to_location_no_,      out_attr_);
  CLIENT_SYS.Set_Item_Value('LOT_BATCH_NO',        new_lot_batch_no_,    out_attr_);
  CLIENT_SYS.Set_Item_Value('SERIAL_NO',           serial_no_,           out_attr_);
  CLIENT_SYS.Set_Item_Value('ENG_CHG_LEVEL',       eng_chg_level_,       out_attr_);
  CLIENT_SYS.Set_Item_Value('WAIV_DEV_REJ_NO',     waiv_dev_rej_no_,     out_attr_);
  CLIENT_SYS.Set_Item_Value('ORDER_NO',            order_no_,            out_attr_);
  CLIENT_SYS.Set_Item_Value('LINE_NO',             line_no_,             out_attr_);
  CLIENT_SYS.Set_Item_Value('RELEASE_NO',          release_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIPT_NO',          receipt_no_,          out_attr_);
  CLIENT_SYS.Set_Item_Value('RECEIVED_QTY',        qty_to_move_,         out_attr_);
--  CLIENT_SYS.Set_Item_Value('CONDITION_CODE_ID',   condition_code_id_,   out_attr_);

END MOVE_TO_STOCK;



--MODIFIED MAIN PO RECEIVE API
PROCEDURE PO_RECEIVE(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  contract_                      INVENTORY_PART_IN_STOCK.contract%TYPE;
  order_no_                      PURCHASE_RECEIPT.order_no%TYPE;
  line_no_                       PURCHASE_RECEIPT.line_no%TYPE;
  release_no_                    PURCHASE_RECEIPT.release_no%TYPE;
  receipt_no_                    PURCHASE_RECEIPT.receipt_no%TYPE;
  order_code_                    PURCHASE_ORDER_LINE_NEW.order_code%TYPE;
  part_no_                       INVENTORY_PART_IN_STOCK.part_no%TYPE;
  alternative_part_no_           INVENTORY_PART_IN_STOCK.part_no%TYPE;

  note_text_                     DOCUMENT_TEXT.note_text%TYPE;

  qty_arrived_                   PURCHASE_RECEIPT.qty_arrived%TYPE;
  qty_inspected_                 PURCHASE_RECEIPT.qty_to_inspect%TYPE;

  configuration_id_              INVENTORY_PART_IN_STOCK.configuration_id%TYPE;
  expiration_date_               INVENTORY_PART_IN_STOCK.expiration_date%TYPE;
  location_no_                   INVENTORY_PART_IN_STOCK.location_no%TYPE;
  lot_batch_no_                  INVENTORY_PART_IN_STOCK.lot_batch_no%TYPE;
  serial_no_                     INVENTORY_PART_IN_STOCK.serial_no%TYPE;
  eng_chg_level_                 INVENTORY_PART_IN_STOCK.eng_chg_level%TYPE;
  waiv_dev_rej_no_               INVENTORY_PART_IN_STOCK.waiv_dev_rej_no%TYPE;
  availability_control_id_       INVENTORY_PART_IN_STOCK.availability_control_id%TYPE;
  is_inventory_part_             VARCHAR2(20);
  inventory_part_                INVENTORY_PART%ROWTYPE;
  inventory_part_in_stock_       INVENTORY_PART_IN_STOCK_API.Public_Rec;

  vendor_no_                     SUPPLIER.vendor_no%TYPE;
  vendor_name_                   SUPPLIER.vendor_name%TYPE;
  inspection_code_               PURCHASE_ORDER_LINE.inspection_code%TYPE;
  receipt_date_                  PURCHASE_RECEIPT_NEW.arrival_date%TYPE;

  attr_                          VARCHAR2(2000);
  info1_                         VARCHAR2(2);

BEGIN

  order_no_                      := CLIENT_SYS.Get_Item_Value('ORDER_NO', in_attr_);
  line_no_                       := CLIENT_SYS.Get_Item_Value('LINE_NO', in_attr_);
  release_no_                    := CLIENT_SYS.Get_Item_Value('RELEASE_NO', in_attr_);
  order_code_                    := CLIENT_SYS.Get_Item_Value('ORDER_CODE', in_attr_);
  part_no_                       := CLIENT_SYS.Get_Item_Value('PART_NO', in_attr_);
  alternative_part_no_           := CLIENT_SYS.Get_Item_Value('ALTERNATIVE_PART_NO', in_attr_);
  qty_arrived_                   := CLIENT_SYS.Get_Item_Value('QTY_ARRIVED', in_attr_);
  qty_inspected_                 := CLIENT_SYS.Get_Item_Value('QTY_INSPECTED', in_attr_);
  inspection_code_               := PURCHASE_ORDER_LINE_API.Get_Inspection_Code(order_no_, line_no_, release_no_);
  availability_control_id_       := CLIENT_SYS.Get_Item_Value('AVAILABILITY_CONTROL_ID',      in_attr_);

  attr_ := in_attr_;

  RECEIVE(attr_, attr_);

  receipt_no_                    := CLIENT_SYS.Get_Item_Value('RECEIPT_NO',                    attr_);
  contract_                      := CLIENT_SYS.Get_Item_Value('CONTRACT',                      attr_);
  location_no_                   := CLIENT_SYS.Get_Item_Value('LOCATION_NO',                   attr_);
  part_no_                       := CLIENT_SYS.Get_Item_Value('PART_NO',                       attr_);
  configuration_id_              := '*';
  serial_no_                     := CLIENT_SYS.Get_Item_Value('SERIAL_NO',                     attr_);
  lot_batch_no_                  := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO',                  attr_);
  eng_chg_level_                 := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL',                 attr_);
  waiv_dev_rej_no_               := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO',               attr_);
  is_inventory_part_             := CLIENT_SYS.Get_Item_Value('INVENTORY_PART',                attr_);


  vendor_no_                     := PURCHASE_ORDER_API.Get_Vendor_No(order_no_);
  vendor_name_                   := SUPPLIER_API.Get_Vendor_Name(vendor_no_);

  IF availability_control_id_ IS NOT NULL AND is_inventory_part_ = 'TRUE' THEN
     INVENTORY_PART_IN_STOCK_API.Modify_Availability_Control_Id(contract_,
                                                                part_no_,
                                                                configuration_id_,
                                                                location_no_,
                                                                lot_batch_no_,
                                                                serial_no_,
                                                                eng_chg_level_,
                                                                waiv_dev_rej_no_,
                                                                '0',
                                                                availability_control_id_);
  END IF;

  inventory_part_in_stock_       := INVENTORY_PART_IN_STOCK_API.Get(contract_,
                                                                    part_no_,
                                                                    configuration_id_,
                                                                    location_no_,
                                                                    lot_batch_no_,
                                                                    serial_no_,
                                                                    eng_chg_level_,
                                                                    waiv_dev_rej_no_,
                                                                    '0');


  receipt_date_                   := PURCHASE_RECEIPT_API.Get_Arrival_Date(order_no_,
                                                                           line_no_,
                                                                           release_no_,
                                                                           receipt_no_);

  CLIENT_SYS.Add_To_Attr('RECEIPT_DATE', TO_CHAR(receipt_date_, 'DD/MM/YYYY'), attr_);
  CLIENT_SYS.Add_To_Attr('EXPIRATION_DATE', TO_CHAR(inventory_part_in_stock_.expiration_date, 'DD/MM/YYYY'), attr_);
  CLIENT_SYS.Add_To_Attr('SUPPLIER', vendor_name_,  attr_);
  CLIENT_SYS.Add_To_Attr('INFO1',    info1_, attr_);

  out_attr_ := attr_;

END PO_RECEIVE;
--MODIFIED MAIN PO RECEIVE API

--MODIFIED MAIN PO INSPECT API
PROCEDURE PO_INSPECT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  qty_approved_                  PURCHASE_RECEIPT_NEW.qty_inspected%TYPE;
  qty_inspected_                 PURCHASE_RECEIPT_NEW.qty_inspected%TYPE;

  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  qty_approved_                  := CLIENT_SYS.Get_Item_Value('QTY_APPROVED', in_attr_);
  qty_inspected_                 := CLIENT_SYS.Get_Item_Value('QTY_INSPECTED', in_attr_);

  CLIENT_SYS.Set_Item_Value('QTY_INSPECTED', qty_inspected_ + qty_approved_, attr_);

  INSPECT(attr_, attr_);

  out_attr_ := attr_;

END PO_INSPECT;
--MODIFIED MAIN PO INSPECT API

--MODIFIED MAIN PO MOVE TO STOCK API
PROCEDURE PO_MOVE_TO_STOCK(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

--  order_type_                    PURCHASE_ORDER_LINE_NEW.order_type%TYPE;
  order_no_                      PURCHASE_ORDER_LINE_NEW.order_no%TYPE;
  attr_                          VARCHAR2(2000);

BEGIN

  attr_ := in_attr_;

  MOVE_TO_STOCK(attr_, attr_);
--  order_no_              := CLIENT_SYS.Get_Item_Value('ORDER_NO' , attr_);

 -- order_type_            := PURCHASE_ORDER_API.Get_Order_Type(order_no_);

  out_attr_ := attr_;

END PO_MOVE_TO_STOCK;
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


   IF  transaction_ = 'PO_RECEIVE' THEN PO_RECEIVE(attr_, attr_);

   ELSIF transaction_ = 'PO_MOVE_TO_STOCK' THEN PO_MOVE_TO_STOCK(attr_, attr_);

   ELSIF transaction_ = 'PO_INSPECT' THEN PO_INSPECT(attr_, attr_);

   ELSE RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');

   END IF;

   out_attr_ := attr_;

--EXCEPTION
--   WHEN OTHERS THEN
--      RAISE_APPLICATION_ERROR(SQLCODE,  SQLERRM);
END TRANSACT;

END ESI_SW_PURCHASE_ORDER_API;
/
