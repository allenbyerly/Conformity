CREATE OR REPLACE VIEW ESI_INVENTORY AS
SELECT
       ST.contract                      contract,
       ST.part_no                        part_no,
       IP.accounting_group               accounting_group,
       IP.asset_class                    asset_class,
       IP.country_of_origin              country_of_origin,
       IP.hazard_code                    hazard_code,
       IP.note_id                        note_id,
       IP.estimated_material_cost        estimated_material_cost,
       IP.part_product_code              part_product_code,
       IP.part_product_family            part_product_family,
       IP.part_status                    part_status,
       IP.planner_buyer                  planner_buyer,
       IP.prime_commodity                prime_commodity,
       IP.second_commodity               second_commodity,
       IP.unit_meas                      unit_meas,
       IP.description                    description,
       IP.abc_class                      abc_class,
       IP.create_date                    create_date,
       IP.cycle_code                     cycle_code,
       IP.cycle_code_db                  cycle_code_db,
       IP.cycle_period                   cycle_period,
       IP.dim_quality                    dim_quality,
       IP.durability_day                 durability_day,
       IP.expected_leadtime              expected_leadtime,
       IP.lead_time_code                 lead_time_code,
       IP.lead_time_code_db              lead_time_code_db,
       IP.manuf_leadtime                 manuf_leadtime,
       IP.note_text                      note_text,
       IP.oe_alloc_assign_flag           oe_alloc_assign_flag,
       IP.oe_alloc_assign_flag           oe_alloc_assign_flag_db,
       IP.onhand_analysis_flag           onhand_analysis_flag,
       IP.onhand_analysis_flag           onhand_analysis_flag_db,
       IP.purch_leadtime                 purch_leadtime,
       IP.superseded_by                  superseded_by,
       IP.supersedes                     supersedes,
       IP.supply_code                    supply_code,
       IP.supply_code_db                 supply_code_db,
       IP.type_code                      type_code,
       IP.type_code_db                   type_code_db,
       IP.customs_stat_no                customs_stat_no,
       IP.type_designation               type_designation,
       IP.zero_cost_flag                 zero_cost_flag,
       IP.zero_cost_flag_db              zero_cost_flag_db,
       IP.avail_activity_status          avail_activity_status,
       IP.avail_activity_status          avail_activity_status_db,
       IP.eng_attribute                  eng_attribute,
       IP.shortage_flag                  shortage_flag,
       IP.shortage_flag_db               shortage_flag_db,
       IP.forecast_consumption_flag      forecast_consumption_flag,
       IP.forecast_consumption_flag      forecast_consumption_flag_db,
       IP.stock_management               stock_management,
       IP.stock_management_db            stock_management_db,
       IP.weight_net                     weight_net,
       IP.intrastat_conv_factor          intrastat_conv_factor,
       IP.part_cost_group_id             part_cost_group_id,
       IP.dop_connection                 dop_connection                 ,
       IP.dop_connection_db              dop_connection_db,
       IP.std_name_id                    std_name_id,
       IP.ean_no                         ean_no,
       IP.inventory_valuation_method     inventory_valuation_method,
       IP.inventory_valuation_method_db  inventory_valuation_method_db,
       IP.negative_on_hand               negative_on_hand,
       IP.negative_on_hand_db            negative_on_hand_db,
       IP.technical_coordinator_id       technical_coordinator_id,
       IP.actual_cost_activated          actual_cost_activated,
       IP.max_actual_cost_update         max_actual_cost_update,
       IP.cust_warranty_id               cust_warranty_id,
       IP.sup_warranty_id                sup_warranty_id,
       IP.region_of_origin               region_of_origin,
       IP.inventory_part_cost_level      inventory_part_cost_level,
       IP.inventory_part_cost_level_db   inventory_part_cost_level_db,
       IP.ext_service_cost_method        ext_service_cost_method,
       IP.ext_service_cost_method_db     ext_service_cost_method_db,
       IP.supply_chain_part_group        supply_chain_part_group,
       ST.configuration_id               configuration_id,
       ST.lot_batch_no                   lot_batch_no,
       ST.serial_no                      serial_no,
       ST.eng_chg_level                  eng_chg_level,
       ST.waiv_dev_rej_no                waiv_dev_rej_no,
       ST.avg_unit_transit_cost          avg_unit_transit_cost,
       ST.count_variance                 count_variance,
       ST.expiration_date                expiration_date,
       substrb(Inventory_Part_Freeze_Code_API.Decode(ST.freeze_flag_db),1,200) freeze_flag,
       ST.freeze_flag_db                 freeze_flag_db,
       ST.last_activity_date             last_activity_date,
       ST.last_count_date                last_count_date,
       substrb(Inventory_Location_Type_API.Decode(ST.location_type_db),1,200) location_type,
       ST.location_type_db               location_type_db,
       ST.qty_in_transit                 qty_in_transit,
       ST.qty_onhand                     qty_onhand,
       ST.qty_reserved                   qty_reserved,
       ST.receipt_date                   receipt_date,
       ST.source                         source,
       ST.availability_control_id        availability_control_id,
       ST.condition_code                 condition_code,
       substrb(Part_Ownership_API.Decode(ST.part_ownership_db),1,200) part_ownership,
       ST.part_ownership_db              part_ownership_db,
       ST.owning_vendor_no               owning_vendor_no,
       ST.owning_customer_no             owning_customer_no,
       ST.location_no                   location_no,
       ST.location_group                location_group,
       ST.warehouse                     warehouse,
       ST.bay_no                        bay_no,
       ST.row_no                        row_no,
       ST.tier_no                       tier_no,
       ST.bin_no                        bin_no,
       ST.location_name                 location_name,
       ST.priority                      priority,
       ST.objid                         objid,
       ST.objversion                    objversion
FROM   ESI_INVENTORY_PART_IN_STOCK ST,
       INVENTORY_PART IP
WHERE  ST.part_no = IP.part_no (+)
AND    ST.contract = IP.contract (+);
