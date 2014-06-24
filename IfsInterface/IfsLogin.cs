using System;
using System.Text;
using System.Data.OracleClient;
using System.Xml;
using System.Collections;
using System.IO;
using QueryBuilder;

namespace IfsInterface
{
    public class IfsLogin
    {
        private OracleConnection connection;
        private IfsInterface.IfsProperties ifsProperties;
        public  IfsInterface.IfsProperties IfsProperties { get { return ifsProperties; } }

        //        private string menu;
        //        public string Menu { get { return menu; } }
        //        private string language;
        //        public string Language { get { return language; } }
        //        private string site;
        //        public string Site { get { return site; } }

        public IfsLogin(OracleConnection connection, string appowner)
        {
            this.connection = connection;
            ifsProperties = new IfsInterface.IfsProperties();
            this.ifsProperties.AppOwner = appowner;
        }

        public XmlDocument Login(string methodName, XmlNode apiNode, ArrayList transactions)
        {
            XmlDocument result;
    
            ifsProperties.Transactions = transactions;

            switch (methodName)
            {
                case "Logon":
                    result = Login(apiNode);
                    break;

                default:
                    throw new Exception(string.Format("{0}:  Unknown method: {1}", System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.Name, methodName));
            }

            return result;
        }

        private XmlDocument Login(XmlNode apiNode)
        {
            XmlDocument result = new XmlDocument();
            XmlNodeList parameters = apiNode.ChildNodes;

            string userName = "";
            string password = "";

            foreach (XmlNode parameter in parameters)
            {
                if (parameter.Attributes.Count > 0)
                {
                    XmlAttribute parameterName = parameter.Attributes[0];
                    switch (parameterName.Value)
                    {
                        case "username_":
                            userName = ((XmlText)parameter.FirstChild).Value;
                            break;

                        case "password_":
                            password = ((XmlText)parameter.FirstChild).Value;
                            break;
                    }
                }
            }           

         /*   using (OracleCommand cmd = connection.CreateCommand())
            {

                cmd.CommandText = "select default_site, menu_name, printer_no from esi_scanworks_users_tab where identity = :identity and password = :password";
                cmd.Parameters.Add("identity", OracleType.VarChar).Value = userName;
                cmd.Parameters.Add("password", OracleType.VarChar).Value = password;
            */

            OracleQueryBuilder userQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

            userQuery.AddFrom("ESI_SW_USERS");
            userQuery.AddSelect("CONTRACT", "CONTRACT", "DISTINCT", "", "");
            userQuery.AddSelect("MENU_NAME", "MENU_NAME", "", "", "");
            userQuery.AddWhere("IDENTITY", userName, "=", "", false, "");
            userQuery.AddWhere("PASSWORD", password, "=", "", false, "");


                using (OracleDataReader reader = userQuery.Execute(connection))
                {
                    if (reader.Read())
                    {
                        ifsProperties.Username = userName;
                        ifsProperties.DefaultContract = reader.GetString(0);
                        ifsProperties.Contract = ifsProperties.DefaultContract;
                        ifsProperties.DefaultMenu = reader.GetString(1);
                        ifsProperties.CurrentMenu = reader.GetString(1);
                        ifsProperties.Printer = "";
                        /*
                        if (reader.IsDBNull(2))
                        {
                            ifsProperties.Printer = "";
                        }
                        else
                        {
                            ifsProperties.Printer = reader.GetString(2);
                        }
                       
                        IfsLogin.PackageLogon(connection, userName, password);
                        */
                        createLog("Logon User", "A", userName);
                    }
                    else
                    {
                        createLog("Invalid Logon", "E", "");
                        throw new Exception("Invalid Logon");
                    }
                }
   //         }

            // If sucessful, the format of the response does not matter.
            XmlNode status = result.CreateElement("Success");
            result.AppendChild(status);
            return result;
        }

        private void createLog(string msg, string status, string userId)
        {
   /*         if (ESI_Scanworks_Log.Scanworks_log.enable_log(ifsProperties))
            {
                ESI_Scanworks_Log.Transaction_Log_AX.TransName = GetType().ToString().Substring(1 + GetType().ToString().LastIndexOf('.'));
                ESI_Scanworks_Log.Transaction_Log_AX.User = userId;
                ESI_Scanworks_Log.Transaction_Log_AX.Company = "";
                ESI_Scanworks_Log.Transaction_Log_AX.Site = "";
                ESI_Scanworks_Log.Transaction_Log_AX.Warehouse = "";
                ESI_Scanworks_Log.Transaction_Log_AX.Quantity = "";
                ESI_Scanworks_Log.Transaction_Log_AX.Order = "";
                ESI_Scanworks_Log.Transaction_Log_AX.Item = "";
                ESI_Scanworks_Log.Transaction_Log_AX.LogDateTime = DateTime.Now.ToString();
                ESI_Scanworks_Log.Transaction_Log_AX.Status = status;
                ESI_Scanworks_Log.Transaction_Log_AX.Error = msg;
                ESI_Scanworks_Log.Transaction_Log_AX.User_1 = "";
                ESI_Scanworks_Log.Transaction_Log_AX.User_2 = "";
                ESI_Scanworks_Log.Transaction_Log_AX.User_3 = "";

                //                ESI_Scanworks_Log.Transaction_Log_AX.LogTransaction(axapta);
            }*/
        }
        static private void addParameter(XmlElement apiNode, string name, string value)
        {
            XmlElement parameter = apiNode.OwnerDocument.CreateElement("parameter");
            XmlAttribute attribute = apiNode.OwnerDocument.CreateAttribute("name");
            attribute.Value = name;
            parameter.Attributes.Append(attribute);

            if (value.Length > 0)
            {
                XmlText textNode = apiNode.OwnerDocument.CreateTextNode(value);
                parameter.AppendChild(textNode);
            }

            apiNode.AppendChild(parameter);
        }

        static public void PackageLogon(OracleConnection connection, string username, string password)
        {
            XmlDocument logonDoc = new XmlDocument();

            XmlElement scanworks = logonDoc.CreateElement("Scanworks");
            logonDoc.AppendChild(scanworks);

            XmlElement erp = logonDoc.CreateElement("ERP");
            scanworks.AppendChild(erp);
            XmlText ifs = logonDoc.CreateTextNode("IFS");
            erp.AppendChild(ifs);
            XmlElement api = logonDoc.CreateElement("API");
            scanworks.AppendChild(api);
            XmlAttribute name = logonDoc.CreateAttribute("Name");
            name.Value = "esi_scanworks_logon.Logon";
            api.Attributes.Append(name);

            addParameter(api, "status", "");
            addParameter(api, "username_", username);
            addParameter(api, "password_", password);

            XmlElement method = logonDoc.CreateElement("Method");
            api.AppendChild(method);
            XmlText methodName = logonDoc.CreateTextNode("Logon");
            method.AppendChild(methodName);


            StringWriter sw = new StringWriter();
            logonDoc.Save(sw);
            string xmlString = sw.ToString();



            StringBuilder sql = new StringBuilder("begin :result := ").Append("esi_scanworks_logon").Append(".ApiCall(:parameters_); end; ");

            OracleCommand cmd = new OracleCommand();

            OracleParameter returnParameter = new OracleParameter();

            returnParameter.ParameterName = "result";
            returnParameter.OracleType = OracleType.Clob;
            returnParameter.Direction = System.Data.ParameterDirection.Output;
            //                returnParameter.Size = 32000;
            cmd.Parameters.Add(returnParameter);

            OracleParameter oraParameter = new OracleParameter();
            oraParameter.ParameterName = "parameters_";
            oraParameter.Value = xmlString;
            oraParameter.OracleType = OracleType.LongVarChar;
            oraParameter.Direction = System.Data.ParameterDirection.Input;
            oraParameter.Size = 32000;

            cmd.Parameters.Add(oraParameter);

            cmd.CommandText = sql.ToString();
            cmd.Connection = connection;

            cmd.ExecuteNonQuery();

            string result = "";

            if (returnParameter.Value.GetType().ToString().Equals("System.Data.OracleClient.OracleLob"))
            {
                OracleLob lob = (OracleLob)returnParameter.Value;
                result = (string)lob.Value;
            }
            else
            {
                result = (string)returnParameter.Value;
            }

            logonDoc = new XmlDocument();
            logonDoc.LoadXml(result);
        }

    }
}

