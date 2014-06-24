CREATE OR REPLACE PACKAGE ESI_SW_TIME_CLOCK_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Demo Package
  -- Author:              Barry Bohlman
  -- Version:             7.3.0.0
  -- Date:                06/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS Employee API's
-----------------------------------------------------------------------------------------


FUNCTION PACKAGE RETURN VARCHAR2;
FUNCTION VERSION RETURN VARCHAR2;

PROCEDURE TRANSACT (in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

END ESI_SW_TIME_CLOCK_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_TIME_CLOCK_API IS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Demo Package
  -- Author:              Barry Bohlman
  -- Version:             7.3.0.0
  -- Date:                06/16/2011
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS Time Clock API's
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



PROCEDURE CLOCK_IN(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

  intype_         VARCHAR2(9);
  company_id_     VARCHAR2(20);
  emp_no_         VARCHAR2(11);
  reg_stamp_      DATE;
  v_stamp_date_   VARCHAR2(22);
  batch_          VARCHAR2(1);
  overtime_type_  VARCHAR2(10);
  abs_wage_code_  VARCHAR2(10);
  org_code_       VARCHAR2(10);
  day_type_       VARCHAR2(10);

BEGIN

   Client_SYS.Clear_Attr(attr_);

   intype_ := 'IN_NORMAL';
   batch_ := '0';
   overtime_type_  := NULL;
   abs_wage_code_  := NULL;
   org_code_       := NULL;
   day_type_       := NULL;

   company_id_ :=    Client_SYS.Get_Item_Value('COMPANY_ID', in_attr_);
   emp_no_ :=        Client_SYS.Get_Item_Value('EMP_NO', in_attr_);
   v_stamp_date_ :=  Client_SYS.Get_Item_Value('REG_STAMP', in_attr_);
   --day_type_ :=      Client_SYS.Get_Item_Value('DAY_TYPE', in_attr_);

   reg_stamp_ := TO_DATE(v_stamp_date_, 'MM/DD/YYYY HH:MI:SS AM');

   attr_ := create_stamps_api.Arrival(intype_,
   			     company_id_,
   			     emp_no_,
   			     reg_stamp_,
   			     batch_,
   			     overtime_type_,
   			     abs_wage_code_,
   			     org_code_,
   			     day_type_);


   out_attr_ := attr_;

END CLOCK_IN;


PROCEDURE CLOCK_OUT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS

  attr_                          VARCHAR2(2000);

  outtype_         VARCHAR2(20);
  company_id_     VARCHAR2(20);
  emp_no_         VARCHAR2(11);
  reg_stamp_      DATE;
  v_stamp_date_   VARCHAR2(22);
  batch_          VARCHAR2(1);
  overtime_type_  VARCHAR2(10);
  abs_wage_code_  VARCHAR2(10);
  org_code_       VARCHAR2(10);

BEGIN

   Client_SYS.Clear_Attr(attr_);

   outtype_ := 'OUT_NORMAL';
   batch_ := '0';
   overtime_type_  := NULL;
   abs_wage_code_  := NULL;
   org_code_       := NULL;

   company_id_ :=    Client_SYS.Get_Item_Value('COMPANY_ID', in_attr_);
   emp_no_ :=        Client_SYS.Get_Item_Value('EMP_NO', in_attr_);
   v_stamp_date_ :=  Client_SYS.Get_Item_Value('REG_STAMP', in_attr_);

   reg_stamp_ := TO_DATE(v_stamp_date_, 'MM/DD/YYYY HH:MI:SS AM');

   attr_ := create_stamps_api.Departure(outtype_,
   			     company_id_,
   			     emp_no_,
   			     reg_stamp_,
   			     batch_,
   			     overtime_type_,
   			     abs_wage_code_,
   			     org_code_);


   out_attr_ := attr_;

END CLOCK_OUT;

PROCEDURE START_OP(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
   intype_         VARCHAR2(20);
   company_id_     VARCHAR2(20);
   emp_no_         VARCHAR2(11);
   reg_stamp_      DATE;
   v_stamp_date_   VARCHAR2(22);
   batch_          VARCHAR2(1);
   contract_       VARCHAR2(5);
   OpId_           NUMBER;
   OpNo_           NUMBER;
   work_center_no_ VARCHAR2(5);
   order_no_     VARCHAR2(12);
   MchCode_        VARCHAR2(10);
   InfoCode_       VARCHAR2(12);

BEGIN

   intype_ := 'START';
   batch_ := '0';
   order_no_ := NULL;
   OpNo_ := NULL;
   contract_ := NULL;
   work_center_no_ := NULL;
   MchCode_ := NULL;
   InfoCode_ := NULL;

   company_id_ :=    Client_SYS.Get_Item_Value('COMPANY_ID', in_attr_);
   emp_no_ :=        Client_SYS.Get_Item_Value('EMP_NO', in_attr_);
   v_stamp_date_ :=  Client_SYS.Get_Item_Value('REG_STAMP', in_attr_);
   OpId_ :=          Client_SYS.Get_Item_Value('OP_ID', in_attr_);
   InfoCode_ :=      Client_SYS.Get_Item_Value('INFO_CODE', in_attr_);

   reg_stamp_ := TO_DATE(v_stamp_date_, 'MM/DD/YYYY HH:MI:SS AM');

   out_attr_ := CREATE_OP_STAMPS_API.Employee_Operation(intype_,
                                           company_id_,
                                           emp_no_,
                                           reg_stamp_,
                                           batch_,
                                           OpId_,
                                           order_no_,
                                           OpNo_,
                                           contract_,
                                           work_center_no_,
                                           MchCode_,
                                           InfoCode_);

END START_OP;

PROCEDURE STOP_OP(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
   stoptype_       VARCHAR2(9);
   stop_type_      VARCHAR2(9);
   company_id_     VARCHAR2(20);
   emp_no_         VARCHAR2(11);
   reg_stamp_      DATE;
   v_stamp_date_   VARCHAR2(22);
   batch_          VARCHAR2(1);
   contract_       VARCHAR2(5);
   OpId_           NUMBER;
   OpNo_           NUMBER;
   work_center_no_ VARCHAR2(5);
   order_no_     VARCHAR2(12);
   MchCode_        VARCHAR2(10);
   InfoCode_       VARCHAR2(12);

BEGIN

   batch_ := '0';
   order_no_ := NULL;
   OpNo_ := NULL;
   contract_ := NULL;
   work_center_no_ := NULL;
   MchCode_ := NULL;
   InfoCode_ := NULL;

   company_id_ :=    Client_SYS.Get_Item_Value('COMPANY_ID', in_attr_);
   emp_no_ :=        Client_SYS.Get_Item_Value('EMP_NO', in_attr_);
   v_stamp_date_ :=  Client_SYS.Get_Item_Value('REG_STAMP', in_attr_);
   OpId_ :=          Client_SYS.Get_Item_Value('OP_ID', in_attr_);
   stoptype_ :=      Client_SYS.Get_Item_Value('STOP_TYPE', in_attr_);

   stop_type_ := STOP_TYPE_API.ENCODE(nls_initcap(stoptype_));

   reg_stamp_ := TO_DATE(v_stamp_date_, 'MM/DD/YYYY HH:MI:SS AM');

   out_attr_ := CREATE_OP_STAMPS_API.Employee_Operation(stop_type_,
                                           company_id_,
                                           emp_no_,
                                           reg_stamp_,
                                           batch_,
                                           OpId_,
                                           order_no_,
                                           OpNo_,
                                           contract_,
                                           work_center_no_,
                                           MchCode_,
                                           InfoCode_);

END STOP_OP;

PROCEDURE STOP_OP_QTY(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)
IS
   stoptype_       VARCHAR2(9);
   stop_type_      VARCHAR2(9);
   company_id_     VARCHAR2(20);
   emp_no_         VARCHAR2(11);
   reg_stamp_      DATE;
   --v_stamp_date_   VARCHAR2(22);
   batch_          VARCHAR2(1);
   contract_       VARCHAR2(5);
   site_           VARCHAR2(5);
   OpId_           NUMBER;
   OpNo_           NUMBER;
   work_center_no_ VARCHAR2(5);
   order_no_     VARCHAR2(12);
   MchCode_        VARCHAR2(10);
   InfoCode_       VARCHAR2(12);
   qty_attr_	   VARCHAR2(2000);
   irupt_code_     VARCHAR2(20);
   op_qty_	   NUMBER;
   scrap_qty_	   NUMBER;
   reason_         scrapping_cause.reject_reason%TYPE;

   CURSOR get_order_info(op_id_ IN NUMBER) IS
     SELECT order_no, release_no, sequence_no, operation_no
     FROM shop_order_operation
     WHERE op_id = op_id_;

   order_rec_ 	  get_order_info%ROWTYPE;
   qty_to_report_ NUMBER;

BEGIN

   batch_ := '0';
   order_no_ := NULL;
   OpNo_ := NULL;
   contract_ := NULL;
   work_center_no_ := NULL;
   MchCode_ := NULL;
   InfoCode_ := NULL;
   irupt_code_ := NULL;
   Client_SYS.Clear_Attr(qty_attr_);

   company_id_ :=    Client_SYS.Get_Item_Value('COMPANY_ID', in_attr_);
   emp_no_ :=        Client_SYS.Get_Item_Value('EMP_NO', in_attr_);
   site_ :=        Client_SYS.Get_Item_Value('SITE', in_attr_);
   stoptype_ :=      Client_SYS.Get_Item_Value('STOP_TYPE', in_attr_);
   irupt_code_ :=      Client_SYS.Get_Item_Value('INTERRUPT', in_attr_);
   OpId_ :=          Client_SYS.Get_Item_Value('OP_ID', in_attr_);
   op_qty_ :=          Client_SYS.Get_Item_Value('OP_QTY', in_attr_);
   reason_ :=          Client_SYS.Get_Item_Value('REJECT_REASON', in_attr_);
   scrap_qty_ :=          Client_SYS.Get_Item_Value('SCRAP_QTY', in_attr_);

   --v_stamp_date_ :=  Client_SYS.Get_Item_Value('REG_STAMP', in_attr_);
   stoptype_ :=      Client_SYS.Get_Item_Value('STOP_TYPE', in_attr_);


   stop_type_ := STOP_TYPE_API.ENCODE(nls_initcap(stoptype_));

   Client_SYS.Add_To_Attr('REJECT_REASON', '', qty_attr_);
   Client_SYS.Add_To_Attr('OP_QTY', op_qty_, qty_attr_);

   if ( scrap_qty_ >  0 ) THEN
		 Client_SYS.Add_To_Attr('REJECT_REASON', reason_, qty_attr_);
		 Client_SYS.Add_To_Attr('OP_QTY', scrap_qty_, qty_attr_);
   END IF;

   Client_SYS.Add_To_Attr('TOTAL_APPROVED_QTY', op_qty_, qty_attr_);
   Client_SYS.Add_To_Attr('TOTAL_REJECTED_QTY', scrap_qty_, qty_attr_);

   stop_type_ := STOP_TYPE_API.ENCODE(nls_initcap(stoptype_));

   --reg_stamp_ := TO_DATE(v_stamp_date_, 'MM/DD/YYYY HH:MI:SS AM');
   reg_stamp_ := Site_API.Get_Site_Date(site_);

   OPEN get_order_info(OpId_);
   FETCH get_order_info INTO order_rec_;
   CLOSE get_order_info;

   qty_to_report_ := Shop_Order_Operation_API.Get_Remaining_Qty(order_rec_.order_no,
   								order_rec_.release_no,
   								order_rec_.sequence_no,
   								order_rec_.operation_no);

   qty_to_report_ := qty_to_report_ - (op_qty_ + scrap_qty_);

   IF (qty_to_report_ = 0) OR (qty_to_report_ < 0) THEN
     stop_type_ := STOP_TYPE_API.ENCODE(nls_initcap('Stop'));
   END IF;


   out_attr_ := CREATE_OP_STAMPS_API.Employee_Operation(stop_type_,
                                           company_id_,
                                           emp_no_,
                                           reg_stamp_,
                                           batch_,
                                           OpId_,
                                           order_no_,
                                           OpNo_,
                                           contract_,
                                           work_center_no_,
                                           MchCode_,
                                           InfoCode_,
                                           irupt_code_,
                                           qty_attr_);

END STOP_OP_QTY;


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

   IF  transaction_ = 'CLOCK_IN' THEN CLOCK_IN(attr_, attr_);

   ELSIF  transaction_ = 'CLOCK_OUT' THEN CLOCK_OUT(attr_, attr_);

   ELSIF  transaction_ = 'START_OP' THEN START_OP(attr_, attr_);

   ELSIF  transaction_ = 'STOP_OP' THEN STOP_OP(attr_, attr_);

   ELSIF  transaction_ = 'STOP_OP_QTY' THEN STOP_OP_QTY(attr_, attr_);

   ELSE RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');

   END IF;

   out_attr_ := attr_;

--EXCEPTION
--   WHEN OTHERS THEN
--      RAISE_APPLICATION_ERROR(SQLCODE,  SQLERRM);
END TRANSACT;

END ESI_SW_TIME_CLOCK_API;
/
