using System;
using System.Data.OracleClient;
using System.Xml;

namespace IfsInterface
{
    public class IfsPage
    {
        public static string getPageMessage(string identity, OracleConnection connection)
        {
            string result = null;
            /*
            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "select page, log from esi_scanworks_page_tab where sent = 'N' and identity = :identity order by log";
                cmd.Parameters.Add("identity", OracleType.VarChar).Value = identity;

                using (OracleDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        decimal log;
                        result = reader.GetString(0);
                        log = reader.GetDecimal(1);

                        using (OracleCommand update = connection.CreateCommand())
                        {
                            update.CommandText = "update esi_scanworks_page_tab set sent = 'Y' where log = :log";
                            update.Parameters.Add("log", OracleType.Number).Value = log;
                            update.ExecuteNonQuery();
                        }
                    }
                }
            }
            */
            return result;
        }

        public static void AddPageElement(XmlElement statusElement, IfsProperties ifsProperties, OracleConnection connection)
        {

            XmlElement pageElement = statusElement.OwnerDocument.CreateElement("PAGE");
            statusElement.AppendChild(pageElement);

            string message = getPageMessage(ifsProperties.Username, connection);

            if (null != message)
            {
                pageElement.AppendChild(statusElement.OwnerDocument.CreateTextNode(message));
            }
        }
    }
}
