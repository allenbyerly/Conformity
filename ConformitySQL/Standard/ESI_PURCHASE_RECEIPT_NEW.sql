CREATE OR REPLACE VIEW ESI_PURCHASE_RECEIPT_NEW AS
SELECT PR.order_no                                                          order_no,
       PR.line_no                                                           line_no,
       PR.release_no                                                        release_no,
       PR.receipt_no                                                        receipt_no,
       PR.contract                                                          contract,
       PR.description                                                       description,
       PR.vendor_no                                                         vendor_no,
       PR.receipt_reference                                                 receipt_reference,
       PR.note_text                                                         note_text,
       PR.qty_arrived                                                       qty_arrived,
       PR.qty_inspected                                                     qty_inspected,
       PR.qty_to_inspect                                                    qty_to_inspect,
       PR.arrival_date                                                      arrival_date,
       PR.receiver                                                          receiver,
       PR.qty_invoiced                                                      qty_invoiced,
       PR.qc_code                                                           qc_code,
       PR.no_of_inspections                                                 no_of_inspections,
       PR.receive_case                                                      receive_case,
       PR.receive_case_db                                                   receive_case_db,
       PR.qty_consignment                                                   qty_consignment,
       PR.automatic_invoice                                                 automatic_invoice,
       PR.automatic_invoice_db                                              automatic_invoice_db,
       PR.note_id                                                           note_id,
       PR.printed_arrival_flag                                              printed_arrival_flag,
       PR.printed_arrival_flag_db                                           printed_arrival_flag_db,
       PR.printed_return_flag                                               printed_return_flag,
       PR.printed_return_flag_db                                            printed_return_flag_db,
       PR.buy_unit_meas                                                     buy_unit_meas,
       PR.unit_meas                                                         unit_meas,
       PR.conv_factor                                                       conv_factor,
       PR.requisition_no                                                    requisition_no,
       PR.req_line                                                          req_line,
       PR.req_release                                                       req_release,
       PR.demand_code                                                       demand_code,
       PR.demand_operation_no                                               demand_operation_no,
       PR.demand_order_code                                                 demand_order_code,
       PR.demand_order_no                                                   demand_order_no,
       PR.demand_order_type                                                 demand_order_type,
       PR.demand_release                                                    demand_release,
       PR.demand_sequence_no                                                demand_sequence_no,
       PR.manufacturer_id                                                   manufacturer_id,
       PR.part_ownership                                                    part_ownership,
       PR.part_ownership_db                                                 part_ownership_db,
       PR.owning_customer_no                                                owning_customer_no,
       PR.objid                                                             objid,
       PR.objversion                                                        objversion,
       PR.objstate                                                          objstate,
       PR.objevents                                                         objevents,
       PR.state                                                             state,
       PR.part_no                                                           part_no,
       LOC.configuration_id                                                 configuration_id,
       LOC.location_no                                                      location_no,
       LOC.lot_batch_no                                                     lot_batch_no,
       LOC.serial_no                                                        serial_no,
       LOC.eng_chg_level                                                    eng_chg_level,
       LOC.waiv_dev_rej_no                                                  waiv_dev_rej_no,
       LOC.qty_in_store                                                     qty_in_store,
       LOC.objid                                                            loc_objid,
       LOC.objversion                                                       loc_objversion
FROM   PURCHASE_RECEIPT_NEW PR,
       RECEIPT_INVENTORY_LOCATION LOC
WHERE  PR.ORDER_NO = LOC.ORDER_NO (+)
AND    PR.LINE_NO = LOC.LINE_NO (+)
AND    PR.RELEASE_NO = LOC.RELEASE_NO (+)
AND    PR.RECEIPT_NO = LOC.RECEIPT_NO (+);