CREATE OR REPLACE PACKAGE ESI_SW_WORK_ORDER_API IS
  -----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Demo Package
  -- Author:              Vinojee Dittakavi
  -- Version:             7.3.0.0
  -- Date:                07/18/2011
  -----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS WO API's
  -- Additionally this implements custom ESI delivery functionality
  -----------------------------------------------------------------------------------------

  FUNCTION PACKAGE RETURN VARCHAR2;
  FUNCTION VERSION RETURN VARCHAR2;

  PROCEDURE TRANSACT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

END ESI_SW_WORK_ORDER_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_WORK_ORDER_API IS
  -----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Demo Package
  -- Author:              Vinojee Dittakavi
  -- Version:             7.3.0.0
  -- Date:                07/18/2011
  -----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides general functionality
  -- to IFS WO API's
  -- Additionally this implements custom ESI delivery functionality
  -----------------------------------------------------------------------------------------
  FUNCTION VERSION RETURN VARCHAR2 IS
  BEGIN
    RETURN '7.3.0.0';
  END;

  FUNCTION PACKAGE RETURN VARCHAR2 IS
  BEGIN
    RETURN 'DEMO';
  END;

  PROCEDURE MANUAL_ISSUE(out_attr_ OUT VARCHAR2, in_attr_ IN VARCHAR2) IS
  
    userid_ inventory_transaction_hist.userid%TYPE;
  
    contract_        maint_material_requisition.contract%TYPE;
    part_no_         maint_material_req_line.part_no%TYPE;
    location_no_     inventory_part_in_stock.location_no%TYPE;
    lot_batch_no_    inventory_part_in_stock.lot_batch_no%TYPE;
    serial_no_       inventory_part_in_stock.serial_no%TYPE;
    eng_chg_level_   inventory_part_in_stock.eng_chg_level%TYPE;
    waiv_dev_rej_no_ inventory_part_in_stock.waiv_dev_rej_no%TYPE;
    config_id_       inventory_part_in_stock.configuration_id%TYPE;
    quantity_        maint_material_req_line.qty%TYPE;
    activity_seq_    inventory_part_in_stock.activity_seq%TYPE;
    project_id_      activity_tab.project_id%TYPE;
    line_item_no_    maint_material_req_line.line_item_no%TYPE;
    order_no_        maint_material_requisition.maint_material_order_no%TYPE;
    wo_no_           maint_material_requisition.wo_no%TYPE;
    qty_issued_      maint_material_req_line.qty%TYPE;
    plan_line_no_    maint_material_req_line.plan_line_no%TYPE;
  
    qty_assigned_ work_order_part_alloc_tab.qty_assigned%TYPE;
  
  BEGIN
  
    order_no_        := CLIENT_SYS.Get_Item_Value('ORDER_NO', in_attr_);
    line_item_no_    := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', in_attr_);
    location_no_     := CLIENT_SYS.Get_Item_Value('LOCATION_NO', in_attr_);
    lot_batch_no_    := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', in_attr_);
    serial_no_       := CLIENT_SYS.Get_Item_Value('SERIAL_NO', in_attr_);
    eng_chg_level_   := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', in_attr_);
    waiv_dev_rej_no_ := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO',
                                                  in_attr_);
    project_id_      := CLIENT_SYS.Get_Item_Value('PROJECT_NO', in_attr_);
    activity_seq_    := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', in_attr_);
    quantity_        := CLIENT_SYS.Get_Item_Value('QUANTITY', in_attr_);
    plan_line_no_    := CLIENT_SYS.Get_Item_Value('PLAN_LINE_NO', in_attr_);
    qty_assigned_    := CLIENT_SYS.Get_Item_Value('QTY_ASSIGNED', in_attr_);
    config_id_       := CLIENT_SYS.Get_Item_Value('CONFIGURATION_ID',
                                                  in_attr_);
  
    MAINT_MATERIAL_REQ_LINE_API.Make_Manual_Issue_Detail(qty_issued_,
                                                         order_no_,
                                                         line_item_no_,
                                                         location_no_,
                                                         lot_batch_no_,
                                                         serial_no_,
                                                         eng_chg_level_,
                                                         waiv_dev_rej_no_,
                                                         project_id_,
                                                         activity_seq_,
                                                         quantity_,
                                                         plan_line_no_,
                                                         qty_assigned_,
                                                         config_id_);
  
    out_attr_ := in_attr_;
  
    CLIENT_SYS.Add_To_Attr('QTY_ISSUED', qty_issued_, out_attr_);
  
    CLIENT_SYS.Set_Item_Value('ORDER_NO', order_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('LINE_ITEM_NO', line_item_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('LOCATION_NO', location_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('LOT_BATCH_NO', lot_batch_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('SERIAL_NO', serial_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('ENG_CHG_LEVEL', eng_chg_level_, out_attr_);
    CLIENT_SYS.Set_Item_Value('WAIV_DEV_REJ_NO',
                              waiv_dev_rej_no_,
                              out_attr_);
    CLIENT_SYS.Set_Item_Value('PROJECT_NO', project_id_, out_attr_);
    CLIENT_SYS.Set_Item_Value('ACTIVITY_SEQ', activity_seq_, out_attr_);
    CLIENT_SYS.Set_Item_Value('QUANTITY', quantity_, out_attr_);
    CLIENT_SYS.Set_Item_Value('PLAN_LINE__NO', plan_line_no_, out_attr_);
    CLIENT_SYS.Set_Item_Value('QTY_ASSIGNED', qty_assigned_, out_attr_);
    CLIENT_SYS.Set_Item_Value('CONFIGURATION_ID', config_id_, out_attr_);
  
  END MANUAL_ISSUE;

  PROCEDURE NEW_WORK_ORDER_CODING(out_attr_ OUT VARCHAR2,
                                  in_attr_  IN VARCHAR2) IS
  
    info_       VARCHAR2(2000);
    attr_       VARCHAR2(2000);
    action_     VARCHAR2(20);
    objid_      work_order_coding.objid%TYPE;
    objversion_ work_order_coding.objversion%TYPE;
  
    contract_            work_order_coding.contract%TYPE;
    wo_no_               work_order_coding.wo_no%TYPE;
    org_code_            work_order_coding.org_code%TYPE;
    emp_no_              work_order_coding.emp_no%TYPE;
    emp_signature_       work_order_coding.emp_signature%TYPE;
    company_             work_order_coding.company%TYPE;
    catalog_no_          work_order_coding.catalog_no%TYPE;
    mch_code_contract_   work_order_coding.mch_code_contract%TYPE;
    customer_            work_order_coding.customer_no%TYPE;
    agreement_           active_separate.agreement_id%TYPE;
    agreemnt_price_flag_ VARCHAR2(1);
    hours_               work_order_coding.qty%TYPE;
    price_list_          work_order_coding.price_list_no%TYPE;
    role_code_           EMPLOYEE_ROLE_TAB.role_code%TYPE;
    amount_              work_order_coding.amount%TYPE;
    comment_             work_order_coding.cmnt%TYPE;
    cost_type_           VARCHAR(20);
    account_type_        VARCHAR(20);
    reported_            VARCHAR2(1);
  
    base_price_      NUMBER;
    sale_price_      NUMBER;
    sale_unit_price_ NUMBER;
    discount_        NUMBER;
    currency_rate_   NUMBER;
    price_source_    VARCHAR2(25);
    price_source_db_ VARCHAR2(25);
    price_list_db_   VARCHAR2(25);
    price_source_id_ VARCHAR2(10);
    total_amount_    NUMBER;
  
  BEGIN
    action_              := CLIENT_SYS.Get_Item_Value('ACTION', in_attr_);
    wo_no_               := CLIENT_SYS.Get_Item_Value('WO_NO', in_attr_);
    emp_no_              := CLIENT_SYS.Get_Item_Value('EMP_NO', in_attr_);
    emp_signature_       := CLIENT_SYS.Get_Item_Value('EMP_SIGNATURE',
                                                      in_attr_);
    org_code_            := CLIENT_SYS.Get_Item_Value('ORG_CODE', in_attr_);
    contract_            := CLIENT_SYS.Get_Item_Value('CONTRACT', in_attr_);
    mch_code_contract_   := CLIENT_SYS.Get_Item_Value('MCH_CODE_CONTRACT',
                                                      in_attr_);
    company_             := CLIENT_SYS.Get_Item_Value('COMPANY', in_attr_);
    role_code_           := CLIENT_SYS.Get_Item_Value('ROLE_CODE', in_attr_);
    catalog_no_          := CLIENT_SYS.Get_Item_Value('CATALOG_NO',
                                                      in_attr_);
    price_list_          := CLIENT_SYS.Get_Item_Value('PRICE_LIST_NO',
                                                      in_attr_);
    hours_               := CLIENT_SYS.Get_Item_Value('QTY', in_attr_);
    total_amount_        := CLIENT_SYS.Get_Item_Value('AMOUNT', in_attr_);
    sale_price_          := CLIENT_SYS.Get_Item_Value('LIST_PRICE',
                                                      in_attr_);
    discount_            := CLIENT_SYS.Get_Item_Value('DISCOUNT', in_attr_);
    comment_             := CLIENT_SYS.Get_Item_Value('CMNT', in_attr_);
    cost_type_           := CLIENT_SYS.Get_Item_Value('WORK_ORDER_COST_TYPE',
                                                      in_attr_);
    account_type_        := CLIENT_SYS.Get_Item_Value('WORK_ORDER_ACCOUNT_TYPE',
                                                      in_attr_);
    agreemnt_price_flag_ := CLIENT_SYS.Get_Item_Value('AGREEMENT_PRICE_FLAG',
                                                      in_attr_);
    sale_unit_price_     := CLIENT_SYS.Get_Item_Value('SALE_UNIT_PRICE',
                                                      in_attr_);
  
    CLIENT_SYS.Clear_Attr(attr_);
    Client_Sys.Add_To_Attr('EMP_NO', emp_no_, attr_);
    Client_Sys.Add_To_Attr('EMP_SIGNATURE', emp_signature_, attr_);
    Client_Sys.Add_To_Attr('WO_NO', wo_no_, attr_);
    Client_Sys.Add_To_Attr('ORG_CODE', org_code_, attr_);
    Client_Sys.Add_To_Attr('CONTRACT', contract_, attr_);
    Client_Sys.Add_To_Attr('MCH_CODE_CONTRACT', mch_code_contract_, attr_);
    Client_Sys.Add_To_Attr('COMPANY', company_, attr_);
    Client_Sys.Add_To_Attr('ROLE_CODE', role_code_, attr_);
    Client_Sys.Add_To_Attr('CATALOG_NO', catalog_no_, attr_);
    Client_Sys.Add_To_Attr('PRICE_LIST_NO', price_list_, attr_);
    Client_Sys.Add_To_Attr('QTY', hours_, attr_);
    Client_Sys.Add_To_Attr('AMOUNT', total_amount_, attr_);
    Client_Sys.Add_To_Attr('LIST_PRICE', sale_price_, attr_);
    Client_Sys.Add_To_Attr('DISCOUNT', discount_, attr_);
    Client_Sys.Add_To_Attr('CMNT', comment_, attr_);
    Client_Sys.Add_To_Attr('WORK_ORDER_COST_TYPE', cost_type_, attr_);
    Client_Sys.Add_To_Attr('WORK_ORDER_ACCOUNT_TYPE', account_type_, attr_);
    Client_Sys.Add_To_Attr('AGREEMENT_PRICE_FLAG',
                           agreemnt_price_flag_,
                           attr_);
    Client_Sys.Add_To_Attr('SALE_UNIT_PRICE', sale_unit_price_, attr_);
  
    WORK_ORDER_CODING_API.NEW__(info_, objid_, objversion_, attr_, action_);
  
    out_attr_ := in_attr_;
  
    Client_Sys.Add_To_Attr('OBJID', objid_, out_attr_);
    Client_Sys.Add_To_Attr('OBJVERSION', objversion_, out_attr_);
  
    Client_Sys.Set_Item_Value('EMP_NO', emp_no_, out_attr_);
    Client_Sys.Set_Item_Value('EMP_SIGNATURE', emp_signature_, out_attr_);
    Client_Sys.Set_Item_Value('WO_NO', wo_no_, out_attr_);
    Client_Sys.Set_Item_Value('ORG_CODE', org_code_, out_attr_);
    Client_Sys.Set_Item_Value('CONTRACT', contract_, out_attr_);
    Client_Sys.Set_Item_Value('MCH_CODE_CONTRACT',
                              mch_code_contract_,
                              out_attr_);
    Client_Sys.Set_Item_Value('COMPANY', company_, out_attr_);
    Client_Sys.Set_Item_Value('ROLE_CODE', role_code_, out_attr_);
    Client_Sys.Set_Item_Value('CATALOG_NO', catalog_no_, out_attr_);
    Client_Sys.Set_Item_Value('PRICE_LIST_NO', price_list_, out_attr_);
    Client_Sys.Set_Item_Value('QTY', hours_, out_attr_);
    Client_Sys.Set_Item_Value('AMOUNT', total_amount_, out_attr_);
    Client_Sys.Set_Item_Value('LIST_PRICE', sale_price_, out_attr_);
    Client_Sys.Set_Item_Value('DISCOUNT', discount_, out_attr_);
    Client_Sys.Set_Item_Value('CMNT', comment_, out_attr_);
    Client_Sys.Set_Item_Value('WORK_ORDER_COST_TYPE',
                              cost_type_,
                              out_attr_);
    Client_Sys.Set_Item_Value('WORK_ORDER_ACCOUNT_TYPE',
                              account_type_,
                              out_attr_);
    Client_Sys.Set_Item_Value('AGREEMENT_PRICE_FLAG',
                              agreemnt_price_flag_,
                              out_attr_);
    Client_Sys.Set_Item_Value('SALE_UNIT_PRICE',
                              sale_unit_price_,
                              out_attr_);
  
    CLIENT_SYS.Add_Info('INFO', info_, out_attr_);
  
  END NEW_WORK_ORDER_CODING;

  PROCEDURE REPORT(out_attr_ OUT VARCHAR2, in_attr_ IN VARCHAR2) IS
    as_objid_      active_separate.objid%TYPE;
    as_objversion_ active_separate.objversion%TYPE;
    info_          VARCHAR2(2000);
    attr_          VARCHAR2(2000);
    action_        VARCHAR2(20);
  BEGIN
    attr_ := in_attr_;
  
    as_objid_      := CLIENT_SYS.Get_Item_Value('OBJID', in_attr_);
    as_objversion_ := CLIENT_SYS.Get_Item_Value('OBJVERSION', in_attr_);
    action_        := CLIENT_SYS.Get_Item_Value('ACTION', in_attr_);
    ACTIVE_SEPARATE_API.Report__(info_,
                                 as_objid_,
                                 as_objversion_,
                                 attr_,
                                 action_);
  
    out_attr_ := in_attr_;
  
    Client_Sys.Set_Item_Value('OBJVERSION', as_objversion_, out_attr_);
    CLIENT_SYS.Add_Info('INFO', info_, out_attr_);
  END REPORT;

  PROCEDURE MODIFY(out_attr_ OUT VARCHAR2, in_attr_ IN VARCHAR2) IS
    as_objid_      active_separate.objid%TYPE;
    as_objversion_ active_separate.objversion%TYPE;
    info_          VARCHAR2(2000);
    attr_          VARCHAR2(2000);
    action_        VARCHAR2(20);
    wo_no_         active_separate.wo_no%TYPE;
  BEGIN
    attr_ := in_attr_;
    
    wo_no_      := CLIENT_SYS.Get_Item_Value('WO_NO', attr_);
    
    ACTIVE_SEPARATE_API.Get_Id_Ver_By_Keys__(as_objid_,
                                             as_objversion_,
                                             wo_no_);
                                  
    Client_SYS.Clear_Attr(attr_);               
    Client_Sys.Add_To_Attr('REAL_F_DATE',
                           TO_CHAR(sysdate, 'YYYY-MM-DD-HH24.MI.SS'),
                           attr_);                                             
  
    action_        := 'DO';
    ACTIVE_SEPARATE_API.MODIFY__(info_,
                                 as_objid_,
                                 as_objversion_,
                                 attr_,
                                 action_);

    CLIENT_SYS.Add_Info('INFO', info_, out_attr_);
  END MODIFY;

  PROCEDURE WO_MAT_ISSUE(out_attr_ OUT VARCHAR2, in_attr_ IN VARCHAR2) IS
  
    userid_ inventory_transaction_hist.userid%TYPE;
  
    contract_        maint_material_requisition.contract%TYPE;
    part_no_         maint_material_req_line.part_no%TYPE;
    location_no_     inventory_part_in_stock.location_no%TYPE;
    lot_batch_no_    inventory_part_in_stock.lot_batch_no%TYPE;
    serial_no_       inventory_part_in_stock.serial_no%TYPE;
    eng_chg_level_   inventory_part_in_stock.eng_chg_level%TYPE;
    waiv_dev_rej_no_ inventory_part_in_stock.waiv_dev_rej_no%TYPE;
    config_id_       inventory_part_in_stock.configuration_id%TYPE;
    quantity_        maint_material_req_line.qty%TYPE;
    activity_seq_    inventory_part_in_stock.activity_seq%TYPE;
    project_id_      activity_tab.project_id%TYPE;
    line_item_no_    maint_material_req_line.line_item_no%TYPE;
    order_no_        maint_material_requisition.maint_material_order_no%TYPE;
    wo_no_           maint_material_requisition.wo_no%TYPE;
    qty_issued_      maint_material_req_line.qty%TYPE;
    plan_line_no_    maint_material_req_line.plan_line_no%TYPE;
  
    ptr_   NUMBER;
    name_  VARCHAR2(30);
    value_ VARCHAR2(2000);
    attr_  VARCHAR2(2000);
  
    qty_assigned_ work_order_part_alloc_tab.qty_assigned%TYPE;
  
  BEGIN
  
    attr_ := in_attr_;
  
    wo_no_           := CLIENT_SYS.Get_Item_Value('WO_NO', attr_);
    order_no_        := CLIENT_SYS.Get_Item_Value('ORDER_NO', attr_);
    project_id_      := CLIENT_SYS.Get_Item_Value('PROJECT_NO', attr_);
    contract_        := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
    part_no_         := CLIENT_SYS.Get_Item_Value('PART_NO', attr_);
    line_item_no_    := CLIENT_SYS.Get_Item_Value('LINE_ITEM_NO', attr_);
    location_no_     := CLIENT_SYS.Get_Item_Value('LOCATION_NO', attr_);
    quantity_        := CLIENT_SYS.Get_Item_Value('QUANTITY', attr_);
    lot_batch_no_    := CLIENT_SYS.Get_Item_Value('LOT_BATCH_NO', attr_);
    activity_seq_    := CLIENT_SYS.Get_Item_Value('ACTIVITY_SEQ', attr_);
    serial_no_       := CLIENT_SYS.Get_Item_Value('SERIAL_NO', attr_);
    eng_chg_level_   := CLIENT_SYS.Get_Item_Value('ENG_CHG_LEVEL', attr_);
    waiv_dev_rej_no_ := CLIENT_SYS.Get_Item_Value('WAIV_DEV_REJ_NO', attr_);
    config_id_       := CLIENT_SYS.Get_Item_Value('CONFIGURATION_ID', attr_);
    plan_line_no_    := CLIENT_SYS.Get_Item_Value('PLAN_LINE_NO', attr_);
    userid_          := CLIENT_SYS.Get_Item_Value('USERID', attr_);
  
    --fnd_session_api.set_property('FND_USER', userid_);
    --FND_SESSION_UTIL_API.Set_Fnd_User_(userid_);
  
    qty_assigned_ := Work_Order_Part_Alloc_API.Get_Assigned_In_Loc(wo_no_,
                                                                   line_item_no_,
                                                                   location_no_,
                                                                   serial_no_,
                                                                   lot_batch_no_,
                                                                   waiv_dev_rej_no_);
  
    CLIENT_SYS.Add_To_Attr('QTY_ASSIGNED', qty_assigned_, attr_);
  
    Manual_Issue(attr_, attr_);
  
    out_attr_ := attr_;
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(SQLCODE,
                              'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
    
  END WO_MAT_ISSUE;

  PROCEDURE WO_REPORT_TIME(out_attr_ OUT VARCHAR2, in_attr_ IN VARCHAR2) IS
  
    userid_ inventory_transaction_hist.userid%TYPE;
  
    contract_          work_order_coding.contract%TYPE;
    wo_no_             work_order_coding.wo_no%TYPE;
    org_code_          work_order_coding.org_code%TYPE;
    emp_no_            work_order_coding.emp_no%TYPE;
    emp_signature_     work_order_coding.emp_signature%TYPE;
    company_           work_order_coding.company%TYPE;
    catalog_no_        work_order_coding.catalog_no%TYPE;
    mch_code_contract_ work_order_coding.mch_code_contract%TYPE;
    customer_          work_order_coding.customer_no%TYPE;
    agreement_         active_separate.agreement_id%TYPE;
    hours_             work_order_coding.qty%TYPE;
    price_list_        work_order_coding.price_list_no%TYPE;
    role_code_         EMPLOYEE_ROLE_TAB.role_code%TYPE;
    amount_            work_order_coding.amount%TYPE;
    comment_           work_order_coding.cmnt%TYPE;
    cost_type_         VARCHAR(20);
    account_type_      VARCHAR(20);
    reported_          VARCHAR2(1);
  
    base_price_      NUMBER;
    sale_price_      NUMBER;
    sale_unit_price_ NUMBER;
    discount_        NUMBER;
    currency_rate_   NUMBER;
    price_source_    VARCHAR2(25);
    price_source_db_ VARCHAR2(25);
    price_list_db_   VARCHAR2(25);
    price_source_id_ VARCHAR2(10);
    total_amount_    NUMBER;
  
    ptr_   NUMBER;
    name_  VARCHAR2(30);
    value_ VARCHAR2(2000);
  
    info_          VARCHAR2(2000);
    attr_          VARCHAR2(2000);
    temp_attr_     VARCHAR2(2000);
    objid_         work_order_coding.objid%TYPE;
    objversion_    work_order_coding.objversion%TYPE;
    as_objid_      active_separate.objid%TYPE;
    as_objversion_ active_separate.objversion%TYPE;
  
  BEGIN
  
    attr_ := in_attr_;
  
    wo_no_             := CLIENT_SYS.Get_Item_Value('WO_NO',             attr_);
    contract_          := CLIENT_SYS.Get_Item_Value('CONTRACT',          attr_);
    company_           := CLIENT_SYS.Get_Item_Value('COMPANY',           attr_);
    emp_no_            := CLIENT_SYS.Get_Item_Value('EMPLOYEE_ID',       attr_);
    emp_signature_     := CLIENT_SYS.Get_Item_Value('EMP_SIG',           attr_);
    org_code_          := CLIENT_SYS.Get_Item_Value('ORG_CODE',          attr_);
    mch_code_contract_ := CLIENT_SYS.Get_Item_Value('MCH_CODE_CONTRACT', attr_);
    customer_          := CLIENT_SYS.Get_Item_Value('CUSTOMER',          attr_);
    agreement_         := CLIENT_SYS.Get_Item_Value('AGREEMENT',         attr_);
    hours_             := CLIENT_SYS.Get_Item_Value('QUANTITY',          attr_);
    reported_          := CLIENT_SYS.Get_Item_Value('REPORTED',          attr_);
    userid_            := CLIENT_SYS.Get_Item_Value('USERID',            attr_);
  
    --fnd_session_api.set_property('FND_USER', userid_);
  
    role_code_  := employee_role_api.get_default_role(company_, emp_no_);
    comment_    := Person_Info_API.Get_Name(ifsapp.Company_Emp_API.Get_Person_Id(company_,
                                                                                 emp_no_)) || ', ';
    comment_    := comment_ || org_code_ || ' (' ||
                   Role_API.Get_Description(role_code_) || ')';
    catalog_no_ := Role_Sales_Part_API.Get_Def_Catalog_No(role_code_,
                                                          contract_);
  
    amount_       := WORK_ORDER_PLANNING_UTIL_API.GET_COST(org_code_,
                                                           role_code_,
                                                           contract_,
                                                           catalog_no_);
    total_amount_ := hours_ * amount_;
  
    cost_type_    := Work_Order_Cost_Type_API.Get_Client_Value(0);
    account_type_ := Work_Order_Account_Type_API.Get_Client_Value(0);
  
    -- VPD (07-04-11): Commented the following lines. 'PREPARE' action is not catered for in the new
    -- NEW_WORK_ORDER_CODING procedure.
  
    --    Client_Sys.Clear_Attr(attr_);
    --    Client_Sys.Add_To_Attr('WO_NO', wo_no_, attr_);
  
    --    temp_attr_ := attr_;
  
    --    WORK_ORDER_CODING_API.NEW__(info_, objid_, objversion_, temp_attr_, 'PREPARE' );
  
    Work_Order_Coding_API.Get_Price_Info(price_source_db_,
                                         base_price_,
                                         sale_price_,
                                         discount_,
                                         currency_rate_,
                                         price_source_,
                                         price_source_id_,
                                         contract_,
                                         catalog_no_,
                                         customer_,
                                         agreement_,
                                         price_list_,
                                         1,
                                         wo_no_,
                                         NULL);
  
    Client_SYS.Clear_Attr(attr_);
    Client_Sys.Add_To_Attr('EMP_NO', emp_no_, attr_);
    Client_Sys.Add_To_Attr('EMP_SIGNATURE', emp_signature_, attr_);
    Client_Sys.Add_To_Attr('WO_NO', wo_no_, attr_);
    Client_Sys.Add_To_Attr('ORG_CODE', org_code_, attr_);
    Client_Sys.Add_To_Attr('CONTRACT', contract_, attr_);
    Client_Sys.Add_To_Attr('MCH_CODE_CONTRACT', mch_code_contract_, attr_);
    Client_Sys.Add_To_Attr('COMPANY', company_, attr_);
    Client_Sys.Add_To_Attr('ROLE_CODE', role_code_, attr_);
    Client_Sys.Add_To_Attr('CATALOG_NO', catalog_no_, attr_);
    Client_Sys.Add_To_Attr('PRICE_LIST_NO', price_list_, attr_);
    Client_Sys.Add_To_Attr('QTY', hours_, attr_);
    Client_Sys.Add_To_Attr('AMOUNT', total_amount_, attr_);
    Client_Sys.Add_To_Attr('LIST_PRICE', sale_price_, attr_);
    Client_Sys.Add_To_Attr('DISCOUNT', discount_, attr_);
    Client_Sys.Add_To_Attr('CMNT', comment_, attr_);
    Client_Sys.Add_To_Attr('WORK_ORDER_COST_TYPE', cost_type_, attr_);
    Client_Sys.Add_To_Attr('WORK_ORDER_ACCOUNT_TYPE', account_type_, attr_);
  
    IF (agreement_ IS NULL) THEN
      Client_Sys.Add_To_Attr('AGREEMENT_PRICE_FLAG', '0', attr_);
    ELSE
      Client_Sys.Add_To_Attr('AGREEMENT_PRICE_FLAG', '1', attr_);
    END IF;
  
    IF (price_list_db_ = 'AGREEMENT' OR price_list_db_ = 'PRICELIST') THEN
      sale_unit_price_ := sale_price_;
    ELSE
      sale_unit_price_ := '';
    END IF;
    Client_Sys.Add_To_Attr('SALE_UNIT_PRICE', sale_unit_price_, attr_);
  
    --temp_attr_ := attr_;
  
    Client_Sys.Add_To_Attr('ACTION', 'DO', attr_);
  
    --   WORK_ORDER_CODING_API.NEW__(info_, objid_, objversion_, temp_attr_, 'DO' );
    NEW_WORK_ORDER_CODING(attr_, attr_);
  
    IF (reported_ = 'Y') THEN
    
      ACTIVE_SEPARATE_API.Get_Id_Ver_By_Keys__(as_objid_,
                                               as_objversion_,
                                               wo_no_);
      Client_Sys.Clear_Attr(attr_);
      Client_Sys.Add_To_Attr('OBJID', as_objid_, attr_);
      Client_Sys.Add_To_Attr('OBJVERSION', as_objversion_, attr_);
      Client_Sys.Add_To_Attr('ACTION', 'DO', attr_);
    
      --ACTIVE_SEPARATE_API.Report__(info_, as_objid_, as_objversion_, temp_attr_, 'DO');
      REPORT(attr_, attr_);
    END IF;
  
    Client_SYS.Clear_Attr(attr_);
  
    Client_Sys.Add_To_Attr('WO_NO', wo_no_, attr_);

  
 
    -- VPD (07-04-11): Commented the following lines. 'CHECK' action is not catered for in the new
    -- MODIFY procedure.                                            
  
    --  temp_attr_ := attr_;
    --  ACTIVE_SEPARATE_API.MODIFY__(info_, as_objid_, as_objversion_, temp_attr_, 'CHECK');
  
    --temp_attr_ := attr_;
    MODIFY(attr_, attr_);
    --ACTIVE_SEPARATE_API.MODIFY__(info_, as_objid_, as_objversion_, temp_attr_, 'DO');
  
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(SQLCODE,
                              'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
    
  END WO_REPORT_TIME;

  PROCEDURE TRANSACT(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2) IS
  
    transaction_ VARCHAR2(200);
    fnd_user_    FND_USER_PROPERTY.identity%TYPE;
    attr_        VARCHAR2(20000);
  
  BEGIN
  
    attr_ := in_attr_;
  
    fnd_user_    := CLIENT_SYS.Get_Item_Value('FND_USER', attr_);
    transaction_ := CLIENT_SYS.Get_Item_Value('TRANSACTION', attr_);
  
    FND_SESSION_UTIL_API.Set_Fnd_User_(fnd_user_);
      
    IF transaction_ = 'WO_MAT_ISSUE' THEN
      WO_MAT_ISSUE(attr_, attr_);
    
    ELSIF transaction_ = 'WO_REPORT_TIME' THEN
      WO_REPORT_TIME(attr_, attr_);
    
    ELSE
      RAISE_APPLICATION_ERROR(-20002, 'Transaction Mismatch');
    
    END IF;
  
    out_attr_ := attr_;
  
  END TRANSACT;

END ESI_SW_WORK_ORDER_API;
/
