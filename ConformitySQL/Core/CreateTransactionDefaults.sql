prompt ________________________________________________
prompt 
prompt Installing Scanworks Default Transaction System Data
prompt ________________________________________________

prompt ------------------------------------------------

prompt Creating Scanworks Standard Transaction Data

prompt ------------------------------------------------

prompt Creating * Menu Transaction
INSERT INTO esi_sw_transactions_tab
VALUES ('*',
        '*',
        '*',
        '*',
	'*',
        '*',
	SYSDATE);

prompt Creating Submenu Menu Transaction
INSERT INTO esi_sw_transactions_tab
VALUES ('SUBMENU',
        'SUBMENU',
        'Transaction that provides Submenu Functionality',
        'CORE',
	'SUBMENU',
        '&core_version',
	SYSDATE);
		
prompt Creating Return Menu Transaction
INSERT INTO esi_sw_transactions_tab
VALUES ('RETURN',
        'RETURN',
        'Transaction that provides Return to Previous Menu Functionality',
        'CORE',
	'RETURN',
        '&core_version',
	SYSDATE);
		
prompt Creating Logoff Menu Transaction
INSERT INTO esi_sw_transactions_tab
VALUES ('LOGOFF',
        'LOGOFF',
        'Transaction that provides Logoff Menu Functionality',
        'CORE',
	'LOGOFF',
        '&core_version',
	SYSDATE);


prompt ------------------------------------------------

prompt Creating Scanworks Default Field Data

prompt ------------------------------------------------	


