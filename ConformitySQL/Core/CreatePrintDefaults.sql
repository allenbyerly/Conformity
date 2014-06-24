prompt ________________________________________________
prompt 
prompt Installing Scanworks Default Print System Data
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Default Printer Data

prompt ------------------------------------------------

prompt Creating Default Print Site
INSERT INTO esi_sw_print_sites_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'NONE',
		SYSDATE);

prompt Creating Default Printer
INSERT INTO esi_sw_printers_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        '1',
		'Default Printer',
		'Default Printer',
		'',
		SYSDATE);		

prompt ------------------------------------------------

prompt Creating Scanworks Default Label Data

prompt ------------------------------------------------	

prompt Creating Default Label Name
INSERT INTO esi_sw_label_names_tab
VALUES (USER_DEFAULT_API.Get_Contract,
        'Default.lwl',
		SYSDATE);

prompt Creating Default Label Data
INSERT INTO esi_sw_labels_tab
VALUES (USER_DEFAULT_API.Get_Contract,
		'*',
		'*',
		'*',
		'Default.lwl',
        	'1',
		SYSDATE);	