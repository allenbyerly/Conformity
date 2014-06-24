prompt ________________________________________________
prompt 
prompt Installing Tosoh Triggers
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Tosoh Delivery System Triggers

prompt ------------------------------------------------

prompt Creating Transactions Triggers

CREATE OR REPLACE TRIGGER ESI_SW_DELIVERY_ITR
AFTER INSERT ON ESI_SW_DELIVERY_TAB
REFERENCING OLD AS OLDREC NEW AS NEWREC
FOR EACH ROW
DECLARE
   CURSOR lines IS
   SELECT *
   FROM ESI_SW_DELIVERY_LINES
   WHERE DELNOTE_NO = :NEWREC.DELNOTE_NO;
BEGIN

   FOR next_ IN lines LOOP

       INSERT INTO ESI_SW_DELIVERY_ITEM_TAB
       VALUES ( next_.contract,
                next_.delnote_no,
                next_.part_no,
                next_.serial_no,
                next_.lot_batch_no,
                next_.qty_shipped,
                '0',
                '',
                SYSDATE);
   END LOOP;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END ESI_SW_DELIVERY_ITR;
/

