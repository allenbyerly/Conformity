prompt ________________________________________________
prompt 
prompt Installing Scanworks Default Menu System Data
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Default Menu Data

prompt ------------------------------------------------	

prompt Creating * Menu
INSERT INTO esi_sw_menus_tab
VALUES ('*',
        '*',
	SYSDATE);
				
prompt Creating Default Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	SYSDATE);		
		
prompt Creating Admin Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	SYSDATE);
		