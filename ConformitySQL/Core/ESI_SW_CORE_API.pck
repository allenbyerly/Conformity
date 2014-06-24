CREATE OR REPLACE PACKAGE ESI_SW_CORE_API AS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Standard Package
  -- Author:              Allen Byerly
  -- Version:             7.2.1.100
  -- Date:                07/08/2010
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides basic functionailty
  -- to core scanworks services and features specific to Scanworks.
-----------------------------------------------------------------------------------------
version_             CONSTANT VARCHAR2(128) := '7.2.1.100';
package_             CONSTANT VARCHAR2(128) := 'Core';

FUNCTION VERSION RETURN VARCHAR2;
FUNCTION PACKAGE RETURN VARCHAR2;

PROCEDURE UPDATE_PASSWORD(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2);

FUNCTION GET_LABEL_DIR(
   contract_     ESI_SW_PRINT_SITES.CONTRACT%TYPE) RETURN VARCHAR2;

FUNCTION GET_LABEL_NAME(
   contract_     INVENTORY_PART.contract%TYPE,
   part_no_      INVENTORY_PART.part_no%TYPE,
   transaction_  ESI_SW_LABELS.TRANSACTION%TYPE) RETURN ESI_SW_LABELS.LABEL_NAME%TYPE;

FUNCTION GET_LABEL_COUNT(
   contract_     INVENTORY_PART.contract%TYPE,
   part_no_      INVENTORY_PART.part_no%TYPE,
   transaction_  ESI_SW_LABELS.TRANSACTION%TYPE) RETURN ESI_SW_LABELS.NUMBER_OF_LABEL%TYPE;

FUNCTION GET_PRINTER_NO(
   contract_     ESI_SW_MENU_ITEMS.CONTRACT%TYPE,
   menu_name_    ESI_SW_MENU_ITEMS.MENU_NAME%TYPE,
   transaction_  ESI_SW_MENU_ITEMS.TRANSACTION%TYPE) RETURN ESI_SW_MENU_ITEMS.PRINTER_NO%TYPE;

FUNCTION GET_PRINTER_TYPE(
   contract_     ESI_SW_PRINTERS.CONTRACT%TYPE,
   printer_no_   ESI_SW_PRINTERS.PRINTER_NO%TYPE) RETURN ESI_SW_PRINTERS.PRINTER_TYPE%TYPE;

PRAGMA RESTRICT_REFERENCES(GET_LABEL_NAME, WNDS);
PRAGMA RESTRICT_REFERENCES(VERSION, WNDS);

END ESI_SW_CORE_API;
/
CREATE OR REPLACE PACKAGE BODY ESI_SW_CORE_API AS
-----------------------------------------------------------------------------------------
  -- Scanworks 7:         Standard SQL Framework
  -- Transaction/Package: Scanworks Standard Package
  -- Author:              Allen Byerly
  -- Version:             7.2.1.100
  -- Date:                07/08/2010
-----------------------------------------------------------------------------------------
  -- Description:  In general, this package provides basic functionailty
  -- to core scanworks services and features specific to Scanworks.
-----------------------------------------------------------------------------------------
FUNCTION VERSION RETURN VARCHAR2 IS
BEGIN
  RETURN version_;
END;

FUNCTION PACKAGE RETURN VARCHAR2 IS
BEGIN
  RETURN package_;
END;

PROCEDURE SET_USERID(in_attr_   IN VARCHAR2,
                     out_attr_  OUT VARCHAR2)

IS

   userid_          INVENTORY_TRANSACTION_HIST_TAB.Userid%TYPE;

   ptr_             NUMBER;
   name_            VARCHAR2(30);
   value_           VARCHAR2(2000);

BEGIN

   Client_SYS.Clear_Attr(out_attr_);

   ptr_ := NULL;

   WHILE (Client_SYS.Get_Next_From_Attr(in_attr_, ptr_, name_, value_)) LOOP
      IF (name_ = 'USERID') THEN
         userid_ := value_;
      ELSE
         Client_SYS.Add_To_Attr(name_, value_, out_attr_);
      END IF;
   END LOOP;

   FND_SESSION_UTIL_API.Set_Fnd_User_(userid_);
   -- fnd_session_api.set_property('FND_USER', userid_);

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END SET_USERID;

PROCEDURE UPDATE_PASSWORD(in_attr_ IN VARCHAR2, out_attr_ OUT VARCHAR2)

  IS

    attr_ VARCHAR2(2000);

    identity_     esi_sw_users_tab.identity%TYPE;
    contract_     esi_sw_users_tab.contract%TYPE;
    menu_name_    esi_sw_users_tab.menu_name%TYPE;
    value_        esi_sw_users_tab.password%TYPE;

  BEGIN

    attr_ := in_attr_;

    SET_USERID(attr_, attr_);

    attr_ := in_attr_;

    identity_          := CLIENT_SYS.Get_Item_Value('IDENTITY', attr_);
    contract_          := CLIENT_SYS.Get_Item_Value('CONTRACT', attr_);
    menu_name_         := CLIENT_SYS.Get_Item_Value('MENU_NAME', attr_);
    value_             := CLIENT_SYS.Get_Item_Value('PASSWORD', attr_);

     UPDATE esi_sw_users_tab
        SET password = value_
      WHERE identity = identity_
        AND contract = contract_
        AND menu_name = menu_name_;

END UPDATE_PASSWORD;

FUNCTION GET_LABEL(
   contract_  inventory_part.contract%TYPE,
   part_no_   inventory_part.part_no%TYPE,
   transaction_ ESI_SW_MENU_ITEMS.TRANSACTION%TYPE) RETURN     ESI_SW_LABELS%ROWTYPE

IS
   CURSOR  part_catalogs(p_part_no  part_catalog.part_no%TYPE) IS
   SELECT  part_main_group
   FROM    part_catalog
   WHERE   part_no   = p_part_no;

   CURSOR  labels(p_contract            ESI_SW_LABELS.CONTRACT%TYPE,
                  P_transaction         ESI_SW_LABELS.TRANSACTION%TYPE,
                  p_part_no             ESI_SW_LABELS.PART_NO%TYPE,
                  p_part_main_group     ESI_SW_LABELS.PART_MAIN_GROUP%TYPE) IS
   SELECT  *
   FROM    ESI_SW_LABELS
   WHERE   contract             = p_contract
   AND     transaction          = P_transaction
   AND     part_no              = p_part_no
   AND     part_main_group      = p_part_main_group;

   part_main_group_         ESI_SW_LABELS.PART_MAIN_GROUP%TYPE;
   part_catalog_            part_catalogs%ROWTYPE;

   trans_part_label_        labels%ROWTYPE;
   trans_group_label_       labels%ROWTYPE;
   trans_default_label_     labels%ROWTYPE;

   part_label_              labels%ROWTYPE;
   group_label_             labels%ROWTYPE;
   default_label_           labels%ROWTYPE;

   result_                  ESI_SW_LABELS%ROWTYPE;

BEGIN

  -- Get the Part Main Group for the Part
  OPEN   part_catalogs(part_no_);
  FETCH  part_catalogs
  INTO   part_catalog_;

  IF part_catalogs%FOUND THEN
     part_main_group_ := part_catalog_.part_main_group;
  ELSE
     part_main_group_ := '*';
  END IF;


  -- Look for a Transaction Part Label
  OPEN   labels(contract_, transaction_, part_no_, '*');
  FETCH  labels
  INTO   trans_part_label_;

  IF labels%FOUND THEN
     -- If found use the Transaction Part Label
     result_ := trans_part_label_;
     CLOSE  labels;
  ELSE
     CLOSE  labels;
     -- Otherwise look for a Transaction Group Label
     OPEN   labels(contract_, transaction_, '*', part_main_group_);
     FETCH  labels
     INTO   trans_group_label_;

     IF labels%FOUND THEN
        -- If found use the Transaction Group Label
        result_ := trans_group_label_;
        CLOSE  labels;
     ELSE
        CLOSE  labels;
        -- Otherwise look for a Transaction Default Label
        OPEN   labels(contract_, transaction_, '*', '*');
        FETCH  labels
        INTO   trans_default_label_;

        IF labels%FOUND THEN
           -- If found use the Transaction Default Label
           result_ := trans_default_label_;
           CLOSE  labels;
        ELSE
           CLOSE  labels;
           -- Otherwise look for a Part Label
           OPEN   labels(contract_, '*', part_no_, '*');
           FETCH  labels
           INTO   part_label_;

           IF labels%FOUND THEN
              -- If found use the Part Label
              result_ := part_label_;
              CLOSE  labels;
           ELSE
              CLOSE  labels;
              -- Otherwise look for a Group Label
              OPEN   labels(contract_, '*', '*', part_main_group_);
              FETCH  labels
              INTO   group_label_;

              IF labels%FOUND THEN
                 -- If found use the Group Label
                 result_ := group_label_;
                 CLOSE  labels;
              ELSE
                 CLOSE  labels;
                 -- Otherwise look for a Default Label
                 OPEN   labels(contract_, '*', '*', '*');
                 FETCH  labels
                 INTO   default_label_;

                 IF labels%FOUND THEN
                    -- If found use the Part Label
                    result_ := default_label_;
                    CLOSE  labels;
                 ELSE
                    CLOSE  labels;
                    -- Otherwise throw an error
                    RAISE_APPLICATION_ERROR(-20003, 'No label defined for this site');
                 END IF;
              END IF;
           END IF;
        END IF;
     END IF;
  END IF;

  RETURN result_;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END;

FUNCTION GET_LABEL_DIR(
   contract_     ESI_SW_PRINT_SITES.CONTRACT%TYPE) RETURN VARCHAR2

IS
   label_dir_        ESI_SW_PRINT_SITES.LABEL_DIRECTORY%TYPE;

   CURSOR directories IS
   SELECT *
   FROM   ESI_SW_PRINT_SITES
   WHERE  contract       = contract_;

BEGIN

   FOR next_ IN directories LOOP

       label_dir_ := next_.label_directory;

   END LOOP;

   RETURN label_dir_;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END GET_LABEL_DIR;

FUNCTION GET_LABEL_NAME(
   contract_    INVENTORY_PART.contract%TYPE,
   part_no_     INVENTORY_PART.part_no%TYPE,
   transaction_ ESI_SW_LABELS.TRANSACTION%TYPE) RETURN     ESI_SW_LABELS.LABEL_NAME%TYPE

IS

   label_     ESI_SW_LABELS%ROWTYPE;

BEGIN

   label_ := GET_LABEL(contract_, part_no_, transaction_);

   RETURN label_.LABEL_NAME;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END GET_LABEL_NAME;


FUNCTION GET_LABEL_COUNT(
   contract_    INVENTORY_PART.contract%TYPE,
   part_no_     INVENTORY_PART.part_no%TYPE,
   transaction_ ESI_SW_LABELS.TRANSACTION%TYPE) RETURN     ESI_SW_LABELS.NUMBER_OF_LABEL%TYPE

IS

   label_     ESI_SW_LABELS%ROWTYPE;

BEGIN

   label_ := GET_LABEL(contract_, part_no_, transaction_);

   RETURN label_.NUMBER_OF_LABEL;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END GET_LABEL_COUNT;

FUNCTION GET_PRINTER_NO(
   contract_    ESI_SW_MENU_ITEMS.CONTRACT%TYPE,
   menu_name_   ESI_SW_MENU_ITEMS.MENU_NAME%TYPE,
   transaction_ ESI_SW_MENU_ITEMS.TRANSACTION%TYPE) RETURN     ESI_SW_MENU_ITEMS.PRINTER_NO%TYPE

IS

   printers_    ESI_SW_MENU_ITEMS%ROWTYPE;

   CURSOR printers IS
   SELECT *
   FROM ESI_SW_MENU_ITEMS
   WHERE contract = contract_
   AND menu_name = menu_name_
   AND transaction = transaction_
   AND submenu = '*';

BEGIN

   FOR next_ IN printers LOOP
       printers_ := next_;
   END LOOP;

   RETURN printers_.PRINTER_NO;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END GET_PRINTER_NO;

FUNCTION GET_PRINTER_TYPE(
   contract_     ESI_SW_PRINTERS.CONTRACT%TYPE,
   printer_no_   ESI_SW_PRINTERS.PRINTER_NO%TYPE) RETURN ESI_SW_PRINTERS.PRINTER_TYPE%TYPE

IS
   printer_type_         VARCHAR(30);

   CURSOR printers IS
   SELECT *
   FROM   ESI_SW_PRINTERS
   WHERE  contract       = contract_
   AND    printer_no     = printer_no_;

BEGIN

    FOR next_ IN printers LOOP

       printer_type_ := next_.printer_type;

    END LOOP;

    RETURN printer_type_;

EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(SQLCODE, 'ENSYNC_MARKER' || SQLERRM || 'ENSYNC_MARKER');
END GET_PRINTER_TYPE;

END ESI_SW_CORE_API;
/
