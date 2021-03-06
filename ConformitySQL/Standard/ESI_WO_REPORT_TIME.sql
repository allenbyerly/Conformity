CREATE OR REPLACE VIEW ESI_WO_REPORT_TIME AS
SELECT AWO.wo_no                          wo_no,
       AWO.err_descr                      err_descr,
       AWO.plan_s_date                    plan_s_date,
       AWO.work_done                      work_done,
       Pm_Type_API.Decode(AWO.pm_type)    pm_type,
       AWO.pm_type                        pm_type_db,
       AWO.reported_by_id                 reported_by_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), reported_by_id)
                                      reported_by,
       AWO.priority_id                    priority_id,
       AWO.err_class                      err_class,
       AWO.err_type                       err_type,
       AWO.err_discover_code              err_discover_code,
       AWO.err_symptom                    err_symptom,
       AWO.work_type_id                   work_type_id,
       AWO.call_code                      call_code,
       substr(Site_API.Get_Company(AWO.CONTRACT),1,20) awo_company,
       Pre_Accounting_Api.Get_Cost_Center(AWO.pre_accounting_id)    cost_center,
       Pre_Accounting_Api.Get_Object_No(AWO.pre_accounting_id)    object_no,
       AWO.action_code_id                 action_code_id,
       AWO.contract                       contract,
       AWO.mch_code                       mch_code,
       AWO.performed_action_id            performed_action_id,
       AWO.op_status_id                   op_status_id,
       AWO.err_cause                      err_cause,
       AWO.test_point_id                  test_point_id,
       AWO.func_test_org                  func_test_org,
       AWO.work_master_sign_id            work_master_sign_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), work_master_sign_id)
                                      work_master_sign,
       AWO.work_leader_sign_id            work_leader_sign_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), work_leader_sign_id)
                                      work_leader_sign,
       AWO.rounddef_id                    rounddef_id,
       AWO.prepared_by_id                 prepared_by_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), AWO.prepared_by_id)  prepared_by,
       authorize_code                 authorize_code,
       func_test_sign_id              func_test_sign_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), func_test_sign_id)
                                      func_test_sign,
       AWO.pm_no                          pm_no,
       AWO.pm_revision                    pm_revision,
       AWO.role_code                      role_code,
       AWO.project_no                     project_no,
       AWO.reg_date                       reg_date,
       AWO.err_cause_lo                   err_cause_lo,
       AWO.err_descr_lo                   err_descr_lo,
       AWO.plan_f_date                    plan_f_date,
       AWO.real_s_date                    real_s_date,
       AWO.real_f_date                    real_f_date,
       AWO.work_descr_lo                  work_descr_lo,
       AWO.bud_pers_cost                  bud_pers_cost,
       AWO.bud_mat_cost                   bud_mat_cost,
       AWO.bud_ext_cost                   bud_ext_cost,
       AWO.bud_tools_cost                 bud_tools_cost,
       AWO.sync_with_std_bud              sync_with_std_bud,
       AWO.performed_action_lo            performed_action_lo,
       AWO.func_test                      func_test,
       AWO.func_test_descr                func_test_descr,
       AWO.pm_descr                       pm_descr,
       AWO.plan_hrs                       plan_hrs,
       AWO.real_hrs                       real_hrs,
       Pre_Accounting_Api.Get_Codeno_C(AWO.pre_accounting_id)                         code_c,
       Pre_Accounting_Api.Get_Codeno_D(AWO.pre_accounting_id)                         code_d,
       Pre_Accounting_Api.Get_Codeno_G(AWO.pre_accounting_id)                         code_g,
       Pre_Accounting_Api.Get_Codeno_H(AWO.pre_accounting_id)                         code_h,
       Pre_Accounting_Api.Get_Codeno_I(AWO.pre_accounting_id)                         code_i,
       Pre_Accounting_Api.Get_Codeno_J(AWO.pre_accounting_id)                         code_j,
       AWO.activity_seq                   activity_seq,
       AWO.test_number                    test_number,
       AWO.instruction                    instruction,
       AWO.materials                      materials,
       AWO.plan_s_week                    plan_s_week,
       AWO.plan_f_week                    plan_f_week,
       AWO.pre_accounting_id              pre_accounting_id,
       AWO.note                           note,
       AWO.last_activity_date             last_activity_date,
       AWO.note_id                        note_id,
       AWO.required_start_date            required_start_date,
       AWO.required_end_date              required_end_date,
       AWO.report_in_by_id                report_in_by_id,
       Company_Emp_API.Get_Person_Id(Site_API.Get_Company(AWO.contract), AWO.report_in_by_id)
                                      report_in_by,
       nvl(AWO.repair_flag,'FALSE')       repair_flag,
       AWO.contact                        contact,
       AWO.phone_no                       phone_no,
       AWO.customer_no                    customer_no,
       Work_Order_Address_API.Get_Address1(AWO.WO_NO)  address1,
       Work_Order_Address_API.Get_Address2(AWO.WO_NO)  address2,
       Work_Order_Address_API.Get_Address3(AWO.WO_NO)  address3,
       Work_Order_Address_API.Get_Address4(AWO.WO_NO)  address4,
       Work_Order_Address_API.Get_Address5(AWO.WO_NO)  address5,
       Work_Order_Address_API.Get_Address6(AWO.WO_NO)  address6,
       Work_Order_Address_API.Get_Address7(AWO.WO_NO)  address7,
       NULL                           std_job_flag,
       RPAD(' ',50)                   address_id,
       AWO.agreement_id                   agreement_id,
       AWO.bud_exp_cost                   bud_exp_cost,
       AWO.bud_fixed_cost                 bud_fixed_cost,
       AWO.reference_no                   reference_no,
       Fixed_Price_API.Decode(AWO.fixed_price) fixed_price,
       AWO.fixed_price                    fixed_price_db,
       AWO.fault_rep_flag                 fault_rep_flag,
       AWO.quotation_id                   quotation_id,
       Equipment_Functional_API.Get_Criticality(AWO.mch_code_contract,AWO.mch_code)  criticality,
       Equipment_Object_API.Get_Group_Id(AWO.mch_code_contract,AWO.mch_code)         group_id,
       AWO.cust_order_type                cust_order_type,
       AWO.cust_order_no                  cust_order_no,
       AWO.cust_order_line_no             cust_order_line_no,
       AWO.cust_order_rel_no              cust_order_rel_no,
       AWO.cust_order_line_item_no        cust_order_line_item_no,
       Generate_Note_API.Decode(AWO.generate_note) generate_note,
       AWO.generate_note                  generate_note_db,
       AWO.seq_no                         seq_no,
       AWO.gen_id                         gen_id,
       AWO.warranty_row_no                warranty_row_no,
       AWO.currency_code                  currency_code,
       AWO.repair_part_no                 repair_part_no,
       AWO.repair_part_contract           repair_part_contract,
       nvl( AWO.non_serial_repair_flag, 'FALSE') non_serial_repair_flag,
       Non_Serial_Location_API.Decode(AWO.non_serial_location)  non_serial_location,
       AWO.non_serial_location            non_serial_location_db,
       AWO.obj_cust_warranty              obj_cust_warranty,
       AWO.obj_sup_warranty               obj_sup_warranty,
       AWO.cust_warranty                  cust_warranty,
       AWO.cust_warr_type                 cust_warr_type,
       AWO.sup_warranty                   sup_warranty,
       AWO.sup_warr_type                  sup_warr_type,
       AWO.ncf_inv_stat_fee               ncf_inv_stat_fee,
       AWO.planned_man_hrs                planned_man_hrs,
       AWO.mch_code_contract              mch_code_contract,
       decode(AWO.connection_type,'VIM',Active_Work_Order_Util_Api.Get_Vim_Obj_Description(AWO.wo_no),Maintenance_Object_Api.Get_Mch_Name(AWO.mch_code_contract, AWO.mch_code)) mch_code_description,
       Maint_Connection_Type_API.Decode(AWO.connection_type) connection_type,
       AWO.connection_type                connection_type_db,
       AWO.receive_order_no               receive_order_no,
       AWO.complex_agreement_id           complex_agreement_id,
       Equipment_Serial_API.Get_Part_No(AWO.mch_code_contract,AWO.mch_code) part_no,
       Equipment_Serial_API.Get_Serial_No(AWO.mch_code_contract,AWO.mch_code) serial_no,
       AWO.lot_batch_no                   lot_batch_no,
       Active_Separate_API.Is_Project_Connected(AWO.WO_NO) project_connected,
       AWO.case_id                        case_id,
       AWO.task_id                        task_id,
       AWO.context                        context,
       AWO.cust_add_id                    cust_add_id,
       Scheduling_Constraints_API.Decode(AWO.scheduling_constraints) scheduling_constraints,
       AWO.scheduling_constraints         scheduling_constraints_db,
       AWO.rowid                         objid,
       ltrim(lpad(to_char(AWO.rowversion),2000))                    objversion,
       AWO.wo_status_id                      objstate,
       Active_Work_Order_API.Finite_State_Events__(AWO.wo_status_id)                     objevents,
       Client_SYS.Get_Key_Reference('ActiveSeparate', 'WO_NO', AWO.WO_NO) wo_key_value,
       decode(AWO.activity_seq,'',0,1)    activity_connected,
       AWO.contract_id                    contract_id,
       AWO.line_no                        line_no,
       AWO.location_id                    location_id,
       NULL                           condition_code,
       text_id$                       text_id$,
       AWO.temp_mob_wo                    temp_mob_wo,
       AWO.source                         source,
       AWO.source_id                      source_id,
       Active_Work_Order_API.Finite_State_Decode__(AWO.wo_status_id)                         state,
       ee.company                        	company,      
       ee.person_id                      	person_id,    
       ee.employee_id                    	employee_id,  
       ee.name                            	name,         
       ee.vendor_no                     vendor_no,    
       ee.org_code                      org_code,     
       ee.DELIVERY_ADDRESS                 DELIVERY_ADDRESS, 
       ee.CONTRACT_REF                     CONTRACT_REF,     
       ee.DIST_CALENDAR_ID                 DIST_CALENDAR_ID, 
       ee.MANUF_CALENDAR_ID                MANUF_CALENDAR_ID,
       ee.OFFSET                           OFFSET           
FROM   active_work_order_tab awo, ESI_EMPLOYEE ee
WHERE  pm_type = 'ActiveSeparate'
AND    connection_type != 'CRO'
AND    awo.contract = ee.contract (+)
WITH   read only;