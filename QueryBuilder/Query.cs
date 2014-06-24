using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.OracleClient;

namespace QueryBuilder
{
    public class Query
    {
 //       IEnumerable<OracleDataReader> enumerator;

        private OracleDataReader Results { get; set; }
        private OracleQueryBuilder QueryBuilder { get; set; }
        private OracleJoinBuilder Join { get; set; }

       // private bool resultsInput = false;

        public Query(OracleDataReader reader)
        {
     //       resultsInput = true;
            Results = reader;
        }

        public Query(OracleQueryBuilder query)
        {
     //       resultsInput = false;
            QueryBuilder = query;
        }

        public Query(OracleJoinBuilder join)
        {
  //          resultsInput = false;

            Join = join;
        }

        private Boolean readResults()
        {
            return Results.Read();
        }

        private string GetResult(int row, int column, TypeCode returnType)
        {
            bool read = true;

            if (Results.Depth < 1)
            {
               read = Results.Read();
            }
            if (Results.IsClosed)
            {
                read = false;
            }

            if (!read)
            {
                throw new Exception("Ilvaid Record");
            }

            string value;

            if (!Results.IsDBNull(column))
            {
                value = Results.GetDecimal(column).ToString();
            }
            else
            {
                value = "";
            }

            return value;
        }
    }

}
