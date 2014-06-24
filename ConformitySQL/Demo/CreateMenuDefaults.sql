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
	'10',
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
		
prompt Creating PO Move to Stock
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Purchase Order',
	'PO Move To Stock',
	'*',
	'20',
	'Move to Stock',
	'',
	'ForkLift',
	'*',
	'',
	SYSDATE);

prompt Creating PO Inspect
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Purchase Order',
	'PO Inspect',
	'*',
	'30',
	'Inspect',
	'',
	'Microscope',
	'*',
	'',
	SYSDATE);

prompt Creating Menu Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Purchase Order',
	'RETURN',
	'*',
	'40',
	'Return',
	'',
	'Undo',
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
	'20',
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
	'10',
	'SO Issue',
	'',
	'Label',
	'*',
	'',
	SYSDATE);

prompt Creating SO Picklist Issue
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
	'SO Picklist Issue',
	'*',
	'20',
	'SO Picklist Issue',
	'',
	'Label',
	'*',
	'',
	SYSDATE);


prompt Creating SO Reserve
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
	'SO Reserve',
	'*',
	'30',
	'SO Reserve',
	'',
	'HandTruck',
	'*',
	'',
	SYSDATE);

prompt Creating Menu Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Shop Order',
	'RETURN',
	'*',
	'40',
	'Return',
	'',
	'Undo',
	'*',
	'',
	SYSDATE);
	
prompt		
prompt Creating Default Work Order Menu Items
prompt ------------------------------------------

prompt Creating Work Order Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default',
	'SUBMENU',
	'Work Order',
	'30',
	'Work Order',
	'',
	'factory',
	USER_DEFAULT_API.Get_Contract,
	'',
	SYSDATE);

prompt Creating WO Mat Issue
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Work Order',
	'WO Mat Issue',
	'*',
	'10',
	'WO Mat Issue',
	'',
	'Label',
	'*',
	'',
	SYSDATE);
	
prompt Creating WO Report Time
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Work Order',
	'WO Report Time',
	'*',
	'20',
	'WO Report Time',
	'',
	'Clock',
	'*',
	'',
	SYSDATE);
	
prompt Creating Menu Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Work Order',
	'RETURN',
	'*',
	'30',
	'Return',
	'',
	'Undo',
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
	'40',
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
	'10',
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
	'20',
	'Print Inquiry',
	'1',
	'BarcodeReport',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);

prompt Creating Inventory Count Report
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Inventory',
	'INV Count Report',
	'*',
	'30',
	'Count Report',
	'1',
	'Clipboard',
	'*',
	USER_DEFAULT_API.Get_Contract,
	SYSDATE);

prompt Creating Menu Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Inventory',
	'RETURN',
	'*',
	'40',
	'Return',
	'',
	'Undo',
	'*',
	'',
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

prompt		
prompt Creating Default Customer Order Menu Items
prompt ------------------------------------------

prompt Creating Customer Order Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Default', 
        'SUBMENU', 
        'Customer Order', 
        '60', 
        'Customer Order', 
        '', 
        'Box', 
        USER_DEFAULT_API.Get_Contract, 
        '', 
        SYSDATE);

prompt Creating Customer Order Pick
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Customer Order', 
        'CO Pick', 
        '*', 
        '10', 
        'Pick', 
        '1', 
        'OpenBox', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Customer Order Picklist Pick
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Customer Order', 
        'CO Picklist Pick', 
        '*', 
        '20', 
        'Picklist Pick', 
        '1', 
        'Clipboard', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Customer Order Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Customer Order', 
        'RETURN', 
        '*', 
        '30', 
        'Return', 
        '', 
        'Undo', 
        '*', 
        '', 
        SYSDATE);


prompt		
prompt Creating Default Time Clock Menu Items
prompt ------------------------------------------

prompt Creating Time Clock Submenu
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Default', 
        'SUBMENU', 
        'Time Clock', 
        '70', 
        'Time Clock', 
        '', 
        'AlarmClock', 
        USER_DEFAULT_API.Get_Contract, 
        '', 
        SYSDATE);


prompt Creating Time Clock Clock In
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'Clock In', 
        '*', 
        '10', 
        'Clock In', 
        '1', 
        'Clock', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Time Clock Clock Out
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'Clock Out', 
        '*', 
        '20', 
        'Clock Out', 
        '1', 
        'Clock2', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Time Clock Start Op
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'Start Op', 
        '*', 
        '30', 
        'Start Op', 
        '1', 
        'Clock3', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Time Clock Stop Op
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'Stop Op', 
        '*', 
        '40', 
        'Stop Op', 
        '1', 
        'PocketWatch', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Time Clock Stop Op Qty
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'Stop Op Qty', 
        '*', 
        '50', 
        'Stop Op Qty', 
        '1', 
        'Clock3', 
        '*', 
        USER_DEFAULT_API.Get_Contract, 
        SYSDATE);

prompt Creating Time Clock Return
INSERT INTO esi_sw_menu_items_tab
VALUES (USER_DEFAULT_API.Get_Contract, 
        'Time Clock', 
        'RETURN', 
        '*', 
        '90', 
        'Return', 
        '', 
        'Undo', 
        '*', 
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
		