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

prompt Creating Purchase Order Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Purchase Order',
	'50',
	'Purchase Order',
	'',
	'Box',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating PO Receive
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Purchase Order',
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
        'Purchase Order',
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
        'Purchase Order',
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

prompt Creating Customer Order Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Customer Order',
	'50',
	'Customer Order',
	'',
	'BoxFull',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating CO Picklist Pick
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Customer Order',
	'CO Picklist Pick',
	'*',
	'30',
	'Picklist Pick',
	'',
	'Clipboard',
	'*',
	'',
	SYSDATE);

prompt Creating CO Pick
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Customer Order',
	'CO Pick',
	'*',
	'30',
	'Pick',
	'',
	'ForkLift',
	'*',
	'',
	SYSDATE);

prompt		
prompt Creating Default Shop Order Menu Items
prompt ------------------------------------------

prompt Creating Shop Order Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Shop Order',
	'50',
	'Shop Order',
	'',
	'factory',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating SO Issue
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
	'SO Issue',
	'*',
	'30',
	'SO Issue',
	'',
	'Label',
	'*',
	'',
	SYSDATE);

prompt Creating SO Receive
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
	'SO Receive',
	'*',
	'30',
	'SO Receive',
	'',
	'Factory',
	'*',
	'',
	SYSDATE);

prompt		
prompt Creating Default Inventory Menu Items
prompt -------------------------------------

prompt Creating Inventory Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Inventory',
	'50',
	'Inventory',
	'',
	'StackedBoxes',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating Inventory Change Location
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Inventory',
	'INV Change Location',
	'*',
	'40',
	'Change Location',
	'1',
	'ForkLift',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);

prompt Creating Inventory Print Inquiry
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Inventory',
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