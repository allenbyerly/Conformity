prompt ________________________________________________
prompt 
prompt Installing Scanworks Default Menu System Data
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Default Menu Item Data

prompt ------------------------------------------------	


prompt		
prompt Creating Default Purchase Order Menu Items
prompt ------------------------------------------


prompt Creating PO Receive
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'PO Receive',
	'*',
	'10',
	'Receive',
	'1',
	'BoxFull',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);
		
prompt Creating PO Inspect
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'PO Inspect',
	'*',
	'20',
	'Inspect',
	'',
	'MagGlass',
	'*',
	'',
	SYSDATE);

prompt Creating PO Move to Stock
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'PO Move To Stock',
	'*',
	'30',
	'Move to Stock',
	'',
	'ForkLift',
	'*',
	'',
	SYSDATE);

prompt		
prompt Creating Default Customer Order Menu Items
prompt ------------------------------------------


prompt Creating CO Picklist Pick
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'CO Picklist Pick',
	'*',
	'30',
	'Picklist Pick',
	'',
	'ForkLift',
	'*',
	'',
	SYSDATE);


prompt Creating CO Verify Delivery
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'CO Verify Delivery',
	'*',
	'30',
	'Verify Delivery',
	'',
	'ForkLift',
	'*',
	'',
	SYSDATE);

prompt		
prompt Creating Default Inventory Menu Items
prompt -------------------------------------


prompt Creating Inventory Change Location
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'INV Change Location',
	'*',
	'40',
	'Change Part Location',
	'1',
	'BarcodeReport',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);

prompt Creating Inventory Print Inquiry
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'INV Print Inquiry',
	'*',
	'40',
	'Print Inquiry',
	'1',
	'BarcodeReport',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);

prompt		
prompt Creating Default Administration Menu Items
prompt ------------------------------------------


prompt Creating Admin Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Admin',
	'50',
	'Admin',
	'',
	'Gears',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating Menu Logoff
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'LOGOFF',
	'*',
	'60',
	'Logoff',
	'',
	'ShutDown',
	'*',
	'',
	SYSDATE);

prompt		
prompt Creating Admin Menu Items
prompt
prompt Creating Admin Change Site
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	'ADMIN Change Site',
	'*',
	'10',
	'Change Site',
	'',
	'Gear',
	'*',
	'',
	SYSDATE);

prompt Creating Admin Change Printer
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	'ADMIN Change Printer',
	'*',
	'20',
	'Change Printer',
	'',
	'Gear',
	'*',
	'',
	SYSDATE);

prompt Creating Admin Change Password
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	'ADMIN Change Password',
	'*',
	'30',
	'Change Password',
	'',
	'Gear',
	'*',
	'',
	SYSDATE);

prompt Creating Menu Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	'RETURN',
	'*',
	'40',
	'Return',
	'',
	'Undo',
	'*',
	'',
	SYSDATE);
		
prompt Creating Menu Logoff
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Admin',
	'LOGOFF',
	'*',
	'50',
	'Logoff',
	'',
	'ShutDown',
	'*',
	'',
	SYSDATE);		