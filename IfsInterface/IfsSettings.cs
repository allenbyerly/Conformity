using System;
using System.Xml;
using System.Data.OracleClient;

namespace IfsInterface
{
    public class IfsSettings
    {
        public static XmlDocument Settings(OracleConnection connection, string methodName, XmlNode apiNode)
        {
            XmlDocument result;

            switch (methodName)
            {
                case "Get_Settings":
                    result = GetProperties(connection, apiNode);
                    break;

                default:
                    throw new Exception(string.Format("{0}:  Unknown method: {1}", System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.Name, methodName));
            }

            return result;
        }

        private static XmlDocument GetProperties(OracleConnection connection, XmlNode apiNode)
        {
            XmlNodeList parameters = apiNode.ChildNodes;

            string deviceId = null;

            for (int i = 0; (i < parameters.Count) && (deviceId == null); i += 1)
            {
                for (int j = 0; (j < parameters[i].Attributes.Count) && (deviceId == null); j += 1)
                {
                    XmlAttribute attribute = parameters[i].Attributes[j];
                    if (attribute.Value.Equals("device_id_"))
                    {
                        deviceId = ((XmlText)parameters[i].FirstChild).Value;
                    }
                }
            }

            XmlDocument doc = new XmlDocument();

            XmlElement root = doc.CreateElement("Settings");
            doc.AppendChild(root);
            /*
            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "select setting, value from esi_scanworks_settings_tab where device_id = :deviceId";
                cmd.Parameters.Add("deviceId", OracleType.VarChar).Value = deviceId;

                using (OracleDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        XmlElement setting = doc.CreateElement("Setting");
                        XmlAttribute attribute = doc.CreateAttribute("Setting");
                        attribute.Value = reader.GetString(0);

                        setting.Attributes.Append(attribute);

                        XmlElement valueElement = doc.CreateElement("Value");
                        setting.AppendChild(valueElement);

                        XmlText value = doc.CreateTextNode(reader.GetString(0));
                        valueElement.AppendChild(value);

                        root.AppendChild(setting);
                    }
                }
            }
            */
            bool found = false;

            for (int i = 0; (i < parameters.Count) && !found; i += 1)
            {
                for (int j = 0; (j < parameters[i].Attributes.Count) && !found; j += 1)
                {
                    XmlAttribute attribute = parameters[i].Attributes[j];
                    if (attribute.Value.Equals("settings_"))
                    {
                        found = true;

                        string result = doc.InnerXml;

                        doc = apiNode.OwnerDocument;
                        XmlText resultNode = doc.CreateTextNode(result);
                        parameters[i].AppendChild(resultNode);
                    }
                }
            }

            return doc;

        }

    }
}
