CREATE OR REPLACE VIEW ESI_SHOP_MATERIAL_ALLOC AS
SELECT MAT.order_no                       order_no,
       MAT.release_no                     release_no,
       MAT.sequence_no                    sequence_no,
       MAT.line_item_no                   line_item_no,
       MAT.part_no                        part_no,
       MAT.contract                       contract,
       MAT.issue_to_loc                   issue_to_loc,
       MAT.note_id                        note_id,
       MAT.operation_no                   operation_no,
       MAT.structure_line_no              structure_line_no,
       MAT.create_date                    create_date,
       MAT.date_required                  date_required,
       MAT.last_activity_date             last_activity_date,
       MAT.last_issue_date                last_issue_date,
       MAT.leadtime_offset                leadtime_offset,
       MAT.priority_no                    priority_no,
       MAT.qty_assigned                   qty_assigned,
       MAT.qty_issued                     qty_issued,
       MAT.qty_on_order                   qty_on_order,
       MAT.qty_per_assembly               qty_per_assembly,
       MAT.shrinkage_factor               shrinkage_factor,
       MAT.component_scrap                component_scrap,
       MAT.qty_required                   qty_required,
       MAT.supply_code                    supply_code,
       MAT.supply_code_db                    supply_code_db,
       MAT.note_text                      note_text,
       MAT.order_code                     order_code,
       MAT.order_code_db                     order_code_db,
       MAT.generate_demand_qty            generate_demand_qty,
       MAT.qty_short                      qty_short,
       MAT.consumption_item               consumption_item,
       MAT.consumption_item_db               consumption_item_db,
       MAT.print_unit                     print_unit,
       MAT.activity_seq                   activity_seq,
       MAT.draw_pos_no                    draw_pos_no,
       MAT.configuration_id               configuration_id,
       MAT.condition_code                 condition_code,
       MAT.part_ownership                 part_ownership,
       MAT.part_ownership_db                 part_ownership_db,
       MAT.owning_customer_no             owning_customer_no,
       MAT.owning_vendor_no               owning_vendor_no,
       MAT.vim_structure_source_db           vim_structure_source_db,
       MAT.vim_structure_source              vim_structure_source,
       MAT.partial_part_required          partial_part_required,
       MAT.project_id                     project_id,
       MAT.catch_qty_issued               catch_qty_issued,
       MAT.replicate_changes              replicate_changes,
       MAT.replaced_qty                   replaced_qty,
       MAT.replaces_qpa_factor            replaces_qpa_factor,
       MAT.replaces_line_item_no          replaces_line_item_no,
       MAT.qty_scrapped_component         qty_scrapped_component,
       MAT.position_part_no               position_part_no,
--       MAT.std_planned_item               std_planned_item,
       MAT.objid                          objid,
       MAT.objversion                     objversion,
       MAT.objstate                       objstate,
       MAT.objevents                      objevents,
       MAT.state                          state,
       INV.location_no                            location_no,
       INV.location_group                location_group,
       INV.warehouse                     warehouse,
       INV.bay_no                        bay_no,
       INV.row_no                        row_no,
       INV.tier_no                       tier_no,
       INV.bin_no                        bin_no,
       INV.location_name                 location_name,
       INV.location_type                 location_type,
       INV.location_type_db              location_type_db,
       INV.lot_batch_no                   lot_batch_no,
       INV.serial_no                      serial_no,
       INV.eng_chg_level                  eng_chg_level,
       INV.waiv_dev_rej_no                waiv_dev_rej_no,
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
FROM   SHOP_MATERIAL_ALLOC MAT,
       ESI_INVENTORY_PART_IN_STOCK INV
WHERE  MAT.part_no = INV.part_no
AND    MAT.contract = INV.contract
AND    MAT.objstate NOT IN ('Closed', 'Parked', 'Planned', 'Cancelled')
AND    MAT.qty_required - MAT.qty_issued > 0;