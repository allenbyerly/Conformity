CREATE OR REPLACE VIEW ESI_OP_RUNNING_JOB AS
SELECT CP.company_id                company_id,
       CP.emp_no                    emp_no,
       CP.fname                     fname,
       CP.lname                     lname,
       OP.contract                  contract,
       OP.op_id                     op_id,
       OP.order_no                  order_no,
       OP.op_no                     op_no,
       OP.optional1                 optional1,
       OP.optional2                 optional2,
       OP.optional3                 optional3,
       OP.sup_op_id                 sup_op_id,
       OP.plan_mch_code             plan_mch_code,
       OP.part_no                   part_no,
       OP.op_status                 op_status,
       OP.op_type                   op_type,
       OP.mch_code                  mch_code,
       OP.work_center_no            work_center_no
FROM COMPANY_PERS CP,
     OP_RUNNING_JOB OP
WHERE  CP.emp_no = OP.emp_no
AND CP.company_id = OP.company_id
AND OP.OP_STATUS = 'In process'
AND OP.CONTRACT IS NOT NULL
WITH   read only

