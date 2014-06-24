using System;
using System.Data.OracleClient;
using System.Collections.Generic;
using System.Xml;
using QueryBuilder;

namespace IfsInterface
{
    public class IfsLicense
    {
        public static XmlDocument GetTransactions(IfsTransactions ifsTransactions, XmlNode apiNode)
        {
            XmlDocument doc = apiNode.OwnerDocument;

            XmlElement transactionsRoot = doc.CreateElement("Transactions");

            foreach (KeyValuePair<string, IfsTransactions.Transaction> ifsTransaction in ifsTransactions.Transactions)
            {
                XmlText value;

                XmlElement transactionElement = doc.CreateElement("Transaction");

                XmlElement transactionNameElement = doc.CreateElement("TRANSACTION_NAME");
                value = doc.CreateTextNode(ifsTransaction.Value.Id);
                transactionNameElement.AppendChild(value);
                transactionElement.AppendChild(transactionNameElement);

                XmlElement apiNameElement = doc.CreateElement("API_NAME");
                value = doc.CreateTextNode(ifsTransaction.Value.Id);
                apiNameElement.AppendChild(value);
                transactionElement.AppendChild(apiNameElement);

                transactionsRoot.AppendChild(transactionElement);
            }

            XmlNodeList parameters = apiNode.ChildNodes;
            bool found = false;

            for (int i = 0; (i < parameters.Count) && !found; i += 1)
            {
                for (int j = 0; (j < parameters[i].Attributes.Count) && !found; j += 1)
                {
                    XmlAttribute attribute = parameters[i].Attributes[j];
                    if (attribute.Value.Equals("transactions_"))
                    {
                        found = true;

                        string result = transactionsRoot.OuterXml;

                        doc = apiNode.OwnerDocument;
                        XmlText resultNode = doc.CreateTextNode(result);
                        parameters[i].AppendChild(resultNode);
                    }
                }
            }
            return doc;
        }

        public static XmlDocument Transactions(OracleConnection connection, string methodName, XmlNode apiNode)
        {
            XmlDocument result;

            switch (methodName)
            {
                case "Get_Transactions":
                    result = GetTransactions(connection, apiNode);
                    break;

                default:
                    throw new Exception(string.Format("{0}:  Unknown method: {1}", System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.Name, methodName));
            }

            return result;
        }

        private static XmlDocument GetTransactions(OracleConnection connection, XmlNode apiNode)
        {
            XmlDocument doc = apiNode.OwnerDocument;

            XmlElement transactionsRoot = doc.CreateElement("Transactions");

            OracleQueryBuilder transactionQuery = new OracleQueryBuilder("IFSAPP");

            transactionQuery.AddSelect("TRANSACTION", "", "", "", "");
            transactionQuery.AddSelect("API", "", "", "", "");
            transactionQuery.AddFrom("ESI_SW_TRANSACTIONS");


            using (OracleDataReader reader = transactionQuery.Execute(connection))
            {
                while (reader.Read())
                {
                    XmlText value;

                    XmlElement transactionElement = doc.CreateElement("Transaction");

                    XmlElement transactionNameElement = doc.CreateElement("TRANSACTION_NAME");
                    value = doc.CreateTextNode(reader.GetString(0));
                    transactionNameElement.AppendChild(value);
                    transactionElement.AppendChild(transactionNameElement);

                    XmlElement apiNameElement = doc.CreateElement("API_NAME");
                    value = doc.CreateTextNode(reader.GetString(1));
                    apiNameElement.AppendChild(value);
                    transactionElement.AppendChild(apiNameElement);

                    transactionsRoot.AppendChild(transactionElement);
                }
            }

            XmlNodeList parameters = apiNode.ChildNodes;
            bool found = false;

            for (int i = 0; (i < parameters.Count) && !found; i += 1)
            {
                for (int j = 0; (j < parameters[i].Attributes.Count) && !found; j += 1)
                {
                    XmlAttribute attribute = parameters[i].Attributes[j];
                    if (attribute.Value.Equals("transactions_"))
                    {
                        found = true;

                        string result = transactionsRoot.OuterXml;

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
