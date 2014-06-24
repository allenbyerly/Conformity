using System;
using System.Collections.Generic;
using System.Linq;
using QueryBuilder;
using System.Data.OracleClient;

namespace IfsInterface
{
    public class IfsFields
    {
        public List<String> Hierarchy;
        protected Dictionary<string, IfsField> Initalizer;
        public Dictionary<string, IfsField> Fields;
        
        private String FirstFieldID { get; set; } 
        private  String LastFieldID { get; set; }

        public int FieldCount { get; set; }
        

        public IfsFields()
        {
            Hierarchy = new List<string>();
            Initalizer = new Dictionary<string, IfsField>();
            Fields = new Dictionary<string, IfsField>();
        }

        //Constructor to create an initializer based on IFS transaction field values in the database and then sets 
        //the transaction fields to these values
        public IfsFields(OracleConnection connection, string transaction, IfsProperties ifsProperties)
        {
            Hierarchy = new List<string>();
            Initalizer = new Dictionary<string, IfsField>();
            Fields = new Dictionary<string, IfsField>();

            //Build a query to get transaction fields
            OracleQueryBuilder fieldsQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

            //Add Table to Select From
            fieldsQuery.AddFrom("ESI_SW_TRANSACTION_SYSTEM");

            //Add Fields to Select
            fieldsQuery.AddSelect("FIELD_ID", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//0
            fieldsQuery.AddSelect("PROMPT", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//1
            fieldsQuery.AddSelect("FIELD_NAME", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//2
            fieldsQuery.AddSelect("DEFAULT_VALUE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//3
            fieldsQuery.AddSelect("MAX_LENGTH", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//4
            fieldsQuery.AddSelect("READ_ONLY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//5
            fieldsQuery.AddSelect("UPPERCASE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//6
            fieldsQuery.AddSelect("HAS_UOM", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//7
            fieldsQuery.AddSelect("LOV", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//8
            fieldsQuery.AddSelect("LOV_PROMPT", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//9
            fieldsQuery.AddSelect("LOV_ON_ENTRY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//10
            fieldsQuery.AddSelect("LOV_READ_ONLY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//11
            fieldsQuery.AddSelect("CONFIGURABLE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//12
            fieldsQuery.AddSelect("LOOKUP_TABLE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//13
            fieldsQuery.AddSelect("ENABLED", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//14
            fieldsQuery.AddSelect("TRANSACTION", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//15
            fieldsQuery.AddSelect("TITLE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//16
            fieldsQuery.AddSelect("API", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//17

            //Add Query Criteria
            fieldsQuery.AddWhere("TRANSACTION", transaction, "=", "ESI_SW_TRANSACTION_SYSTEM", false, "");
            
            //Add Query Sorting
            fieldsQuery.AddOrder("HIERARCHY", "ESI_SW_TRANSACTION_SYSTEM", "");
            
            //Execute the query
            OracleDataReader results = fieldsQuery.Execute(connection);

            while (results.Read())
            {
                if (!results.IsDBNull(0))
                {
                    FieldCount++;

                    //Add each row to the Hierarchy in order
                    Hierarchy.Add(results.GetString(0));

                    //Create a field to store the values for each row
                    IfsField field = new IfsField();

                    //Set the field hierarchy to the value from the hierarchy 
 //                   field.Hierarchy = Hierarchy.IndexOf(results.GetString(0));
                    
                    //Add row values to the field
                    field.Hierarchy = FieldCount;
                    field.FieldID = GetSafeDBString(results, 0) ?? "";
                    field.Prompt = GetSafeDBString(results, 1) ?? "";
                    field.FieldName = GetSafeDBString(results, 2) ?? "";
                    field.DefaultValue = GetSafeDBString(results, 3) ?? "";
                    field.MaxLength = GetSafeDBString(results, 4) ?? "-1";
                    field.ReadOnly = results.GetString(5) == "Y" ? true : false;
                    field.Uppercase = results.GetString(6) == "Y" ? true : false;
                    field.HasUom = results.GetString(7) == "Y" ? true : false;
                    field.Lov = GetSafeDBString(results, 8) ?? "";
                    field.LovPrompt = GetSafeDBString(results, 9) ?? "";
                    field.LovOnEntry = results.GetString(10) == "Y" ? true : false;
                    field.LovReadOnly = results.GetString(11) == "Y" ? true : false;
                    field.Configurable = results.GetString(12) == "Y" ? true : false;
                    field.Table = GetSafeDBString(results, 13) ?? "";
                    field.Enabled = results.GetString(14) == "Y" ? true : false;
                    field.Transaction = GetSafeDBString(results, 15) ?? "";
                    field.TransactionTitle = GetSafeDBString(results, 16) ?? "";
                    field.API = GetSafeDBString(results, 17) ?? "";
                    field.Value = "";

                    //Add each field to the initializer
                    Initalizer.Add(field.FieldID, field);
                }
            }
            
            //Initalize the transaction fields to the intializer values
            Fields = InitializeFields(Initalizer);
        }

        //Initializes transaction fields with intial field values from the database.
        public Dictionary<string, IfsField> InitializeFields(Dictionary<string, IfsField> initialFields)
        {
            Dictionary<string, IfsField> fields = new Dictionary<string, IfsField>();

            foreach (KeyValuePair<string, IfsField> initialField in initialFields)
            {
                IfsField field = new IfsField();

                field.Hierarchy = initialField.Value.Hierarchy;
                field.FieldID = initialField.Value.FieldID;
                field.Prompt = initialField.Value.Prompt;
                field.FieldName = initialField.Value.FieldName;
                field.DefaultValue = initialField.Value.DefaultValue;
                field.MaxLength = initialField.Value.MaxLength;
                field.ReadOnly = initialField.Value.ReadOnly;
                field.Uppercase = initialField.Value.Uppercase;
                field.HasUom = initialField.Value.HasUom;
                field.Lov = initialField.Value.Lov;
                field.LovPrompt = initialField.Value.LovPrompt;
                field.LovOnEntry = initialField.Value.LovOnEntry;
                field.LovReadOnly = initialField.Value.LovReadOnly;
                field.Table = initialField.Value.Table;
                field.Configurable = initialField.Value.Configurable;
                field.Enabled = initialField.Value.Enabled;
                field.Transaction = initialField.Value.Transaction;
                field.TransactionTitle = initialField.Value.TransactionTitle;
                field.API = initialField.Value.API;
                field.Value = initialField.Value.Value;

                fields.Add(field.FieldID, field);
            }

            //Set iteration values
            FirstFieldID = initialFields.Values.Single(x => x.Hierarchy.Equals(1)).FieldID;
            LastFieldID = initialFields.Values.Single(x => x.Hierarchy.Equals(FieldCount)).FieldID;
            
            return fields;
        }

        //Get Field Values By Field ID
        public int FieldHierarchy(String fieldID)
        {
            return Fields[fieldID].Hierarchy;
        }
        public String FieldName(String fieldID)
        {
            return Fields[fieldID].FieldName;
        }
        public String FieldValue(String fieldID)
        {
            return Fields[fieldID].Value;
        }
        public String FieldPrompt(String fieldID)
        {
            return Fields[fieldID].Prompt;
        }
        public bool FieldReadOnly(String fieldID)
        {
            return Fields[fieldID].ReadOnly;
        }

        //Get Field Values By Hierarchy
        public String FieldID(int hierarchy)
        {
            return Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).FieldID;
        }
        public String FieldName(int hierarchy)
        {
            return Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).FieldName;
        }
        public String FieldValue(int hierarchy)
        {
            return Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).Value;
        }
        public String FieldPrompt(int hierarchy)
        {
            return Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).Prompt;
        }
        public bool FieldReadOnly(int hierarchy)
        {
            return Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).ReadOnly;
        }

        //Get Field Values By Field Name
        public int FieldHierarchyByName(String fieldName)
        {
            return Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Hierarchy;
        }
        public String FieldIDByName(String fieldName)
        {
            return Fields.Values.Single(x => x.FieldName.Equals(fieldName)).FieldID;
        }
        public String FieldValueByName(String fieldName)
        {
            return Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Value;
        }
        public String FieldPromptByName(String fieldName)
        {
            return Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Prompt;
        }
        public bool FieldReadOnlyByName(String fieldName)
        {
            return Fields.Values.Single(x => x.FieldName.Equals(fieldName)).ReadOnly;
        }

        //Set Field Values By Field ID
        public void SetFieldHierarchy(String fieldID, int hierarchy)
        {
           Fields[fieldID].Hierarchy = hierarchy;
        }
        public void SetFieldName(String fieldID, String fieldName)
        {
            Fields[fieldID].FieldName = fieldName;
        }
        public void SetFieldValue(String fieldID, String value)
        {
            Fields[fieldID].Value = value;
        }
        public void SetFieldPrompt(String fieldID, String prompt)
        {
            Fields[fieldID].Prompt = prompt;
        }
        public void SetFieldReadOnly(String fieldID, bool readOnly)
        {
            Fields[fieldID].ReadOnly = readOnly;
        }

        //Set Field Values By Hierarchy
        public void SetFieldID(int hierarchy, String fieldID)
        {
            Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).FieldID = fieldID;
        }
        public void SetFieldName(int hierarchy, String fieldName)
        {
            Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).FieldName = fieldName;
        }
        public void SetFieldValue(int hierarchy, String value)
        {
            Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).Value = value;
        }
        public void SetFieldPrompt(int hierarchy, String prompt)
        {
            Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).Prompt = prompt;
        }
        public void SetFieldReadOnly(int hierarchy, bool readOnly)
        {
            Fields.Values.Single(x => x.Hierarchy.Equals(hierarchy)).ReadOnly = readOnly;
        }

        //Set Field Values By Field Name
        public void SetFieldHierarchyByName(String fieldName, int hierarchy)
        {
            Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Hierarchy = hierarchy;
        }
        public void SetFieldIDByName(String fieldName, String fieldID)
        {
            Fields.Values.Single(x => x.FieldName.Equals(fieldName)).FieldID = fieldID;
        }
        public void SetFieldValueByName(String fieldName, String value)
        {
            Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Value = value;
        }
        public void SetFieldPromptByName(String fieldName, String prompt)
        {
            Fields.Values.Single(x => x.FieldName.Equals(fieldName)).Prompt = prompt;
        }
        public void SetFieldReadOnlyByName(String fieldName, bool readOnly)
        {
            Fields.Values.Single(x => x.FieldName.Equals(fieldName)).ReadOnly = readOnly;
        }

/*Get field values by iteration.*/
       
        //Get First Field Values
        public int FirstHierarchy()
        {
            return Fields[FirstFieldID].Hierarchy;
        }
    /*    public String FirstFieldID()
        {
            return Fields[FirstFieldID].FieldName;
        }*/
        public String FirstFieldName()
        {
            return Fields[FirstFieldID].FieldName;
        }
        public String FirstFieldValue()
        {
            return Fields[FirstFieldID].Value;
        }
        public String FirstFieldPrompt()
        {
            return Fields[FirstFieldID].Prompt;
        }
        public bool FirstFieldReadOnly()
        {
            return Fields[FirstFieldID].ReadOnly;
        }

        //Get Last Field Values
        public int LastHierarchy()
        {
            return Fields[LastFieldID].Hierarchy;
        }
/*
        public String LastFieldID()
        {
            return Fields[LastFieldID].FieldName;
        }*/
        public String LastFieldName()
        {
            return Fields[LastFieldID].FieldName;
        }
        public String LastFieldValue()
        {
            return Fields[LastFieldID].Value;
        }
        public String LastFieldPrompt()
        {
            return Fields[LastFieldID].Prompt;
        }
        public bool LastFieldReadOnly()
        {
            return Fields[LastFieldID].ReadOnly;
        }

        //Get Next Field Values by FieldID
        public int NextHierarchy(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount) 
            {
                nextHierarchy = 0;
            }

            return nextHierarchy;
        }
        public String NextFieldID(String fieldID)
        {
            String nextFieldID = "";
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldID = "";
            }
            else
            {
                nextFieldID = FieldID(nextHierarchy);
            }

            return nextFieldID;
        }
        public String NextFieldName(String fieldID)
        {
            String nextFieldName;
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldName = "";
            }
            else
            {
                nextFieldName = FieldName(nextHierarchy);
            }

            return nextFieldName;
        }
        public String NextFieldValue(String fieldID)
        {
            String nextFieldValue;
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldValue = "";
            }
            else
            {
                nextFieldValue = FieldValue(nextHierarchy);
            }

            return nextFieldValue;
        }
        public String NextFieldPrompt(String fieldID)
        {
            String nextFieldPrompt;
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldPrompt = "";
            }
            else
            {
                nextFieldPrompt = FieldPrompt(nextHierarchy);
            }

            return nextFieldPrompt;
        }

        public bool NextFieldReadOnly(String fieldID)
        {
            bool nextFieldReadOnly;
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldReadOnly = false;
            }
            else
            {
                nextFieldReadOnly = FieldReadOnly(nextHierarchy);
            }

            return nextFieldReadOnly;
        }

        public string NextReadOnlyField(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            while (nextHierarchy < FieldCount || !FieldReadOnly(nextHierarchy))
            {
                nextHierarchy = currentHierarchy + 1;
            }

            if (!FieldReadOnly(nextHierarchy))
            {
                return "";
            }
            else
            {
                return FieldID(nextHierarchy);
            }
        }
        public bool NextFieldReadOnly(int hierarachy)
        {
            bool nextFieldReadOnly;
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldReadOnly = false;
            }
            else
            {
                nextFieldReadOnly = FieldReadOnly(nextHierarchy);
            }

            return nextFieldReadOnly;
        }
        
        public string NextWritableField(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int nextHierarchy = currentHierarchy + 1;

            while (nextHierarchy < FieldCount || FieldReadOnly(nextHierarchy))
            {
                nextHierarchy = currentHierarchy + 1;
            }

            if (FieldReadOnly(nextHierarchy))
            {
                return "";
            }
            else
            {
                return FieldID(nextHierarchy);
            }
        }

        //Get Next Field Values by Hierarchy
        public int NextHierarchy(int hierarachy)
        {
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
            }

            return nextHierarchy;
        }
        public String NextFieldID(int hierarachy)
        {
            String nextFieldID = "";
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldID = "";
            }
            else
            {
                nextFieldID = FieldID(nextHierarchy);
            }

            return nextFieldID;
        }
        public String NextFieldName(int hierarachy)
        {
            String nextFieldName;
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldName = "";
            }
            else
            {
                nextFieldName = FieldName(nextHierarchy);
            }

            return nextFieldName;
        }
        public String NextFieldValue(int hierarachy)
        {
            String nextFieldValue;
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldValue = "";
            }
            else
            {
                nextFieldValue = FieldValue(nextHierarchy);
            }

            return nextFieldValue;
        }
        public String NextFieldPrompt(int hierarachy)
        {
            String nextFieldPrompt;
            int nextHierarchy = hierarachy + 1;

            if (nextHierarchy > FieldCount)
            {
                nextHierarchy = 0;
                nextFieldPrompt = "";
            }
            else
            {
                nextFieldPrompt = FieldPrompt(nextHierarchy);
            }

            return nextFieldPrompt;
        }
        

        

        //Get Previous Field Values by FieldID
        public int PreviousHierarchy(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
            }

            return previousHierarchy;
        }
        public String PreviousFieldID(String fieldID)
        {
            String previousFieldID = "";
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldID = "";
            }
            else
            {
                previousFieldID = FieldID(previousHierarchy);
            }

            return previousFieldID;
        }
        public String PreviousFieldName(String fieldID)
        {
            String previousFieldName;
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldName = "";
            }
            else
            {
                previousFieldName = FieldName(previousHierarchy);
            }

            return previousFieldName;
        }
        public String PreviousFieldValue(String fieldID)
        {
            String previousFieldValue;
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldValue = "";
            }
            else
            {
                previousFieldValue = FieldValue(previousHierarchy);
            }

            return previousFieldValue;
        }
        public String PreviousFieldPrompt(String fieldID)
        {
            String previousFieldPrompt;
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldPrompt = "";
            }
            else
            {
                previousFieldPrompt = FieldPrompt(previousHierarchy);
            }

            return previousFieldPrompt;
        }
        public bool PreviousFieldReadOnly(String fieldID)
        {
            bool previousFieldReadOnly;
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldReadOnly = false;
            }
            else
            {
                previousFieldReadOnly = FieldReadOnly(previousHierarchy);
            }

            return previousFieldReadOnly;
        }

        public string PreviousReadOnlyField(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy - 1;

            while (previousHierarchy > 0 || !FieldReadOnly(previousHierarchy))
            {
                previousHierarchy = currentHierarchy - 1;
            }

            if (!FieldReadOnly(previousHierarchy))
            {
                return "";
            }
            else
            {
                return FieldID(previousHierarchy);
            }
        }

        public string PreviousWritableField(String fieldID)
        {
            int currentHierarchy = FieldHierarchy(fieldID);
            int previousHierarchy = currentHierarchy - 1;

            while (previousHierarchy > 0 || FieldReadOnly(previousHierarchy))
            {
                previousHierarchy = currentHierarchy - 1;
            }

            if (FieldReadOnly(previousHierarchy))
            {
                return "";
            }
            else
            {
                return FieldID(previousHierarchy);
            }
        }

        //Get Previous Field Values by Hierarchy
        public int PreviousHierarchy(int hierarachy)
        {
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
            }

            return previousHierarchy;
        }
        public String PreviousFieldID(int hierarachy)
        {
            String previousFieldID = "";
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldID = "";
            }
            else
            {
                previousFieldID = FieldID(previousHierarchy);
            }

            return previousFieldID;
        }
        public String PreviousFieldName(int hierarachy)
        {
            String previousFieldName;
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldName = "";
            }
            else
            {
                previousFieldName = FieldName(previousHierarchy);
            }

            return previousFieldName;
        }
        public String PreviousFieldValue(int hierarachy)
        {
            String previousFieldValue;
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldValue = "";
            }
            else
            {
                previousFieldValue = FieldValue(previousHierarchy);
            }

            return previousFieldValue;
        }
        public String PreviousFieldPrompt(int hierarachy)
        {
            String previousFieldPrompt;
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldPrompt = "";
            }
            else
            {
                previousFieldPrompt = FieldPrompt(previousHierarchy);
            }

            return previousFieldPrompt;
        }
        public bool PreviousFieldReadOnly(int hierarachy)
        {
            bool previousFieldReadOnly;
            int previousHierarchy = hierarachy + 1;

            if (previousHierarchy < 1)
            {
                previousHierarchy = 0;
                previousFieldReadOnly = false;
            }
            else
            {
                previousFieldReadOnly = FieldReadOnly(previousHierarchy);
            }

            return previousFieldReadOnly;
        }

        private string GetSafeDBString(OracleDataReader reader, int column)
        {
            string result = "";

            if (!reader.IsDBNull(column))
            {
                if (reader[column].GetType() == Decimal.One.GetType())
                {
                    result = reader.GetDecimal(column).ToString();
                    
                }
                else
                {
                    result = reader.GetString(column);
                }
            }
            else
            {
                result = "";
            }

            return result;
        }

        private int GetSafeDBint(OracleDataReader reader, int column)
        {
            int result = -1;

            if (!reader.IsDBNull(column))
            {
                if (!int.TryParse(reader.GetString(column), out result))
                {
                    result = -1;
                }
            }
            else
            {
                result = -1;
            }

            return result;
        }


    }
}
