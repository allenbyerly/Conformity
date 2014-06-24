prompt ________________________________________________
prompt 
prompt Removing Scanworks Users and Roles
prompt ________________________________________________

prompt ------------------------------------------------

prompt Removing Scanworks Users

prompt ------------------------------------------------

-- prompt Removing Ensync User

-- DECLARE
--   info_            VARCHAR2(2000) := '';
-- BEGIN
-- 	FND_USER_API.Remove_Cascade__(info_,'ENSYNC');
-- END;
-- /


prompt ------------------------------------------------

prompt Removing Scanworks Roles

prompt ------------------------------------------------

prompt Removing Scanworks Role

DECLARE
       info_            VARCHAR2(2000) := '';
       objid_           VARCHAR2(2000) := '';
       objversion_      VARCHAR2(2000) := '';
/*
       CURSOR get_version IS
       SELECT rowid, ltrim(lpad(to_char(rowversion,'YYYYMMDDHH24MISS'),2000))
       FROM  FND_ROLE_TAB
       WHERE role = 'SCANWORKS';
*/
BEGIN
--   	OPEN get_version;
--   	FETCH get_version INTO objid_, objversion_;
--   	CLOSE get_version;	
--	FND_ROLE_API.Remove__( info_, objid_, objversion_, 'DO' );

	Security_SYS.Drop_Role('SCANWORKS');
END;
/
