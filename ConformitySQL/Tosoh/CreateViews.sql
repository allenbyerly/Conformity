prompt ________________________________________________
prompt 
prompt Installing Tosoh Custom Views
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Tosoh Delivery System Views

prompt ------------------------------------------------

prompt Creating Delivery Status View
CREATE OR REPLACE VIEW ESI_SW_DELIVERY_STATUS AS
SELECT  STATUS.CONTRACT                    CONTRACT,
        STATUS.DELNOTE_NO                  DELNOTE_NO,
        STATUS.STATUS                      STATUS,
        VERIFIED.PART_NO                   PART_NO,
        VERIFIED.SERIAL_NO                 SERIAL_NO,
        VERIFIED.LOT_BATCH_NO              LOT_BATCH_NO,
        VERIFIED.QTY_SHIPPED               QTY_SHIPPED,
        VERIFIED.VERIFIED                  VERIFIED,
        VERIFIED.VERIFIED_BY               VERIFIED_BY
FROM    ESI_SW_DELIVERY_TAB                STATUS,
        ESI_SW_DELIVERY_ITEM_TAB           VERIFIED
WHERE   STATUS.CONTRACT  (+) = VERIFIED.CONTRACT
AND     STATUS.DELNOTE_NO (+) = VERIFIED.DELNOTE_NO;

prompt Creating Delivery Lines View
CREATE OR REPLACE VIEW ESI_SW_DELIVERY_LINES AS
SELECT  ORDERS.CONTRACT                    CONTRACT,
        ORDERS.ORDER_NO                    ORDER_NO,
        ORDERS.LINE_NO                     LINE_NO,
        ORDERS.REL_NO                      REL_NO,
        ORDERS.LINE_ITEM_NO                LINE_ITEM_NO,
        ORDERS.CUSTOMER_NO                 CUSTOMER_NO,
        ORDERS.CUSTOMER_NAME               CUSTOMER_NAME,
        ORDERS.CUSTOMER_PO_NO              CUSTOMER_PO_NO,
        RESERVATION.PICK_LIST_NO           PICK_LIST_NO,
        RESERVATION.PART_NO                PART_NO,
        RESERVATION.SERIAL_NO              SERIAL_NO,
        RESERVATION.LOT_BATCH_NO           LOT_BATCH_NO,
        RESERVATION.ENG_CHG_LEVEL          ENG_CHG_LEVEL,
        RESERVATION.WAIV_DEV_REJ_NO        WAIV_DEV_REJ_NO,
        RESERVATION.LOCATION_NO            LOCATION_NO,
        RESERVATION.QTY_SHIPPED            QTY_SHIPPED,
        RESERVATION.DELIV_NO               DELIV_NO,
        RESERVATION.LAST_ACTIVITY_DATE     LAST_ACTIVITY_DATE,
        DELIVERY.DATE_DELIVERED            DATE_DELIVERED,
        DELIVERY.DELNOTE_NO                DELNOTE_NO
FROM    CUSTOMER_ORDER_JOIN                ORDERS,
        CUSTOMER_ORDER_RESERVATION         RESERVATION,
        CUSTOMER_ORDER_DELIVERY            DELIVERY
WHERE   ORDERS.ORDER_NO = RESERVATION.ORDER_NO
AND     ORDERS.LINE_NO = RESERVATION.LINE_NO
AND     ORDERS.REL_NO = RESERVATION.REL_NO
AND     RESERVATION.DELIV_NO = DELIVERY.DELIV_NO;

prompt Creating Delivery View
CREATE OR REPLACE VIEW ESI_SW_DELIVERY AS
SELECT  LINES.CONTRACT                    CONTRACT,
        LINES.ORDER_NO                    ORDER_NO, 
        LINES.LINE_NO                     LINE_NO,  
        LINES.REL_NO                      REL_NO, 
        LINES.LINE_ITEM_NO                LINE_ITEM_NO, 
        LINES.CUSTOMER_NO                 CUSTOMER_NO, 
        LINES.CUSTOMER_NAME               CUSTOMER_NAME, 
        LINES.CUSTOMER_PO_NO              CUSTOMER_PO_NO, 
        LINES.PICK_LIST_NO                PICK_LIST_NO, 
        LINES.PART_NO                     PART_NO, 
		INVENTORY_PART_API.GET_DESCRIPTION(LINES.CONTRACT, LINES.PART_NO) DESCRIPTION,
        LINES.SERIAL_NO                   SERIAL_NO,
        LINES.LOT_BATCH_NO                LOT_BATCH_NO,     
        LINES.ENG_CHG_LEVEL               ENG_CHG_LEVEL, 
        LINES.WAIV_DEV_REJ_NO             WAIV_DEV_REJ_NO, 
        LINES.LOCATION_NO                 LOCATION_NO,
        LINES.QTY_SHIPPED                 QTY_SHIPPED, 
        LINES.DELIV_NO                    DELIV_NO, 
        LINES.LAST_ACTIVITY_DATE          LAST_ACTIVITY_DATE,
        LINES.DATE_DELIVERED              DATE_DELIVERED,
        LINES.DELNOTE_NO                  DELNOTE_NO,
        STATUS.STATUS                     STATUS,
        STATUS.VERIFIED                   VERIFIED,
        STATUS.VERIFIED_BY                VERIFIED_BY
FROM    ESI_SW_DELIVERY_LINES             LINES,
        ESI_SW_DELIVERY_STATUS            STATUS 
WHERE   LINES.DELNOTE_NO  = STATUS.DELNOTE_NO 
AND     LINES.PART_NO  = STATUS.PART_NO
AND     LINES.LOT_BATCH_NO  = STATUS.LOT_BATCH_NO
AND     LINES.SERIAL_NO  = STATUS.SERIAL_NO;