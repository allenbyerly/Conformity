CREATE OR REPLACE VIEW ESI_SHOP_MATERIAL_PICK_LINE AS
SELECT MAT.order_no                       order_no,
       MAT.release_no                     release_no,
       MAT.sequence_no                    sequence_no,
       MAT.line_item_no                   line_item_no,
       MAT.contract                       contract,
       MAT.part_no                        part_no,
       MAT.location_no                    location_no,
       MAT.lot_batch_no                   lot_batch_no,
       MAT.serial_no                      serial_no,
       MAT.eng_chg_level                  eng_chg_level,
       MAT.waiv_dev_rej_no                waiv_dev_rej_no,
       MAT.configuration_id               configuration_id,
       MAT.activity_seq                   activity_seq,
       MAT.pick_list_no                   pick_list_no,
       MAT.qty_assigned                   qty_assigned,
       MAT.orig_qty_assigned              orig_qty_assigned,
       MAT.last_activity_date             last_activity_date,
       MAT.condition_code                 condition_code,
       MAT.rowid                         objid,
       ltrim(lpad(to_char(MAT.rowversion,'YYYYMMDDHH24MISS'),2000))                    objversion,
       ALLOC.qty_required                qty_required,
       ALLOC.qty_issued                  qty_issued,
       ALLOC.state                       state,
       ALLOC.objid                       alloc_objid,
       ALLOC.objversion                  alloc_objversion,
       INV.location_group                location_group,
       INV.warehouse                     warehouse,
       INV.bay_no                        bay_no,
       INV.row_no                        row_no,
       INV.tier_no                       tier_no,
       INV.bin_no                        bin_no,
       INV.location_name                 location_name,
       INV.location_type                 location_type,
       INV.location_type_db              location_type_db,
       INV.serial_no                      location_serial_no,
       INV.eng_chg_level                  location_eng_chg_level,
       INV.waiv_dev_rej_no                location_waiv_dev_rej_no,
       INV.avg_unit_transit_cost          avg_unit_transit_cost,
       INV.count_variance                 count_variance,
       INV.expiration_date                expiration_date,
       INV.freeze_flag                    freeze_flag,
       INV.freeze_flag_db                 freeze_flag_db,
       INV.last_count_date                last_count_date,
       INV.qty_in_transit                 qty_in_transit,
       INV.qty_onhand                     qty_onhand,
       INV.qty_reserved                   qty_reserved,
       INV.receipt_date                   receipt_date,
       INV.source                         source,
       INV.availability_control_id        availability_control_id,
       INV.objid                          location_objid,
       INV.objversion                     location_objversion
FROM   shop_material_pick_line_tab MAT,
       SHOP_MATERIAL_ALLOC ALLOC,
       ESI_INVENTORY_PART_IN_STOCK INV
WHERE  MAT.order_no = ALLOC.order_no
  AND  MAT.release_no = ALLOC.release_no
  AND  MAT.sequence_no = ALLOC.sequence_no
  AND  MAT.line_item_no = ALLOC.line_item_no
  AND  MAT.part_no = ALLOC.part_no
  AND  MAT.contract = ALLOC.contract
  AND  MAT.part_no = INV.part_no
  AND  MAT.contract = INV.contract
  AND  MAT.location_no = INV.location_no
  AND  MAT.lot_batch_no = INV.lot_batch_no
  AND  ALLOC.qty_required - ALLOC.qty_issued > 0
WITH   read only;

