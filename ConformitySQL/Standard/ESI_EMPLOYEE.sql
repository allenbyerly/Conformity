CREATE OR REPLACE VIEW ESI_EMPLOYEE AS
SELECT company                        	company,      
       person_id                      	person_id,    
       employee_id                    	employee_id,  
       name                            	name,         
       vendor_no                      	vendor_no,    
       org_code                       	org_code,     
       contract                       	contract,
       DELIVERY_ADDRESS                 DELIVERY_ADDRESS, 
       CONTRACT_REF                     CONTRACT_REF,     
       DIST_CALENDAR_ID                 DIST_CALENDAR_ID, 
       MANUF_CALENDAR_ID                MANUF_CALENDAR_ID,
       OFFSET                           OFFSET,           
       ROWVERSION                       ROWVERSION       
FROM   employee_no e, site_tab s
WHERE  s.company(+) = e.company
AND    s.contract(+) = e.contract
WITH   read only; 
       