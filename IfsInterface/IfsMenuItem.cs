using System;
using System.Data.OracleClient;
using System.Xml;
using QueryBuilder;


namespace IfsInterface
{
    public class IfsMenuItem
    {
        public class MenuItemRecord
        {
            public string Prompt { get; set; }
            public string TransactionName { get; set; }
            public string Api { get; set; }
            public string SubMenu { get; set; }
            public string Printer { get; set; }
            public OracleLob Icon { get; set; }
        }

        public static string Get_API_Name(string transactionName, OracleConnection connection)
        {
            string result = "";

     /*       OracleQueryBuilder transactionQuery = new OracleQueryBuilder(ifsifsProperties.AppOwner);
            transactionQuery.AddFrom("ESI_SW_TRANSACTION_SYSTEM");
            transactionQuery.AddSelect("PACKAGE", "", "", "", "");
            transactionQuery.AddSelect("API", "", "", "", "");
            transactionQuery.AddSelect("VERSION", "", "", "", "");
            transactionQuery.AddWhere("TRANSACTION", transactionName, "=", "", false, "");*/
/*
            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "select api_name from esi_scanworks_transactions_tab where transaction_name = :transactionName";
                cmd.Parameters.Add("transactionName", OracleType.VarChar).Value = transactionName;
            */
           /*     using (OracleDataReader reader = transactionQuery.Execute())
                {
                    if (reader.Read())
                    {
                        result = reader.GetString(0);
                    }
                    else
                    {
                        throw new Exception(string.Format("Unknown transaction: {0}", transactionName));
                    }
                }
  //          }*/
            return result;
        }

        public static XmlElement BuildElement(MenuItemRecord menuItemRecord, XmlDocument doc, OracleConnection connection)
        {
            XmlElement result = doc.CreateElement("item");

            XmlElement prompt = doc.CreateElement("PROMPT");
            prompt.AppendChild(doc.CreateTextNode(menuItemRecord.Prompt));
            result.AppendChild(prompt);

            XmlElement apiName = doc.CreateElement("API_NAME");
            apiName.AppendChild(doc.CreateTextNode(menuItemRecord.Api));
            result.AppendChild(apiName);

            XmlElement submenu = doc.CreateElement("SUBMENU");
            submenu.AppendChild(doc.CreateTextNode(menuItemRecord.SubMenu));
            result.AppendChild(submenu);


            System.IO.MemoryStream memory;

            try
            {

                memory = new System.IO.MemoryStream((byte[])menuItemRecord.Icon.Value);
              /*  OracleQueryBuilder transactionQuery = new QueryBuilder(ifsProperties.AppOwner);
                transactionQuery.AddFrom("ESI_SW_TRANSACTION_SYSTEM");
                transactionQuery.AddSelect("PACKAGE", "", "", "", "");
                transactionQuery.AddSelect("API", "", "", "", "");
                transactionQuery.AddSelect("VERSION", "", "", "", "");
                transactionQuery.AddWhere("TRANSACTION", transactionName, "=", "", false, "");

                using (OracleCommand cmd = connection.CreateCommand())
                {
                    cmd.CommandText = "select bfile_loc from esi_scanworks_icons where name = :iconName";
                    cmd.Parameters.Add("iconName", OracleType.VarChar).Value = iconName;

                    using (OracleDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {ORA
                            OracleBFile bFile = reader.GetOracleBFile(0);
                            memory = new System.IO.MemoryStream((byte[])bFile.Value);
                            bFile.Close();
                        }
                        else
                        {
                            throw new Exception("");
                        }
                    }
                }*/
            }
            catch (Exception)
            {
                System.Drawing.Icon defaultIcon = Icons.Default;
                memory = new System.IO.MemoryStream();
                defaultIcon.Save(memory);
            }

            long arrayLength = (long)((4.0d / 3.0d) * memory.Length);

            // If array length is not divisible by 4, go up to the next
            // multiple of 4.
            if (arrayLength % 4 != 0)
            {
                arrayLength += 4 - arrayLength % 4;
            }

            char[] encodedBuffer = new char[arrayLength];

            System.Convert.ToBase64CharArray(memory.ToArray(), 0, (int)memory.Length, encodedBuffer, 0);

            XmlElement icon = doc.CreateElement("ICON");
            icon.AppendChild(doc.CreateTextNode(new string(encodedBuffer)));
            result.AppendChild(icon);

            return result;
        }
    }
}
