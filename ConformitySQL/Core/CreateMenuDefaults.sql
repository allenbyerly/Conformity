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
		
prompt Creating Purchase Order Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Purchase Order',
		SYSDATE);

prompt Creating Customer Order Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Customer Order',
		SYSDATE);

prompt Creating Shop Order Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
		SYSDATE);
		
prompt Creating Work Order Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Work Order',
		SYSDATE);
		
prompt Creating Inventory Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Inventory',
		SYSDATE);

prompt Creating Time Clock Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Time Clock',
		SYSDATE);

prompt Creating Admin Menu
INSERT INTO esi_sw_menus_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
		SYSDATE);


		