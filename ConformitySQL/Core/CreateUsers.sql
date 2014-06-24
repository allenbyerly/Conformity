prompt ________________________________________________
prompt 
prompt Adding Scanworks Users and Roles
prompt ________________________________________________

prompt ------------------------------------------------

prompt Adding Scanworks Roles

prompt ------------------------------------------------

prompt Adding Scanworks Role

DECLARE
       attr_            VARCHAR2(2000) := '';
       info_            VARCHAR2(2000) := '';
       objid_           VARCHAR2(2000) := '';
       objversion_      VARCHAR2(2000) := '';
BEGIN

 --      Client_Sys.Clear_Attr(attr_);

 --      Client_SYS.Add_To_Attr('ROLE', 'SCANWORKS', attr_);
 --      Client_SYS.Add_To_Attr('DESCRIPTION', 'SCANWORKS', attr_);
 --      Client_SYS.Add_To_Attr('FND_ROLE_TYPE','End User Role', attr_);

 --      Fnd_Role_API.NEW__( info_, objid_, objversion_, attr_, 'DO' ); 
  
         Security_SYS.Create_Role('SCANWORKS');
END;
/

prompt Granting Transaction System Tables to Role

GRANT ALL ON ESI_SW_TRANSACTIONS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_FIELDS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_TRANSACTION_LOG_TAB TO SCANWORKS;

prompt Granting Menu System Tables to Role

GRANT ALL ON ESI_SW_USERS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_ICONS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_MENUS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_MENU_ITEMS_TAB TO SCANWORKS;

prompt Granting Printing System Tables to Role

GRANT ALL ON ESI_SW_PRINT_SITES_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_PRINTERS_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_LABEL_NAMES_TAB TO SCANWORKS;
GRANT ALL ON ESI_SW_LABELS_TAB TO SCANWORKS;

prompt Granting Transaction System Views to Role

GRANT SELECT ON ESI_SW_TRANSACTIONS TO SCANWORKS;
GRANT SELECT ON ESI_SW_FIELDS TO SCANWORKS;
GRANT SELECT ON ESI_SW_TRANSACTION_LOG TO SCANWORKS;
GRANT SELECT ON ESI_SW_TRANSACTION_SYSTEM TO SCANWORKS;

prompt Granting Menu System Views to Role

GRANT SELECT ON USER_ALLOWED_SITE TO SCANWORKS;
GRANT SELECT ON ESI_SW_ACTIVE_USERS TO SCANWORKS;
GRANT SELECT ON ESI_SW_SITES TO SCANWORKS;
GRANT SELECT ON ESI_SW_USERS TO SCANWORKS;
GRANT SELECT ON ESI_SW_USER_MENUS TO SCANWORKS;
GRANT SELECT ON ESI_SW_ICONS TO SCANWORKS;
GRANT SELECT ON ESI_SW_MENUS TO SCANWORKS;
GRANT SELECT ON ESI_SW_MENU_ITEMS TO SCANWORKS;
GRANT SELECT ON ESI_SW_MENU_SYSTEM TO SCANWORKS;

prompt Granting Printing System Views to Role

GRANT SELECT ON ESI_SW_PRINT_SITES TO SCANWORKS;
GRANT SELECT ON ESI_SW_PRINTERS TO SCANWORKS;
GRANT SELECT ON ESI_SW_LABEL_NAMES TO SCANWORKS;
GRANT SELECT ON ESI_SW_LABELS TO SCANWORKS;
GRANT SELECT ON ESI_SW_PRINT_SYSTEM TO SCANWORKS;

prompt Granting Scanworks API to Role

GRANT ALL ON ESI_SW_CORE_API TO SCANWORKS;

/
-- prompt ------------------------------------------------

-- prompt Adding Scanworks Users

-- prompt ------------------------------------------------

-- prompt Adding Ensync

-- DECLARE   
--        attr_ 		VARCHAR2(2000) := '';
--        info_            VARCHAR2(2000) := '';
--        objid_           VARCHAR2(2000) := '';
--        objversion_      VARCHAR2(2000) := '';
--        tablespace_	USER_USERS.DEFAULT_TABLESPACE%TYPE;

-- BEGIN

--        SELECT DEFAULT_TABLESPACE 
--        INTO tablespace_
--        FROM USER_USERS;

--        Client_Sys.Clear_Attr(attr_);

--        Client_SYS.Add_To_Attr('IDENTITY', 'ENSYNC', attr_);
--        Client_SYS.Add_To_Attr('DESCRIPTION', 'ENSYNC', attr_);
--        Client_SYS.Add_To_Attr('ORACLE_USER', 'ENSYNC', attr_);
--        Client_SYS.Add_To_Attr('WEB_USER', 'ENSYNC', attr_);
--        Client_SYS.Add_To_Attr('ACTIVE', 'TRUE', attr_);
--        Client_SYS.Add_To_Attr('ORACLE_PASSWORD', 'ENSYNC', attr_);
--        Client_SYS.Add_To_Attr('EXPIRE_PASSWORD', 'FALSE', attr_);
--        Client_SYS.Add_To_Attr('DEFAULT_TABLESPACE', tablespace_, attr_);
  
--        FND_USER_API.NEW__( info_, objid_, objversion_, attr_, 'DO' ); 

-- END;
-- / 

-- DECLARE   

--        tablespace_	USER_USERS.DEFAULT_TABLESPACE%TYPE;

-- BEGIN

--        SELECT DEFAULT_TABLESPACE 
--        INTO tablespace_
--        FROM USER_USERS;

--        EXECUTE IMMEDIATE  'ALTER USER ENSYNC QUOTA UNLIMITED ON ' || tablespace_; 
-- END;
-- / 

-- GRANT SCANWORKS TO IFSAPP;
-- GRANT FND_ADMIN TO ENSYNC;
-- GRANT FND_CONNECT TO ENSYNC;
-- GRANT SCANWORKS TO ENSYNC;

-- DECLARE
          
--        CURSOR roles IS
--        SELECT * 
--        FROM   FND_USER_ROLE
--        WHERE  UPPER(IDENTITY) = UPPER('&APPOWNER');
-- BEGIN
--        FOR next_ IN roles LOOP
--          EXECUTE IMMEDIATE  'GRANT ' ||next_.role || ' TO ENSYNC'; 
--        END LOOP;
-- END;    
-- /    