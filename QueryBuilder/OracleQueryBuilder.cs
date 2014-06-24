using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.OracleClient;
//using System.Data.OracleClient;
//using System.Collections;

namespace QueryBuilder
{
    public class OracleQueryBuilder
    {
        public String Schema { get; set; }
        public String Table { get; set; }
        public String Statement { get; set; }

        private Dictionary<String, String> selectDictionary;
        private Dictionary<String, String> fromDictionary;
        private Dictionary<String, String> whereDictionary;
        private Dictionary<String, String> groupDictionary;
        private Dictionary<String, String> orderDictionary;
        private Dictionary<String, String> havingDictionary;

        private OracleJoinBuilder joinBuilder;

        public OracleQueryBuilder(String schema)
        {
            Schema           = schema;
            Statement        = "SELECT * FROM DUAL";

            selectDictionary = new Dictionary<string, string>();
            fromDictionary   = new Dictionary<string, string>();
            whereDictionary  = new Dictionary<string, string>();
            groupDictionary  = new Dictionary<string, string>();
            orderDictionary  = new Dictionary<string, string>();
            havingDictionary = new Dictionary<string, string>();

            joinBuilder = new OracleJoinBuilder(Schema);

        }

        public void AddFrom(String table)
        {
            String sql = "";

            if (table.Equals(""))
            {
                throw new Exception("Invalid Table");
            }
            else if (fromDictionary.ContainsKey(table))
            {
                throw new Exception("Table Already Set");
            }
            else 
            {
                sql = table;

                fromDictionary.Add(table, table);

            }
        }

        public void AddSelect(String selection, String prompt, String function, String table, String key)
        {
            int counter = 0;
            String sql = "";

           

            if (table.Equals(""))
            {
                sql = function + "(" + selection + ") ";
            }
            else if (fromDictionary.ContainsKey(table))
            {
                sql = function + "(" + table + "." + selection + ") ";
            }
            else
            {
                throw new Exception("Table not set in Query");
            }

            if (!prompt.Equals(""))
            {
                sql = sql + "\"" + prompt + "\"";
            }

            if (selection.Equals("")) 
            {
                throw new Exception("Invalid Selection");
            } 
            else if (!key.Equals("")) 
            {
                while (selectDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                selectDictionary.Add(key + counter, sql);
            }
            else 
            {
                while (selectDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                selectDictionary.Add(selection + counter, sql);
            }           
        }

        public void AddStandardJoin(String selection, String operation, String table1, String table2, String key)
        {
            int counter = 0;
            String sql = "";

            if (table1.Equals("") || table2.Equals(""))
            {
                throw new Exception("Tables Required");
            }
            else if (fromDictionary.ContainsKey(table1) && fromDictionary.ContainsKey(table2))
            {
                sql = table1 + "." + selection + " " + operation + " " + table2 + "." + selection;
            }
            else
            {
                throw new Exception("Tables not set in Query");
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (whereDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                whereDictionary.Add(key + counter, sql);
            }
            else
            {
                while (whereDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                whereDictionary.Add(selection + counter, sql);
            }
        }

        public void AddAdvancedJoin(String selection, String operation, String table1, String table2, String type, bool isOr, String key)
        {

            if (table1.Equals("") || table2.Equals(""))
            {
                throw new Exception("Tables Required");
            }
            else if (type.Equals(""))
            {
                throw new Exception("Type of Join is Required");
            }
            else
            {
                joinBuilder.AddJoin(table1, table2, type);
                joinBuilder.AddOn(selection, operation, table1, table2, type, isOr, "");
            }
        }

        public void AddWhere(String selection, String value, String operation, String table, bool isOr, String key)
        {
            int counter = 0;
            String sql  = "";
            String or = "";

            if (isOr && whereDictionary.Count > 0)
            {
                or = "OR ";
            }

            if (table.Equals(""))
            {
 /*               if (operation.Equals(""))
                {
                    sql = or + selection + " " + value;
                }
                else
                {*/
                sql = or + selection;
           //     }
            }
            else if (fromDictionary.ContainsKey(table))
            {
             /*   if (operation.Equals(""))
                {
                    sql = or + table + "." + selection + " " + value;
                }
                else
                {*/
                sql = or + table + "." + selection;
              //  }
            }
            else
            {
                throw new Exception("Table not set in Query");
            }
            if (value.Equals("{Null}"))
            {
                sql = sql + " IS NULL";
            }
            else if (value.Equals("") && operation.Equals("="))
            {
                sql = sql + " IS NULL";
            }
            else if (value.Equals("") && operation.Equals("!="))
            {       
                sql = sql + " IS NOT NULL";
            }
            else if (!value.Equals(""))
            {
                sql = sql + " " + operation + " '" + value + "'";
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (whereDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                whereDictionary.Add(key + counter, sql);
            }
            else
            {
                while (whereDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                whereDictionary.Add(selection + counter, sql);
            }
        }

        public void AddGroup(String selection, String table, String key)
        {
            int counter = 0;
            String sql = "";

            if (table.Equals(""))
            {
                sql = "(" + selection + ")";
            }
            else if (fromDictionary.ContainsKey(table))
            {
                sql = "(" + table + "." + selection + ")";
            }
            else
            {
                throw new Exception("Table not set in Query");
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (groupDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                groupDictionary.Add(key + counter, sql);
            }
            else
            {
                while (groupDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                groupDictionary.Add(selection + counter, sql);
            }
        }

        public void AddHaving(String selection, String value, String operation, String table, bool isOr, String key)
        {
            int counter = 0;
            String sql  = "";
            String or = "";

            if (isOr && havingDictionary.Count > 0)
            {
                or = "OR";
            }

            if (table.Equals(""))
            {
                sql = or + " " + selection + " " + operation + " '" + value + "'";
            }
            else if (fromDictionary.ContainsKey(table))
            {
                sql = or + " " + table + "." + selection + " " + operation + " '" + value + "'";
            }
            else
            {
                throw new Exception("Table not set in Query");
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (havingDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                havingDictionary.Add(key + counter, sql);
            }
            else
            {
                while (havingDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                havingDictionary.Add(selection + counter, sql);
            }

        }

      

        public void AddOrder(String selection, String table, String key)
        {
            int counter = 0;
            String sql = "";

            if (table.Equals(""))
            {
                sql = "(" + selection + ")";
            }
            else if (fromDictionary.ContainsKey(table))
            {
                sql = "(" + table + "." + selection + ")";
            }
            else
            {
                throw new Exception("Table not set in Query");
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (orderDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                orderDictionary.Add(key + counter, sql);
            }
            else
            {
                while (orderDictionary.ContainsKey(selection + counter))
                {
                    counter++;
                }

                orderDictionary.Add(selection + counter, sql);
            }
        }

        public void RemoveFrom(String table)
        {
            if (!table.Equals(""))
            {
                fromDictionary.Remove(table);
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public void RemoveSelect(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(selectDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(key)) {
                        selectDictionary.Remove(enumerator.Key.ToString());
                    }
                }

            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        selectDictionary.Remove(enumerator.Key.ToString());
                    }
                }

            }
            else
            {
                throw new Exception("Missing Required Field");
            }

            selectDictionary = new Dictionary<String, String>(selectDictionary);

        }

        public void RemoveWhere(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(whereDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    string field = enumerator.Key.ToString().Remove(enumerator.Key.ToString().Length - 1, 1);
                    if (field.Equals(key)) {
                        whereDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        whereDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }
        }

        public void RemoveGroup(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(groupDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    string field = enumerator.Key.ToString().Remove(enumerator.Key.ToString().Length - 1, 1);
                    if (field.Equals(key))
                    {
                        groupDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        groupDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public void RemoveHaving(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(havingDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    string field = enumerator.Key.ToString().Remove(enumerator.Key.ToString().Length - 1, 1);
                    if (field.Equals(key))
                    {
                        havingDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        havingDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public void RemoveOrder(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(orderDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    string field = enumerator.Key.ToString().Remove(enumerator.Key.ToString().Length - 1, 1);
                    if (field.Equals(key))
                    {
                        orderDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        orderDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public void RemoveStandardJoin(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(whereDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext())
                {
                    string field = enumerator.Key.ToString().Remove(enumerator.Key.ToString().Length - 1, 1);
                    if (field.Equals(key))
                    {
                        whereDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext())
                {
                    if (enumerator.Key.ToString().Contains(selection))
                    {
                        whereDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }
        }

        public void RemoveAdvancedJoin(String table1, String table2, String type)
        {
            joinBuilder.RemoveJoin(table1, table2, type);
        }

        public void RemoveAdvancedOn(String selection, String key)
        {
            joinBuilder.RemoveOn(selection, key);
        }



        public String GetSelectClause()
        {
            IDictionaryEnumerator enumerator = selectDictionary.GetEnumerator();
            String selectClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {

                selectClause = "SELECT " +  enumerator.Value;

                while (enumerator.MoveNext())
                {
                    selectClause = selectClause + "," + Environment.NewLine + enumerator.Value;
                }

                selectClause = selectClause + Environment.NewLine;

            }

            return selectClause;
        }

        public String GetFromClause()
        {
            String fromClause = joinBuilder.GetStatement();

            if (fromClause.Equals("")) {
                IDictionaryEnumerator enumerator = fromDictionary.GetEnumerator();
                
                enumerator.Reset();

                if (enumerator.MoveNext())
                {

                    fromClause = "FROM " + enumerator.Value;

                    while (enumerator.MoveNext())
                    {
                        fromClause = fromClause + "," + Environment.NewLine + enumerator.Value;
                    }

                    fromClause = fromClause + Environment.NewLine;
                }
            } 

            return fromClause;
        }

        public String GetWhereClause()
        {
            IDictionaryEnumerator enumerator = whereDictionary.GetEnumerator();
            String whereClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {

                whereClause = "WHERE " + enumerator.Value;

                while (enumerator.MoveNext())
                {
                    if (enumerator.Value.ToString().StartsWith("OR ")) 
                    {
                        whereClause = whereClause + Environment.NewLine + enumerator.Value;
                    }
                    else
                    {
                        whereClause = whereClause + Environment.NewLine + "AND " + enumerator.Value;
                    }
                }
                whereClause = whereClause + Environment.NewLine;
            }

            return whereClause;
        }

        public String GetGroupClause()
        {
            IDictionaryEnumerator enumerator = groupDictionary.GetEnumerator();
            String groupClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {

                groupClause = "GROUP BY " + enumerator.Value;

                while (enumerator.MoveNext())
                {
                    groupClause = groupClause + "," + Environment.NewLine + enumerator.Value;
                }

                groupClause = groupClause + Environment.NewLine;
            }
            return groupClause;
        }

        public String GetHavingClause()
        {
            IDictionaryEnumerator enumerator = havingDictionary.GetEnumerator();
            String havingClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {
                havingClause = "HAVING " + enumerator.Value;

                while (enumerator.MoveNext())
                {
                    if (enumerator.Value.ToString().StartsWith("OR ")) 
                    {
                        havingClause = havingClause + Environment.NewLine + enumerator.Value;
                    }
                    else
                    {
                        havingClause = havingClause + Environment.NewLine + "AND " + enumerator.Value;
                    }
                }

                havingClause = havingClause + Environment.NewLine;
            }
            return havingClause;
        }

        public String GetOrderClause()
        {
            IDictionaryEnumerator enumerator = orderDictionary.GetEnumerator();
            String orderClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {
                orderClause = "ORDER BY " + enumerator.Value;

                while (enumerator.MoveNext())
                {
                    orderClause = orderClause + "," + Environment.NewLine + enumerator.Value;
                }

                orderClause = orderClause + Environment.NewLine;
            }
            return orderClause;
        }

        public void Clear()
        {
            selectDictionary.Clear();
            fromDictionary.Clear();
            whereDictionary.Clear();
            groupDictionary.Clear();
            orderDictionary.Clear();
            havingDictionary.Clear();
        }

        public void ClearSelect()
        {
            selectDictionary.Clear();
        }

        public void ClearFrom()
        {
            fromDictionary.Clear();
        }

        public void ClearWhere()
        {
            whereDictionary.Clear();
        }

        public void ClearGroup()
        {
            groupDictionary.Clear();
        }

        public void ClearOrder()
        {
            orderDictionary.Clear();
        }

        public void ClearHaving()
        {
            havingDictionary.Clear();
        }

        public String GetStatement()
        {
            String statement = "";

            statement = GetSelectClause() + 
                        GetFromClause() + 
                        GetWhereClause() + 
                        GetGroupClause() + 
                        GetHavingClause() + 
                        GetOrderClause();
            
            return statement;
        }

        public String Query(string selection, string prompt, string function, string table, string key, OracleConnection connection)
        {
            String result = "-";
            String sql;
            int count = 0;
            
            ClearSelect();
            AddSelect(selection, prompt, function, table, key);
            sql = GetStatement();

            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = sql.ToString();

                using (OracleDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        count++;
                        object columnValue = reader.GetOracleValue(0);
                        if (reader.IsDBNull(0))
                        {
                            result = "{Null}";
                        }
                        else if (columnValue is System.Data.OracleClient.OracleString)
                        {
                            result = reader.GetString(0);

                        }
                        else if (columnValue is System.Data.OracleClient.OracleNumber)
                        {
                            try
                            {

                                System.Data.OracleClient.OracleNumber number = new OracleNumber(reader.GetOracleNumber(0));

                                result = number.ToString();
                            }
                            catch
                            {
                                throw new Exception("Number value Not Supported");
                            }
                        }
                        else
                        {
                            throw new Exception(string.Format("Unexpected data type for column {0}", selection));
                        }

                    }
                }
            }

            if (count == 0)
            {
                result = "-";
            }
            else if (count > 1)
            {
                result = "";
            }

            return result;
        }

        public String Query(string selection, string prompt, string function, string table, string key, OracleConnection connection, bool allowNull)
        {
            String result = "-";
            String sql;
            int count = 0;

            ClearSelect();
            AddSelect(selection, prompt, function, table, key);
            sql = GetStatement();

            using (OracleCommand cmd = connection.CreateCommand())
            {
                cmd.CommandText = sql.ToString();

                using (OracleDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        count++;
                        object columnValue = reader.GetOracleValue(0);
                        if (reader.IsDBNull(0))
                        {
                            if (allowNull) { result = "{Null}"; }
                            else { result = ""; }
                        }
                        else if (columnValue is System.Data.OracleClient.OracleString)
                        {
                            result = reader.GetString(0);

                        }
                        else if (columnValue is System.Data.OracleClient.OracleNumber)
                        {
                            try
                            {

                                System.Data.OracleClient.OracleNumber number = new OracleNumber(reader.GetOracleNumber(0));

                                result = number.ToString();
                            }
                            catch
                            {
                                throw new Exception("Number value Not Supported");
                            }
                        }
                        else
                        {
                            throw new Exception(string.Format("Unexpected data type for column {0}", selection));
                        }

                    }
                }
            }

            if (count == 0)
            {
                result = "-";
            }
            else if (count > 1)
            {
                result = "";
            }

            return result;
        }


        public OracleDataReader Execute(OracleConnection connection)
        {
            String sql;

            sql = GetStatement();

            OracleCommand cmd = connection.CreateCommand();
      
            cmd.CommandText = sql.ToString();
           
            OracleDataReader reader = cmd.ExecuteReader();

            return reader;
        }
    }
}
