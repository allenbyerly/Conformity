using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using System.Security.Cryptography;
using System.Security.Cryptography.Xml;
using System.Data.OracleClient;
using System.Reflection;
using System.ComponentModel;
using System.Collections;
using System.Collections.Specialized;
using QueryBuilder;
using ScannerFunctions;

namespace IfsInterface
{
    public abstract class IfsTransaction : MarshalByRefObject
    {
        //   public OrderedDictionary Fields = new OrderedDictionary();
        //   public ICollection fields;
        public Dictionary<string, IfsField> Fields;
        protected Dictionary<string, IfsField> InitalFields;
        public IfsTransactions.Transaction transaction;
        //  private ArrayList heirarchy = new ArrayList();
        public Dictionary<string, string> test;
        public List<String> hierarchy;
        protected OracleConnection connection;
        protected IfsProperties ifsProperties;
        protected Lov ifsLov;
        protected OracleQueryBuilder configurationQuery;

        protected bool SmartScanned { get; set; }
        protected IfsSmartScan SmartScan { get; set; }
        protected int SmartIndex { get; set; }

        public string CurrentField {get; set;}
        public string ApiName { get; set; } 
        public string TransactionName { get; set; }
        public string Language { get; set; }
        public string Uom { get; set; }
        public bool CanSave { get; set; }
        public string StatusLine { get; set; }
        public int lastValidatedField { get; set; }

        protected FunctionMenu functionMenu;
        protected SubMenuItem save;
        protected SubMenuItem lov;
        protected SubMenuItem picture;

        string nextAPI = "";
        string title = "";
        string printerNumber = "";
        public string PrinterNumber { get { return printerNumber; } }

        public string NextField { get; set; }

        public abstract XmlDocument Initialize();
        public abstract void Focus(string fieldId, string value);
        public abstract void Validate(string fieldId, string value);
        public abstract void ValidateField(string fieldID, string value, int smartIndex);
        public abstract XmlDocument Lov(string fieldId, int height, string value);
        public abstract string GetValue(string fieldId);
        public abstract string GetUomValue(string fieldId);
        public abstract bool IsFieldReadOnly(string fieldId);
        public abstract void ClearField(string fieldId);
        public abstract bool HasImage(string fieldID);
        
        public DialogMessageBox dialogMessageBox;

        public DialogMessageBox IfsDialogMessage { get { return dialogMessageBox; } }

        public virtual XmlDocument LovAction(string action)
        {
            return ifsLov.UpdateDisplay(action);
        }

        public virtual XmlDocument MenuAction(string action)
        {
            throw new NotImplementedException();
        }

        public virtual string GetSmartFieldID(int smartIndex)
        {
            return "";
        }

        public virtual bool HasImage()
        {
            return false;
        }

        public virtual bool isExecutable()
        {
            IDictionaryEnumerator enumerator = Fields.GetEnumerator();
            bool result = false;

            while (enumerator.MoveNext())
            {
                if (Fields[enumerator.Key.ToString()].Value.Equals(""))
                {
                    result = false;
                    break;
                }
                else
                {
                    result = true;
                }
            }

            return result;
        }

        public virtual XmlDocument MenuAction(string action, string fieldId)
        {
            return MenuAction(action);
        }

        virtual public void InitializeMenu()
        {
            try
            {
                functionMenu = new FunctionMenu();

                save = new SubMenuItem("Save");
                save.Enabled = CanSave;
                save.StatusPrompt = "Working...";

                functionMenu.AddSubMenu(MenuDirection.Left, save);

                SubMenuItem commands = new SubMenuItem("Commands");
                commands.Enabled = true;
                functionMenu.AddSubMenu(MenuDirection.Right, commands);

                lov = new SubMenuItem("LOV");
                lov.Enabled = true;
                commands.AddSubMenu(lov);

                picture = new SubMenuItem("Picture");
                picture.Enabled = HasImage();
                commands.AddSubMenu(picture);

                SubMenuItem end = new SubMenuItem("End");
                end.Enabled = true;
                commands.AddSubMenu(end);
            }
            catch (Exception e)
            {
                transaction.Failed = true;
                throw new Exception(e.Message);
            }
        }

        public IfsTransaction(OracleConnection connection, IfsTransactions.Transaction transaction, IfsProperties ifsProperties)
        {
            try
            {
                    this.connection = connection;
                    this.transaction = transaction;
                    this.TransactionName = transaction.Title;
                    this.ifsProperties = ifsProperties;
                    NextField = "";
                    InitalFields = new Dictionary<string, IfsField>();
                    Fields = new Dictionary<string, IfsField>();
                    hierarchy = new List<string>();

                    dialogMessageBox = ifsProperties.DialogMessageBox;

                    Language = "en-us";

                }
                catch (Exception e)
                {
                    transaction.Failed = true;
                    throw new Exception(e.Message);
                }

                //LoadFields(connection, transactionName, ifsProperties);
            }

        public void LoadFields(OracleConnection connection, IfsProperties ifsProperties)
            {
                try{
                Fields = new Dictionary<string, IfsField>();
                hierarchy = new List<string>();
                transaction.LoadFields(connection, ifsProperties);
                foreach (KeyValuePair<string, IfsField> field in transaction.Fields.Fields)
                {
                    hierarchy.Add(field.Value.FieldID);
                }
                /*OracleQueryBuilder fieldsQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

                //Add Fields to Select
                fieldsQuery.AddSelect("FIELD_ID", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//0
                fieldsQuery.AddSelect("ENABLED", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//1
                fieldsQuery.AddSelect("CONFIGURABLE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//2
                fieldsQuery.AddSelect("LOOKUP_TABLE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//3
                fieldsQuery.AddSelect("PROMPT", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//4
                fieldsQuery.AddSelect("FIELD_NAME", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//5
                fieldsQuery.AddSelect("DEFAULT_VALUE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//6
                fieldsQuery.AddSelect("MAX_LENGTH", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//7
                fieldsQuery.AddSelect("READ_ONLY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//8
                fieldsQuery.AddSelect("UPPERCASE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//9
                fieldsQuery.AddSelect("HAS_UOM", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//10
                fieldsQuery.AddSelect("LOV", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//11
                fieldsQuery.AddSelect("LOV_PROMPT", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//12
                fieldsQuery.AddSelect("LOV_ON_ENTRY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//13
                fieldsQuery.AddSelect("LOV_READ_ONLY", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//14           
                fieldsQuery.AddSelect("TRANSACTION", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//15
                fieldsQuery.AddSelect("PACKAGE", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//16
                fieldsQuery.AddSelect("API", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//17
                fieldsQuery.AddSelect("VERSION", "", "", "ESI_SW_TRANSACTION_SYSTEM", "");//18

                //Add Table to Select From
                fieldsQuery.AddFrom("ESI_SW_TRANSACTION_SYSTEM");

                //Add Query Criteria
                fieldsQuery.AddWhere("API", transactionName, "=", "ESI_SW_TRANSACTION_SYSTEM", false, "");
                
                //Add Query Sorting
                fieldsQuery.AddOrder("HIERARCHY", "ESI_SW_TRANSACTION_SYSTEM", "");
                
                //Execute the query
                OracleDataReader results = fieldsQuery.Execute(connection);

                while (results.Read())
                {
                    hierarchy.Add(GetSafeDBString(reader, 0));

                    Field field = new Field();
                    field.Hierarchy = hierarchy.IndexOf(GetSafeDBString(reader, 0)) + 1;
                    field.FieldID = GetSafeDBString(reader, 0);
                    field.Enabled = (GetSafeDBString(reader, 1) == "Y" ? true : false);
                    field.Configurable = (GetSafeDBString(reader, 2) == "Y" ? true : false);
                    field.LookupTable = GetSafeDBString(reader, 3);
                    field.Prompt = GetSafeDBString(reader, 4);
                    field.FieldName = GetSafeDBString(reader, 5);
                    field.DefaultValue = GetSafeDBString(reader, 6);
                    field.MaxLength = (GetSafeDBint(reader, 7) <= 0 ? -1 : GetSafeDBint(reader, 8));
                    field.ReadOnly = (GetSafeDBString(reader, 8) == "Y" ? true : false);
                    field.Uppercase = (GetSafeDBString(reader, 9) == "Y" ? true : false);
                    field.HasUom = (GetSafeDBString(reader, 10) == "Y" ? true : false);
                    field.Lov = GetSafeDBString(reader, 11);
                    field.LovPrompt = GetSafeDBString(reader, 12);
                    field.LovOnEntry = (GetSafeDBString(reader, 13) == "Y" ? true : false);
                    field.LovReadOnly = (GetSafeDBString(reader, 14) == "Y" ? true : false);
                    field.Transaction = GetSafeDBString(reader, 15);
                    field.Package = GetSafeDBString(reader, 16);
                    field.API = GetSafeDBString(reader, 17);
                    field.Version = GetSafeDBString(reader, 18);      
                    field.Value = "";

                    InitalFields.Add(field.FieldID, field);
                }
        
                using (OracleCommand cmd = connection.CreateCommand())
                {
                    try
                    {
     
                        cmd.CommandText = string.Format("select TITLE, API from esi_sw_transactions where lower(api) = '{0}'", TransactionName.ToLower());
                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                title = reader.GetOracleString(0).Value;
                                apiName = reader.GetOracleString(1).Value;
                            }
                        }

                        cmd.CommandText = "SELECT field_id, transaction, api, prompt, default_value, field_name, lov, lov_prompt, "//0,1,2,3,4,5,6,7
                                        + "max_length, enabled, read_only, uppercase, has_uom, lov_on_entry, lov_read_only, configurable "//8,9,10,11,12,13,14,15
                                        + "FROM esi_sw_transaction_system where api = :api "
                                        + "ORDER BY hierarchy ";

                        cmd.Parameters.Add("api", OracleType.VarChar).Value = apiName;

                        using (OracleDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {

                                hierarchy.Add(GetSafeDBString(reader, 0));

                                Field field = new Field();
                                field.Hierarchy = hierarchy.IndexOf(GetSafeDBString(reader, 0)) + 1;
                                field.FieldID = GetSafeDBString(reader, 0);
                                field.Transaction = GetSafeDBString(reader, 1);
                                field.API = GetSafeDBString(reader, 2);
                                field.Prompt = GetSafeDBString(reader, 3);
                                field.DefaultValue = GetSafeDBString(reader, 4);
                                field.FieldName = GetSafeDBString(reader, 5);
                                field.Lov = GetSafeDBString(reader, 6);
                                field.LovPrompt = GetSafeDBString(reader, 7);
                                field.MaxLength = (GetSafeDBint(reader, 8) <= 0 ? -1 : GetSafeDBint(reader, 8));
                                field.Enabled = (GetSafeDBString(reader, 9) == "Y" ? true : false);
                                field.ReadOnly = (GetSafeDBString(reader, 10) == "Y" ? true : false);
                                field.Uppercase = (GetSafeDBString(reader, 11) == "Y" ? true : false);
                                field.HasUom = (GetSafeDBString(reader, 12) == "Y" ? true : false);
                                field.LovOnEntry = (GetSafeDBString(reader, 13) == "Y" ? true : false);
                                field.LovReadOnly = (GetSafeDBString(reader, 14) == "Y" ? true : false);
                                field.Configurable = (GetSafeDBString(reader, 15) == "Y" ? true : false);
                                field.Value = "";

                                InitalFields.Add(field.FieldID, field);
                            }
                        }
                    }
                    catch (Exception er)
                    {
                        throw new Exception(er.Message);
                    }
                }*/

                Fields = InitializeFields(transaction.Fields.Fields);
                InitializeMenu();
            }
            catch (Exception e)
            {
                transaction.Failed = true;
                throw new Exception(e.Message);
            }
        }

        public Dictionary<string, IfsField> InitializeFields(Dictionary<string, IfsField> initalFields)
        {
            Dictionary<string, IfsField> fields = new Dictionary<string, IfsField>();

            foreach (KeyValuePair<string, IfsField> initialField in initalFields)
            {
                IfsField field = new IfsField();
                field.Hierarchy = initialField.Value.Hierarchy;
                field.FieldID = initialField.Value.FieldID;
                field.Transaction = initialField.Value.Transaction;
                field.API = initialField.Value.API;
                field.Prompt = initialField.Value.Prompt;
                field.DefaultValue = initialField.Value.DefaultValue;
                field.FieldName = initialField.Value.FieldName;
                field.Lov = initialField.Value.Lov;
                field.LovPrompt = initialField.Value.LovPrompt;
                field.MaxLength = initialField.Value.MaxLength;
                field.Enabled = initialField.Value.Enabled;
                field.ReadOnly = initialField.Value.ReadOnly;
                field.Uppercase = initialField.Value.Uppercase;
                field.HasUom = initialField.Value.HasUom;
                field.LovOnEntry = initialField.Value.LovOnEntry;
                field.LovReadOnly = initialField.Value.LovReadOnly;
                field.Configurable = initialField.Value.Configurable;
                field.Value = initialField.Value.Value;

                fields.Add(field.FieldID, field);
            }

            return fields;
        }

        private string GetSafeDBString(OracleDataReader reader, int column)
        {
            string result = "";

            if (!reader.IsDBNull(column))
            {
                result = reader.GetString(column);
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

        private void AddFieldElements(XmlElement statusElement)
        {
            try
            {
                IDictionaryEnumerator enumerator = Fields.GetEnumerator();
                XmlElement fields = statusElement.OwnerDocument.CreateElement("Fields");
                statusElement.AppendChild(fields);

                while (enumerator.MoveNext())
                {
                    IfsField currentField = (IfsField)enumerator.Value;

                    if (currentField.Enabled)
                    {
                        string fieldId = currentField.FieldID;
                        XmlText text;
                        XmlElement element;
                        XmlElement field = statusElement.OwnerDocument.CreateElement("Field");

                        element = statusElement.OwnerDocument.CreateElement("FIELD_ID");
                        text = statusElement.OwnerDocument.CreateTextNode(fieldId);
                        element.AppendChild(text);
                        field.AppendChild(element);

                        if (GetValue(fieldId).Length > 0)
                        {
                            element = statusElement.OwnerDocument.CreateElement("VALUE");
                            text = statusElement.OwnerDocument.CreateTextNode(GetValue(fieldId));
                            element.AppendChild(text);
                            field.AppendChild(element);
                        }

                        element = statusElement.OwnerDocument.CreateElement("READ_ONLY");
                        text = statusElement.OwnerDocument.CreateTextNode(IsFieldReadOnly(fieldId) ? "Y" : "N");
                        element.AppendChild(text);
                        field.AppendChild(element);

                        element = statusElement.OwnerDocument.CreateElement("IS_NEXT_FIELD");
                        text = statusElement.OwnerDocument.CreateTextNode(fieldId.Equals(NextField) ? "Y" : "N");
                        element.AppendChild(text);
                        field.AppendChild(element);

                        if (GetUomValue(fieldId).Length > 0)
                        {
                            element = statusElement.OwnerDocument.CreateElement("UOM");
                            text = statusElement.OwnerDocument.CreateTextNode(GetUomValue(fieldId));
                            element.AppendChild(text);
                            field.AppendChild(element);
                        }

                        fields.AppendChild(field);
                    }
                }

            }
            catch (Exception er)
            {
                throw new Exception(er.Message);
            }
        }

        public string GetNextField(string fieldId)
        {
            String nextFieldId;
            int nextFieldIndex;
            string result = "";

            if (!NextField.Equals("") && !IsFieldReadOnly(fieldId))
            {
                result = NextField;
            }
            else if (Fields.Count <= Fields[fieldId].Hierarchy)
            {
                if (!IsFieldReadOnly(fieldId))
                {
                    result = fieldId;
                }
                else
                {
                    nextFieldId = fieldId;
                    do
                    {
                        if (1 >= Fields[nextFieldId].Hierarchy)
                        {
                            nextFieldIndex = 1;
                            nextFieldId = hierarchy[nextFieldIndex - 1];
                        }
                        else
                        {
                            nextFieldIndex = Fields[nextFieldId].Hierarchy - 1;
                            nextFieldId = hierarchy[nextFieldIndex - 1].ToString();
                        }
                    }
                    while (IsFieldReadOnly(nextFieldId) && 1 < nextFieldIndex);

                    if (1 >= nextFieldIndex)
                    {
                        if (!IsFieldReadOnly(nextFieldId))
                        {
                            result = nextFieldId;
                        }
                        else
                        {
                            Fields[nextFieldId].ReadOnly = false;
                            result = nextFieldId;
                        }
                    }
                    else
                    {
                        result = nextFieldId;
                    }

                }
            }
            else
            {
                nextFieldId = fieldId;
                do
                {
                    if (Fields.Count <= Fields[nextFieldId].Hierarchy)
                    {
                        nextFieldIndex = Fields.Count;
                        nextFieldId = hierarchy[nextFieldIndex - 1];
                    }
                    else
                    {
                        nextFieldIndex = Fields[nextFieldId].Hierarchy + 1;
                        nextFieldId = hierarchy[nextFieldIndex - 1].ToString();
                    }
                }
                while (IsFieldReadOnly(nextFieldId) && Fields.Count > Fields[nextFieldId].Hierarchy);

                if (Fields.Count <= nextFieldIndex)
                {
                    if (!IsFieldReadOnly(nextFieldId))
                    {
                        result = nextFieldId;
                    }
                    else
                    {
                        Fields[fieldId].ReadOnly = false;
                        result = fieldId;
                    }
                }
                else
                {
                    result = nextFieldId;
                }
            }

            return result;

        }

        public string GetPreviousField(string field_id)
        {
            string result = "";

            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "select field_id from esi_scanworks_fields_tab where hierarchy = " +
                    "(select hierarchy-1 from esi_scanworks_fields_tab where field_id = :fieldId)";

                cmd.Parameters.Add("fieldId", OracleType.VarChar).Value = field_id;

                using (OracleDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        result = reader.GetString(0);
                    }
                }
            }
            return result;
        }

        protected void Clear()
        {
            foreach (KeyValuePair<string, IfsField> field in Fields)
            {
                field.Value.Value = "";

                if (!field.Value.DefaultValue.Equals("") && field.Value.Enabled == false)
                {
                    field.Value.Value = field.Value.DefaultValue;
                    field.Value.ReadOnly = true;
                }
            }

            Uom = "";
        }

        protected void ClearLowerFields(string fieldID)
        {
            int currentHierarchy;

            currentHierarchy = hierarchy.IndexOf(fieldID) + 1;

            while (currentHierarchy <= hierarchy.Count - 1)
            {
                if (!IsFieldReadOnly(hierarchy[currentHierarchy]))
                {
                   ClearField(Fields[hierarchy[currentHierarchy]].FieldID);
                }

                currentHierarchy++;
            }
        }

        protected virtual void RefreshConfiguration(string fieldID, OracleQueryBuilder query)
        {
            int currentHierarchy;

            currentHierarchy = hierarchy.IndexOf(fieldID);

            while (currentHierarchy <= hierarchy.Count - 1)
            {
                if (Fields[fieldID].Configurable)
                {
                    query.RemoveWhere("", hierarchy[currentHierarchy]);
                    query.RemoveHaving("", hierarchy[currentHierarchy]);
                }

                currentHierarchy++;
            }
        }

        protected virtual void RefreshQuery(string fieldID, OracleQueryBuilder query)
        {
            int currentHierarchy;

            currentHierarchy = hierarchy.IndexOf(fieldID);

            while (currentHierarchy <= hierarchy.Count - 1)
            {
                query.RemoveWhere("", hierarchy[currentHierarchy]);
                query.RemoveHaving("", hierarchy[currentHierarchy]);
                query.RemoveGroup("", hierarchy[currentHierarchy]);
                query.RemoveOrder("", hierarchy[currentHierarchy]);
                currentHierarchy++;
            }
        }

        protected virtual XmlDocument Lov(string fieldID, string sql, int height)
        {
            XmlDocument lovDoc = new XmlDocument();
            int columnCount = 0;
            List<List<string>> rowValues = new List<List<string>>();
            List<string> columnValues = new List<string>();
            string title = "";
            bool firstRow = true;

            OracleCommand cmd = connection.CreateCommand();
           
            cmd.CommandText = sql.ToString();

            OracleDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
            {
                columnCount = reader.FieldCount;

                if (firstRow)
                {
                    firstRow = false;

                    for (int i = 0; i < reader.FieldCount; i++)
                    {

                        if (!i.Equals(0))
                        {
                            title += "\\";
                        }

                        title += reader.GetName(i);
                    }
                }

                columnValues = new List<string>();

                for (int i = 0; i < columnCount; i++)
                {
                    if (!reader.IsDBNull(i))
                    {
                        object columnValue = reader.GetOracleValue(i);
                        object columnType = reader.GetOracleValue(i).GetType();

                        if (columnValue is System.Data.OracleClient.OracleString)
                        {
                            columnValues.Add(reader.GetString(i));
                        }
                        else if (columnValue is System.Data.OracleClient.OracleNumber)
                        {
                            columnValues.Add(reader.GetDecimal(i).ToString());
                        }
                        else
                        {
                            throw new Exception(string.Format("Unexpected data type encountered"));
                        }

                    }
                    else
                    {
                        columnValues.Add(" ");
                    }
                }

                rowValues.Add(columnValues);                  
            }

            ifsLov = new IfsLov(height);
            ifsLov.Load(rowValues, title);

            lovDoc = ifsLov.Display();

            return lovDoc;
        }

        public XmlDocument APICall(OracleConnection connection, XmlDocument requestDoc)
        {
            try
            {
                XmlDocument resultDoc = new XmlDocument();

                XmlDocument doc = d_3782slff389f928f93.oeoefsifcvase(requestDoc);

                XmlNodeList nodeList = doc.GetElementsByTagName("TRANSACTION");

                if (nodeList.Count > 1)
                {
                    throw new Exception("Ambigious API node");
                }

                XmlNode apiNode = nodeList[0];
                XmlAttributeCollection attributes = apiNode.Attributes;

                if (attributes.Count > 1)
                {
                    throw new Exception("Ambigious API name");
                }

                string apiName = attributes[0].Value;

                string[] apiNames = apiName.Split(new char[] { '.' });

                string packageName = (apiNames.Length > 1) ? apiNames[0] : apiName;
                string methodName = apiNames[1];

                switch (methodName)
                {
                    default:
                        throw new Exception(string.Format("Unknown method: {0}", methodName));

                    case "Get_Screen":
                        {
                            resultDoc = GetScreen(connection, Language);
                            XmlNode parameterNode = apiNode.FirstChild;
                            XmlText screen = doc.CreateTextNode("scn");
                            screen.Value = resultDoc.InnerXml;
                            parameterNode.AppendChild(screen);
                        }
                        break;

                    case "Initialize":
                        {
                            try
                            {
                                resultDoc = Initialize();
                                XmlNode parameterNode = apiNode.FirstChild;
                                XmlText screen = doc.CreateTextNode("scn");
                                screen.Value = resultDoc.InnerXml;
                                parameterNode.AppendChild(screen);
                            }
                            catch (Exception ex)
                            {
                                transaction.Failed = true;
                                throw new Exception(ex.Message);
                            }
                        }
                        break;

                    case "Get_Menu":
                        {
                            resultDoc = functionMenu.GetMenuDoc();
                            XmlNode parameterNode = apiNode.FirstChild;
                            XmlText screen = doc.CreateTextNode("scn");
                            screen.Value = resultDoc.InnerXml;
                            parameterNode.AppendChild(screen);
                        }
                        break;

                    case "Validate_Field":
                        Validate(requestDoc);
                        break;
                    case "FOCUS":
                        Focus(requestDoc);
                        break;
                    case "Menu_Action":
                        {
                            XmlNode parameterNode = apiNode.FirstChild;
                            string action = ((XmlText)parameterNode.FirstChild).Value;

                            XmlNode statusNode = apiNode.ChildNodes[1];
                            string fieldId = ((XmlText)apiNode.ChildNodes[2].FirstChild).Value;

                            resultDoc = MenuAction(action, fieldId);

                            XmlText statusText = requestDoc.CreateTextNode(resultDoc.InnerXml);
                            statusNode.AppendChild(statusText);
                        }
                        break;

                    case "Lov":
                        {
                            string fieldId = "";
                            short height = 15;
                            XmlNode lovNode = null;
                            string value = "";

                            XmlNode api = requestDoc.GetElementsByTagName("TRANSACTION")[0];
                            foreach (XmlNode parameter in api.ChildNodes)
                            {
                                if (parameter.Attributes.Count > 0)
                                {
                                    XmlAttribute attribute = parameter.Attributes[0];
                                    switch (attribute.Value)
                                    {
                                        case "field_name_":
                                            fieldId = ((XmlText)parameter.FirstChild).Value;
                                            break;

                                        case "lov_height_":
                                            {
                                                string s = ((XmlText)parameter.FirstChild).Value;
                                                if (Int16.TryParse(s, out height))
                                                {
                                                    height = Int16.Parse(s);
                                                }
                                            }
                                            break;

                                        case "lov_document_":
                                            lovNode = parameter;
                                            break;

                                        case "value":
                                            value = ((XmlText)parameter.FirstChild).Value;
                                            break;
                                    }
                                }
                            }
                            XmlDocument lovDoc = Lov(fieldId, height, value);
                            XmlText lovText = requestDoc.CreateTextNode(lovDoc.InnerXml);
                            lovNode.AppendChild(lovText);
                        }
                        break;

                    case "Lov_Action":
                        {
                            string action = "";
                            XmlNode lovNode = null;

                            XmlNode api = requestDoc.GetElementsByTagName("TRANSACTION")[0];
                            foreach (XmlNode parameter in api.ChildNodes)
                            {
                                if (parameter.Attributes.Count > 0)
                                {
                                    XmlAttribute attribute = parameter.Attributes[0];
                                    switch (attribute.Value)
                                    {
                                        case "action_":
                                            action = ((XmlText)parameter.FirstChild).Value;
                                            break;

                                        case "lov_display_":
                                            lovNode = parameter;
                                            break;
                                    }
                                }
                            }

                            XmlDocument lovDoc = LovAction(action);
                            XmlText lovText = requestDoc.CreateTextNode(lovDoc.InnerXml);
                            lovNode.AppendChild(lovText);
                        }
                        break;
                }

                return d_3782slff389f928f93.llol_3xfgiu8fsfs(requestDoc);
            }
            catch (Exception e)
            {
                StatusLine = e.Message;
                throw new Exception(e.Message, e);
            }
        }

        public XmlDocument GetStatus()
        {
            XmlDocument statusDoc = new XmlDocument();
            XmlElement status = statusDoc.CreateElement("Status");
            statusDoc.AppendChild(status);

            InitializeMenu();
            functionMenu.AddMenuElement(status);

            IfsPage.AddPageElement(status, ifsProperties, connection);

            dialogMessageBox.DialogMessage(status);

            XmlElement statusElement = statusDoc.CreateElement("STATUS");
            status.AppendChild(statusElement);
            XmlText statusTextNode = statusDoc.CreateTextNode(StatusLine);
            statusElement.AppendChild(statusTextNode);

            XmlElement nextApiElement = statusDoc.CreateElement("NEXT_API");
            status.AppendChild(nextApiElement);
            XmlText nextApiTextNode = statusDoc.CreateTextNode(nextAPI);
            nextApiElement.AppendChild(nextApiTextNode);

            XmlElement titleElement = statusDoc.CreateElement("Title");
            status.AppendChild(titleElement);
            XmlText titleTextNode = statusDoc.CreateTextNode(title);
            titleElement.AppendChild(titleTextNode);

            AddFieldElements(status);


            return statusDoc;
        }

        private XmlDocument GetScreen(OracleConnection connection, string language)
        {
            try
            {

                LoadFields(connection, ifsProperties);

                IDictionaryEnumerator enumerator = Fields.GetEnumerator();

                XmlDocument doc = new XmlDocument();

                XmlElement root = doc.CreateElement("Screen");
                doc.AppendChild(root);

                //         string fieldNames = "API,Field_ID,Hierarchy,Prompt,Lov_On_Entry,Lov_Read_Only,Default_Value,Uppercase,Has_UOM";

                //       string[] fields = fieldNames.Split(new char[] { ',' });

                while (enumerator.MoveNext())
                {
                    IfsField currentField = (IfsField)enumerator.Value;
                    if (currentField.Enabled)
                    {
                        XmlElement field = doc.CreateElement("Field");
                        root.AppendChild(field);
                        // TypeDescriptor.GetProperties

                        PropertyDescriptorCollection properties = TypeDescriptor.GetProperties(currentField);

                        foreach (PropertyDescriptor property in properties)
                        {
                            if (property.IsBrowsable)
                            {
                                String elementName = property.Description.ToLower();
                                String elementValue;
                                /*        if (property.Description.ToLower().Equals("default_value"))
                                        {
                                            elementName = "value";
                                        }
                                        else
                                        {
                                            elementName = property.Description.ToLower();
                                        }

                                
                                        */

                                if (property.GetValue(currentField).GetType().Equals(typeof(bool)))
                                {
                                    elementValue = property.GetValue(currentField).ToString() == "True" ? "Y" : "N";
                                }
                                else
                                {
                                    elementValue = property.GetValue(currentField).ToString();
                                }

                                XmlElement column = doc.CreateElement(elementName.ToLower());
                                XmlText value;

                                if (!elementValue.Equals(""))
                                {
                                    value = doc.CreateTextNode(elementValue);

                                    column.AppendChild(value);
                                    field.AppendChild(column);
                                }

                            }

                        }
                        /*          if property.
                                  AttributeCollection attributes = property.Attributes.;
                              }
                              currentField.GetType().
                              foreach (PropertyInfo property in currentField.GetType().GetProperties().GetType())
                              {
                                  property.GetIndexParameters(
                                  AttributeCollection attributes = TypeDescriptor.GetProperties(currentField)[0].Attributes;
   
                                  if (attributes[typeof(BrowsableAttribute)].Equals(BrowsableAttribute.Yes))
                                  {
                                      String elementName = attributes[typeof(DescriptionAttribute)].ToString().ToLower();
                                      String elementValue = property.GetValue(currentField, null).ToString();

                                      XmlElement column = doc.CreateElement(elementName.ToLower());
                                      XmlText value;

                                      if (!elementValue.Equals(""))
                                      {
                                          value = doc.CreateTextNode(elementValue);

                                          column.AppendChild(value);
                                          field.AppendChild(column);
                                      }

                                  }

                              }*/
                    }
                }
                return doc;
            }
            catch (Exception er)
            {
                throw new Exception(er.Message);
            }

        }

        public void Focus(System.Xml.XmlDocument requestDoc)
        {
            string fieldId = "";
            string value = "";
            XmlNode statusNode = null;

            foreach (XmlNode parameter in requestDoc.GetElementsByTagName("TRANSACTION")[0].ChildNodes)
            {
                XmlText text;
                XmlAttribute attribute;
                if (parameter.Attributes.Count > 0)
                {
                    attribute = parameter.Attributes[0];

                    switch (attribute.Value)
                    {
                        default:
                            throw new Exception(string.Format("Unknown validation parameter {0}", attribute.Name));

                        case "status_":
                            statusNode = parameter;
                            break;

                        case "field_name_":
                            text = (XmlText)parameter.FirstChild;
                            fieldId = text.Value;
                            break;

                        case "value_":
                            if (null != parameter.FirstChild)
                            {
                                text = (XmlText)parameter.FirstChild;
                                value = text.Value;
                            }
                            break;
                    }
                }
            }

            Focus(fieldId, value);

            NextField = fieldId;

            XmlDocument status = GetStatus();
            XmlText statusText = requestDoc.CreateTextNode(status.InnerXml);
            statusNode.AppendChild(statusText);
        }

        public void Validate(System.Xml.XmlDocument requestDoc)
        {
            string fieldId = "";
            string value = "";
            XmlNode statusNode = null;

            foreach (XmlNode parameter in requestDoc.GetElementsByTagName("TRANSACTION")[0].ChildNodes)
            {
                XmlText text;
                XmlAttribute attribute;
                if (parameter.Attributes.Count > 0)
                {
                    attribute = parameter.Attributes[0];

                    switch (attribute.Value)
                    {
                        default:
                            throw new Exception(string.Format("Unknown validation parameter {0}", attribute.Name));

                        case "status_":
                            statusNode = parameter;
                            break;

                        case "field_name_":
                            text = (XmlText)parameter.FirstChild;
                            fieldId = text.Value;
                            break;

                        case "value_":
                            if (null != parameter.FirstChild)
                            {
                                text = (XmlText)parameter.FirstChild;
                                value = text.Value;
                            }
                            break;
                    }
                }
            }

            NextField = "";

            Validate(fieldId, value);

            XmlDocument status = GetStatus();
            XmlText statusText = requestDoc.CreateTextNode(status.InnerXml);
            statusNode.AppendChild(statusText);
        }

        public virtual void ValidateStandardField(OracleQueryBuilder query, string fieldID, string value, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);
                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                SmartScan.ResetScan(nextSmartIndex);
            }

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                    if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }
                }
            }

            query.AddWhere(Fields[fieldID].FieldName, value, "=", "", false, fieldID);
            value = query.Query(Fields[fieldID].FieldName, Fields[fieldID].Prompt, "DISTINCT", "", "", connection);

            switch (value)
            {
                case "-": configurationQuery.RemoveWhere("", fieldID);
                    Fields[fieldID].ReadOnly = false;
                    throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                case "": Fields[fieldID].ReadOnly = false;
                    Fields[fieldID].Value = "";
                    throw new Exception("Invalid Field/Order Data");

                case "{Null}": Fields[fieldID].Value = "";
                    lastValidatedField = Fields[fieldID].Hierarchy;
                    break;

                default: Fields[fieldID].Value = value;
                    lastValidatedField = Fields[fieldID].Hierarchy;
                    break;
            }
            if (SmartScan.IsSmart())
            {
                if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
            }
            else if ((Fields[nextFieldID].Hierarchy < Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {
                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "DISTINCT", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": 
                        configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": 
                        Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
        }

        //all purpose method that validates quantities instead of strings 
        public virtual void ValidateQtyField(OracleQueryBuilder query, string fieldID, decimal fieldQty, decimal limitQty, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            string value;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);

                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                nextFieldIndex = Fields[nextFieldID].Hierarchy;

                SmartScan.ResetScan(nextSmartIndex);
            }

            if (fieldQty.Equals(null)) { throw new Exception("Invalid Field/Order Data"); }
            if (limitQty.Equals(null)) { throw new Exception("Invalid Field/Order Data"); }
            if (fieldQty > limitQty) { throw new Exception(string.Format("{0} Excessive", "Quantity")); }
            if (fieldQty <= 0) { throw new Exception(string.Format("{0} Insufficient", "Quantity")); }

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                    if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }
                }
            }

            Fields[fieldID].ReadOnly = false;

            query.AddWhere(Fields[fieldID].FieldName, limitQty.ToString(), ">=", "", false, fieldID);
            value = query.Query(fieldQty.ToString(), Fields[fieldID].Prompt, "DISTINCT", "", "", connection);

            switch (value)
            {
                case "-": configurationQuery.RemoveWhere("", fieldID);
                    Fields[fieldID].ReadOnly = false;
                    throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                case "": Fields[fieldID].ReadOnly = false;
                    Fields[fieldID].Value = "";
                    throw new Exception("Invalid Field/Order Data");

                case "{Null}": Fields[fieldID].Value = "";
                    break;

                default: Fields[fieldID].Value = value;
                    break;
            }
            if (SmartScan.IsSmart())
            {
                if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
            }
            else if ((Fields[nextFieldID].Hierarchy < Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {

                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "DISTINCT", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].Value = fieldQty.ToString();
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = fieldQty.ToString();
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
        }

        //General purpose method with extra enhancmentss for selection searching
        public virtual void ValidateStandardFieldBySelection(OracleQueryBuilder query, string selection, string fieldID, string value, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);
                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                SmartScan.ResetScan(nextSmartIndex);
            }

            if (selection == null)
            {
                selection = Fields[fieldID].FieldName;
            }

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                    if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }
                }
            }

            query.AddWhere(selection, value, "=", "", false, fieldID);
            value = query.Query(selection, Fields[fieldID].Prompt, "DISTINCT", "", "", connection);

            switch (value)
            {
                case "-": query.RemoveWhere("", fieldID);
                    Fields[fieldID].ReadOnly = false;
                    throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                case "": Fields[fieldID].ReadOnly = false;
                    Fields[fieldID].Value = "";
                    throw new Exception("Invalid Field/Order Data");

                case "{Null}": Fields[fieldID].Value = "";
                    lastValidatedField = Fields[fieldID].Hierarchy;
                    break;

                default: Fields[fieldID].Value = value;
                    lastValidatedField = Fields[fieldID].Hierarchy;
                    break;
            }
            if (SmartScan.IsSmart())
            {
                if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
            }
            else if ((Fields[nextFieldID].Hierarchy < Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {

                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "DISTINCT", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": query.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        break;

                    case "": Fields[fieldID].Value = value;
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }

        }

        //general all purpose validation method designed with the most features and allows for on the fly custom changes.
        public virtual void ValidateConfigurableField(string fieldID, string value, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);
                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                SmartScan.ResetScan(nextSmartIndex);
            }

            configurationQuery.AddWhere(Fields[fieldID].FieldName, value, "=", "", false, fieldID);

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                  if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }

                }
            }

            if ((Fields[nextFieldID].Hierarchy <= Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {
                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "DISTINCT", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].Value = value;
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
            else
            {
                value = configurationQuery.Query(Fields[fieldID].FieldName, Fields[fieldID].Prompt, "DISTINCT", "", "", connection);

                switch (value)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].ReadOnly = false;
                        Fields[fieldID].Value = "";
                        throw new Exception("Invalid Field/Order Data");

                    case "{Null}": Fields[fieldID].Value = "";
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;

                    default: Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }
                if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
        }

        //general all purpose validation method designed with the most features and allows for on the fly custom changes.
        public virtual void ValidateConfigurableFieldBySum(string fieldID, string value, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);
                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                SmartScan.ResetScan(nextSmartIndex);
            }

            configurationQuery.AddWhere(Fields[fieldID].FieldName, value, "=", "", false, fieldID);

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                    if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }

                }
            }

            if ((Fields[nextFieldID].Hierarchy <= Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {
                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].Value = value;
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
            else
            {
                value = configurationQuery.Query(Fields[fieldID].FieldName, Fields[fieldID].Prompt, "SUM", "", "", connection);

                switch (value)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].ReadOnly = false;
                        Fields[fieldID].Value = "";
                        throw new Exception("Invalid Field/Order Data");

                    case "{Null}": Fields[fieldID].Value = "";
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;

                    default: Fields[fieldID].Value = value;
                        lastValidatedField = Fields[fieldID].Hierarchy;
                        break;
                }
                if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
        }

        public virtual void ValidateNextField(string fieldID, string value, int smartIndex)
        {
            string nextFieldID = "";
            string nextFieldValue = "";
            int nextFieldIndex = 0;
            int nextSmartIndex = 0;

            if (SmartScan.IsSmart())
            {
                value = SmartScan.GetValueByIndex(smartIndex);
                nextSmartIndex = smartIndex + 1;
                nextFieldID = GetSmartFieldID(nextSmartIndex);
                SmartScan.ResetScan(nextSmartIndex);
            }

            if (nextFieldID.Equals(""))
            {
                nextFieldID = fieldID;

                while (Fields[nextFieldID].Hierarchy < Fields.Count)
                {
                    nextFieldIndex = Fields[nextFieldID].Hierarchy;
                    nextFieldID = hierarchy[nextFieldIndex];

                    if (Fields[nextFieldID].Configurable) { break; }
                    if (Fields[nextFieldID].Enabled && !Fields[nextFieldID].ReadOnly) { break; }

                }
            }

            if ((Fields[nextFieldID].Hierarchy < Fields.Count)
            && !(Fields[nextFieldID].FieldName.Equals(fieldID))
            && Fields[nextFieldID].Configurable)
            {
                nextFieldValue = configurationQuery.Query(Fields[nextFieldID].FieldName, Fields[nextFieldID].Prompt, "DISTINCT", "", "", connection);

                switch (nextFieldValue)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].Value = value;
                        Fields[nextFieldID].ReadOnly = false;
                        if (!Fields[nextFieldID].Enabled) { throw new Exception(string.Format("No {0} Support", Fields[nextFieldID].Prompt)); }
                        break;

                    default: if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                        Fields[fieldID].Value = value;
                        break;
                }

                if (!Fields[nextFieldID].Value.Equals("") && nextFieldValue.Equals("")) { nextFieldValue = Fields[nextFieldID].Value; }

                if (nextFieldValue.Equals("{Null}")) { ValidateField(nextFieldID, "", nextSmartIndex); }
                else if (!SmartScan.IsSmart() && !nextFieldValue.Equals("")) { ValidateField(nextFieldID, nextFieldValue, nextSmartIndex); }
                else if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
            else
            {
                switch (value)
                {
                    case "-": configurationQuery.RemoveWhere("", fieldID);
                        Fields[fieldID].ReadOnly = false;
                        throw new Exception(string.Format("Invalid {0}", Fields[fieldID].Prompt));

                    case "": Fields[fieldID].ReadOnly = false;
                        Fields[fieldID].Value = "";
                        throw new Exception("Invalid Field/Order Data");

                    case "{Null}": Fields[fieldID].Value = "";
                        break;

                    default: Fields[fieldID].Value = value;
                        break;
                }
                if (SmartScan.IsSmart())
                {
                    if (!nextFieldID.Equals(CurrentField)) { Fields[nextFieldID].ReadOnly = true; }
                    nextFieldValue = SmartScan.GetValueByIndex(nextSmartIndex);
                    ValidateField(nextFieldID, nextFieldValue, nextSmartIndex);
                }
            }
        }

        /* static XmlDocument GetScreen(string apiName, OracleConnection connection, string language)
         {
             IDictionaryEnumerator enumerator = Fields.GetEnumerator();
             XmlDocument doc = new XmlDocument();

             XmlElement root = doc.CreateElement("Screen");
             doc.AppendChild(root);

             string fieldNames = "API,Field_ID,Hierarchy,Prompt,Lov_On_Entry,Lov_Read_Only,Default_Value,Uppercase,Has_UOM";

             string[] fields = fieldNames.Split(new char[] { ',' });
             using (OracleCommand cmd = connection.CreateCommand())
             {
                 cmd.CommandText = string.Format("select {0} from esi_scanworks_fields_tab where API = :api and enabled = 'Y'", fieldNames);
                 cmd.Parameters.Add("api", OracleType.VarChar).Value = apiName;

                 using (OracleDataReader reader = cmd.ExecuteReader())
                 {
                     while (reader.Read())
                     {
                         XmlElement field = doc.CreateElement("Field");
                         root.AppendChild(field);

                         foreach (string fieldName in fields)
                         {
                             XmlElement column = doc.CreateElement(fieldName.ToLower());

                             XmlText value;
                             if (fieldName.ToLower().Equals("hierarchy"))
                             {
                                 int hierarchy = (int)reader.GetDecimal(reader.GetOrdinal(fieldName));
                                 value = doc.CreateTextNode(hierarchy.ToString());
                             }
                             else
                             {
                                 if (!reader.IsDBNull(reader.GetOrdinal(fieldName)))
                                 {
                                     string prompt = reader.GetString(reader.GetOrdinal(fieldName));
                                     value = doc.CreateTextNode(prompt);
                                 }
                                 else
                                 {
                                     value = null;
                                 }
                             }

                             if (null != value)
                             {
                                 column.AppendChild(value);
                                 field.AppendChild(column);
                             }
                         }
                     }
                 }
             }

             return doc;
         }*/

        internal class d_3782slff389f928f93
        {
            static RijndaelManaged key = null;
            static byte[] x = new byte[32];
            static byte[] y = new byte[16];

            private static void fjiej338f9sdlx(string xddf839f8jh2sfn9n)
            {
                sjnfi_f3_f38fs();

                PasswordDeriveBytes passwordDeriveBytes = new PasswordDeriveBytes(
                    xddf839f8jh2sfn9n,
                    new MD5CryptoServiceProvider().ComputeHash(sdknv398fx_3fns_(xddf839f8jh2sfn9n)));

                x = passwordDeriveBytes.GetBytes(32);
                y = passwordDeriveBytes.GetBytes(16);

                key = new RijndaelManaged();
                key.Key = x;
                key.IV = y;
                key.BlockSize = 128;
                key.Padding = PaddingMode.PKCS7;

                ICryptoTransform iCryptoTransform = key.CreateEncryptor(x, y);
            }

            private static string sjnfi_f3_f38fs()
            {
                byte t = 71;

                StringBuilder i3ff = new StringBuilder();

                i3ff.Append((char)t);
                t ^= 40;
                i3ff.Append((char)t);
                t -= 27;
                i3ff.Append((char)t);
                t ^= 59;
                i3ff.Append((char)t);
                t = (byte)(t + 475);
                i3ff.Append((char)t);
                t = (byte)(t + 279);
                i3ff.Append((char)t);
                t = (byte)(t - 248);
                i3ff.Append((char)t);
                t ^= 5;
                i3ff.Append((char)t);

                return i3ff.ToString();

            }

            private static byte[] sdknv398fx_3fns_(string s)
            {
                byte[] bytes;
                char[] chars = s.ToCharArray();

                bytes = new byte[chars.Length];

                for (int i = 0; i < chars.Length; i += 1)
                {
                    bytes[i] = (byte)chars[i];
                }
                return bytes;
            }

            static private void __mfif_mf_f_mr3(XmlDocument ifei_f8f989haf, string te____tetttttxx3333333)
            {
                fjiej338f9sdlx(te____tetttttxx3333333);
                r4_4938____fff3fs(ifei_f8f989haf, "Scanworks", key);
            }

            static internal XmlDocument llol_3xfgiu8fsfs(XmlDocument ___f3f32_fXFFs)
            {
                __mfif_mf_f_mr3(___f3f32_fXFFs, sjnfi_f3_f38fs());
                return ___f3f32_fXFFs;
            }

            static private void _fef3_3f3_fsx(XmlDocument xmlDoc, string keyString)
            {
                fjiej338f9sdlx(keyString);
                wwef_fvxmcnvrv__a(xmlDoc, key);
            }

            static internal XmlDocument oeoefsifcvase(XmlDocument ooeoeoeoeoeoe)
            {
                _fef3_3f3_fsx(ooeoeoeoeoeoe, sjnfi_f3_f38fs());
                return ooeoeoeoeoeoe;
            }

            private static void r4_4938____fff3fs(XmlDocument Doc, string ElementName, SymmetricAlgorithm Key)
            {
                // Check the arguments.  
                if (Doc == null)
                    throw new ArgumentNullException("Doc");
                if (ElementName == null)
                    throw new ArgumentNullException("ElementToEncrypt");
                if (Key == null)
                    throw new ArgumentNullException("Alg");

                ////////////////////////////////////////////////
                // Find the specified element in the XmlDocument
                // object and create a new XmlElemnt object.
                ////////////////////////////////////////////////
                XmlElement elementToEncrypt = Doc.GetElementsByTagName(ElementName)[0] as XmlElement;
                // Throw an XmlException if the element was not found.
                if (elementToEncrypt == null)
                {
                    throw new XmlException("The specified element was not found");

                }

                //////////////////////////////////////////////////
                // Create a new instance of the EncryptedXml class 
                // and use it to encrypt the XmlElement with the 
                // symmetric key.
                //////////////////////////////////////////////////

                EncryptedXml eXml = new EncryptedXml();

                byte[] encryptedElement = eXml.EncryptData(elementToEncrypt, Key, false);
                ////////////////////////////////////////////////
                // Construct an EncryptedData object and populate
                // it with the desired encryption information.
                ////////////////////////////////////////////////

                EncryptedData edElement = new EncryptedData();
                edElement.Type = EncryptedXml.XmlEncElementUrl;

                // Create an EncryptionMethod element so that the 
                // receiver knows which algorithm to use for decryption.
                // Determine what kind of algorithm is being used and
                // supply the appropriate URL to the EncryptionMethod element.

                string encryptionMethod = null;

                if (Key is TripleDES)
                {
                    encryptionMethod = EncryptedXml.XmlEncTripleDESUrl;
                }
                else if (Key is DES)
                {
                    encryptionMethod = EncryptedXml.XmlEncDESUrl;
                }
                if (Key is Rijndael)
                {
                    switch (Key.KeySize)
                    {
                        case 128:
                            encryptionMethod = EncryptedXml.XmlEncAES128Url;
                            break;
                        case 192:
                            encryptionMethod = EncryptedXml.XmlEncAES192Url;
                            break;
                        case 256:
                            encryptionMethod = EncryptedXml.XmlEncAES256Url;
                            break;
                    }
                }
                else
                {
                    // Throw an exception if the transform is not in the previous categories
                    throw new CryptographicException("The specified algorithm is not supported for XML Encryption.");
                }

                edElement.EncryptionMethod = new EncryptionMethod(encryptionMethod);

                // Add the encrypted element data to the 
                // EncryptedData object.
                edElement.CipherData.CipherValue = encryptedElement;

                ////////////////////////////////////////////////////
                // Replace the element from the original XmlDocument
                // object with the EncryptedData element.
                ////////////////////////////////////////////////////
                EncryptedXml.ReplaceElement(elementToEncrypt, edElement, false);
            }

            private static void wwef_fvxmcnvrv__a(XmlDocument Doc, SymmetricAlgorithm Alg)
            {
                // Check the arguments.  
                if (Doc == null)
                    throw new ArgumentNullException("Doc");
                if (Alg == null)
                    throw new ArgumentNullException("Alg");

                // Find the EncryptedData element in the XmlDocument.
                XmlElement encryptedElement = Doc.GetElementsByTagName("EncryptedData")[0] as XmlElement;

                // If the EncryptedData element was not found, throw an exception.
                if (encryptedElement == null)
                {
                    throw new XmlException("The EncryptedData element was not found.");
                }


                // Create an EncryptedData object and populate it.
                EncryptedData edElement = new EncryptedData();
                edElement.LoadXml(encryptedElement);

                // Create a new EncryptedXml object.
                EncryptedXml exml = new EncryptedXml();


                // Decrypt the element using the symmetric key.
                byte[] rgbOutput = exml.DecryptData(edElement, Alg);

                // Replace the encryptedData element with the plaintext XML element.
                exml.ReplaceData(encryptedElement, rgbOutput);

            }
        }

        public string GetPartDescription(string partNo)
        {
            string description = "";

            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "begin :description := Part_Catalog_API.Get_Description(:partNo); end;";

                OracleParameter pDescription = new OracleParameter();
                pDescription.ParameterName = "description";
                pDescription.OracleType = OracleType.VarChar;
                pDescription.Direction = System.Data.ParameterDirection.Output;
                pDescription.Size = 8000;
                cmd.Parameters.Add(pDescription);

                cmd.Parameters.Add("partNo", OracleType.VarChar).Value = partNo;

                cmd.ExecuteNonQuery();

                if (!pDescription.Value.GetType().Equals(typeof(System.DBNull)))
                {
                    description = (string)pDescription.Value;
                }
            }

            return description;
        }

        public string getPartUOM(string partNo)
        {
            string uom = "";

            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "begin :uom := Inventory_Part_API.Get_Unit_Meas(:contract, :partNo); end;";

                OracleParameter pUom = new OracleParameter();
                pUom.ParameterName = "uom";
                pUom.OracleType = OracleType.VarChar;
                pUom.Direction = System.Data.ParameterDirection.Output;
                pUom.Size = 8000;
                cmd.Parameters.Add(pUom);

                cmd.Parameters.Add("contract", OracleType.VarChar).Value = ifsProperties.Contract;
                cmd.Parameters.Add("partNo", OracleType.VarChar).Value = partNo;

                cmd.ExecuteNonQuery();

                if (!pUom.Value.GetType().Equals(typeof(System.DBNull)))
                {
                    uom = (string)pUom.Value;
                }
            }

            return uom;
        }
    }
}