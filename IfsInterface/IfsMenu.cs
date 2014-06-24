using System;
using System.Data.OracleClient;
using System.Xml;
using QueryBuilder;

namespace IfsInterface
{
    public class IfsMenu
    {
        public static XmlDocument Menu(OracleConnection connection, string methodName, XmlNode apiNode, IfsProperties ifsProperties)
        {
            XmlDocument result;

            switch (methodName)
            {
                case "Get_Menu":
                case "Get_Dynamic_Menu":
                    result = GetMenu(connection, apiNode, ifsProperties);
                    break;

                default:
                    throw new Exception(string.Format("{0}:  Unknown method: {1}", System.Reflection.MethodBase.GetCurrentMethod().DeclaringType.Name, methodName));
            }

            return result;
        }

        private static XmlDocument GetMenu(OracleConnection connection, XmlNode apiNode, IfsProperties ifsProperties)
        {
            XmlNodeList parameters = apiNode.ChildNodes;

            XmlNode menuDoc = null;
            string menuName = ifsProperties.DefaultMenu;

            for (int i = 0; (i < parameters.Count); i += 1)
            {
                for (int j = 0; (j < parameters[i].Attributes.Count); j += 1)
                {
                    XmlAttribute attribute = parameters[i].Attributes[j];
                    switch (attribute.Value)
                    {
                        case "menu_doc_":
                            menuDoc = parameters[i];
                            break;

                        case "menu_name_":
                            menuName = ((XmlText)parameters[i].FirstChild).Value;
                            ifsProperties.CurrentMenu = menuName;
                            break;
                    }
                }
            }



            OracleQueryBuilder menuQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

           // menuQuery.AddSelect("PROMPT", "", "", "", "");
            menuQuery.AddFrom("ESI_SW_MENU_SYSTEM");
            menuQuery.AddSelect("PROMPT", "", "", "", "");
            menuQuery.AddSelect("TRANSACTION", "", "", "", "");
 //           menuQuery.AddSelect("API", "", "", "", "");
            menuQuery.AddSelect("SUBMENU", "", "", "", "");
            menuQuery.AddSelect("ICON", "", "", "", "");
  //          menuQuery.AddFrom("ESI_SW_MENU_SYSTEM");
            menuQuery.AddWhere("CONTRACT", ifsProperties.DefaultContract, "=", "", false, "");
            menuQuery.AddWhere("MENU_NAME", menuName, "=", "", false, "");
            menuQuery.AddOrder("RANK", "", "");

/*
            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = "select prompt, transaction_name, submenu, icon from esi_scanworks_menus_tab where menu_name = :menuName order by rank";
                cmd.6t0.Add("menuName", OracleType.VarChar).Value = menuName;
            */

                bool noEscapeItem = true;

                using (OracleDataReader reader = menuQuery.Execute(connection))
                {
                    IfsMenuItem.MenuItemRecord menuItemRecord = new IfsMenuItem.MenuItemRecord();
                    
                    while (reader.Read())
                    {
                        menuItemRecord.Prompt = reader.GetString(0);
                        menuItemRecord.TransactionName = reader.GetString(1);
                        menuItemRecord.Api = reader.GetString(1);
                        menuItemRecord.SubMenu = reader.GetString(2);
                        menuItemRecord.Icon = reader.GetOracleLob(3);

                        XmlElement menuItem = IfsMenuItem.BuildElement(menuItemRecord, apiNode.OwnerDocument, connection);
                        
                        menuDoc.AppendChild(menuItem);

                        if (menuItemRecord.TransactionName.Equals("LOGOFF") || menuItemRecord.TransactionName.Equals("RETURN"))
                        {
                            noEscapeItem = false;
                        }
                    }
                }

                if (noEscapeItem)
                {
                    OracleQueryBuilder iconQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

                    // menuQuery.AddSelect("PROMPT", "", "", "", "");
                    iconQuery.AddFrom("ESI_SW_ICONS");
                    iconQuery.AddSelect("ICON_FILE", "", "", "", "");
                    iconQuery.AddWhere("ICON", "ShutDown", "=", "", false, "");

                    using (OracleDataReader reader = iconQuery.Execute(connection))
                    {
                        IfsMenuItem.MenuItemRecord menuItemRecord = new IfsMenuItem.MenuItemRecord();

                        while (reader.Read())
                        {

                            menuItemRecord.Prompt = "Logoff";
                            menuItemRecord.TransactionName = "LOGOFF";
                            menuItemRecord.Api = "LOGOFF";
                            menuItemRecord.SubMenu = "*";
                            menuItemRecord.Icon = reader.GetOracleLob(0);

                            XmlElement menuItem = IfsMenuItem.BuildElement(menuItemRecord, apiNode.OwnerDocument, connection);

                            menuDoc.AppendChild(menuItem);

                         
                        }
                    }

/*
                    iconQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

                    iconQuery.AddFrom("ESI_SW_ICONS");
                    iconQuery.AddSelect("ICON", "", "", "", "");
                    iconQuery.AddWhere("ICON_NAME", "ShutDown", "=", "", false, "");

                    using (OracleDataReader reader = menuQuery.Execute(connection))
                    {
                        IfsMenuItem.MenuItemRecord menuItemRecord = new IfsMenuItem.MenuItemRecord();

                        while (reader.Read())
                        {

                            menuItemRecord.Prompt = "Logoff";
                            menuItemRecord.TransactionName = "LOGOFF";
                            menuItemRecord.Api = "Logoff";
                            menuItemRecord.SubMenu = "";
                            menuItemRecord.Icon = reader.GetOracleLob(3);

                            XmlElement menuItem = IfsMenuItem.BuildElement(menuItemRecord, apiNode.OwnerDocument, connection);

                            menuDoc.AppendChild(menuItem);

                        }
                    }*/
                }
          //  }
            return apiNode.OwnerDocument;
        }
    }
}
