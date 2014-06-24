using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using QueryBuilder;
//using System.Data.OracleClient;
//using System.Collections;

namespace QueryBuilder
{
    public class OracleJoinBuilder
    {
        public String Schema { get; set; }
        public String Statement { get; set; }

        private Dictionary<String, String> joinDictionary;
        private Dictionary<String, String> onDictionary;

        public OracleJoinBuilder(String schema)
        {
            Schema = schema;
            Statement = "";

            joinDictionary = new Dictionary<string, string>();
            onDictionary = new Dictionary<string, string>();

        }

        public void AddJoin(String fromTable, String joinTable, String type)
        {

            String key = fromTable + " " + type + " " + joinTable; ;
            String sql = fromTable + " " + type + " " + joinTable;

            
            if (fromTable.Equals("") || joinTable.Equals(""))
            {
                throw new Exception("Tables required");
            }
            else if (type.Equals(""))
            {
                throw new Exception("Type required");
            }
            else if (!joinDictionary.ContainsKey(key))
            {
                joinDictionary.Add(key, sql);
            }

           
        }

        public void AddOn(String selection, String operation, String fromTable, String joinTable, String type, bool isOr, String key)
        {
            int counter = 0;
            String sql = "";
            String join = fromTable + " " + type + " " + joinTable;
            String or = "";

            if (isOr && onDictionary.Count > 0)
            {
                IDictionaryEnumerator enumerator = onDictionary.GetEnumerator();

                enumerator.Reset();

                while (enumerator.MoveNext())
                {
                    if (enumerator.Key.ToString().Contains(join))
                    {
                        or = "OR";
                        break;
                    }
                }
            }

            if (fromTable.Equals("") || joinTable.Equals(""))
            {
                throw new Exception("Tables Required");
            } 
            else if (type.Equals(""))
            {
                throw new Exception("Type Required");
            } 
            else if (joinDictionary.ContainsKey(join))
            {
                sql = or + " " + fromTable + "." + selection + " " + operation + " " + joinTable + "." + selection;
            }
            else 
            {
                throw new Exception("Join not set in Query");
            }

            if (selection.Equals(""))
            {
                throw new Exception("Invalid Selection");
            }
            else if (!key.Equals(""))
            {
                while (onDictionary.ContainsKey(key + counter))
                {
                    counter++;
                }

                onDictionary.Add(key + counter, sql);
            }
            else
            {
                while (onDictionary.ContainsKey(join + ":" + selection + counter))
                {
                    counter++;
                }

                onDictionary.Add(join + ":" + selection + counter, sql);
            }
        }

        public void RemoveJoin(String fromTable, String joinTable, String type)
        {

            String key = fromTable + " " + type + " " + joinTable;

            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(onDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!(fromTable.Equals("") || joinTable.Equals("") || type.Equals("")))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(key)) {
                        onDictionary.Remove(enumerator.Key.ToString());
                    }
                }

                joinDictionary.Remove(key);
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public void RemoveOn(String selection, String key)
        {
            Dictionary<String, String> tempDictionary = new Dictionary<String, String>(onDictionary);
            IDictionaryEnumerator enumerator = tempDictionary.GetEnumerator();

            enumerator.Reset();

            if (!key.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(key)) {
                        onDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else if (!selection.Equals(""))
            {
                while (enumerator.MoveNext()) {
                    if (enumerator.Key.ToString().Contains(selection)) {
                        onDictionary.Remove(enumerator.Key.ToString());
                    }
                }
            }
            else
            {
                throw new Exception("Missing Required Field");
            }

        }

        public String GetJoinClause()
        {
            IDictionaryEnumerator enumerator = joinDictionary.GetEnumerator();
            String joinClause = "";

            enumerator.Reset();

            if (enumerator.MoveNext())
            {

                joinClause = "FROM " + enumerator.Key.ToString() + Environment.NewLine; 
                joinClause = joinClause + GetOnClause(enumerator.Key.ToString());


                while (enumerator.MoveNext())
                {
                    joinClause = joinClause + Environment.NewLine + enumerator.Value + Environment.NewLine;
                    joinClause = joinClause + GetOnClause(enumerator.Key.ToString());

                }

                joinClause = joinClause + Environment.NewLine;

            }

            return joinClause;
        }

        public String GetOnClause(String join)
        {
            IDictionaryEnumerator enumerator = onDictionary.GetEnumerator();
            String onClause = "";

            enumerator.Reset();

            while (enumerator.MoveNext())
            {
                if (enumerator.Key.ToString().Contains(join))
                {
                    onClause = "ON " + enumerator.Value;

                    while (enumerator.MoveNext())
                    {
                        if (enumerator.Key.ToString().Contains(join))
                        {
                            if (enumerator.Value.ToString().StartsWith("OR ")) 
                            {
                                onClause = onClause + Environment.NewLine + enumerator.Value;
                            }
                            else 
                            {
                                onClause = onClause + Environment.NewLine + "AND " + enumerator.Value;
                            }
                        }
                    }
                }
            }

            return onClause;
        }

        public void Clear()
        {
            joinDictionary.Clear();
            onDictionary.Clear();
        }

        public void ClearJoin()
        {
            joinDictionary.Clear();
        }

        public void ClearOn()
        {
            onDictionary.Clear();
        }

        public String GetStatement()
        {
            String statement = "";

            statement = GetJoinClause();

            return statement;
        }
    }
}
