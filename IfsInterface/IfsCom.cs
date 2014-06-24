using System;
using System.Collections.Generic;
using System.Data.OracleClient;
using System.Linq;
using System.Text;

namespace IfsInterface
{
    public class IfsCom
    {
        
        public OracleParameter Input{ get; set; }
        public OracleParameter Output { get; set; }
        public OracleParameter InputOutput { get; set; }
        public OracleParameter ReturnValue { get; set; }

        public String Attributes { get; set; }

        public IfsCom()
        {
            Initialize();
        }

        public void Initialize()
        {
            Attributes = "";

            Input = new OracleParameter();

            Input.ParameterName = "InAttribute";
            Input.OracleType = OracleType.VarChar;
            Input.Direction = System.Data.ParameterDirection.Input;
            Input.Size = 2000;

            Output = new OracleParameter();

            Output.ParameterName = "OutAttribute";
            Output.OracleType = OracleType.VarChar;
            Output.Direction = System.Data.ParameterDirection.Output;
            Output.Size = 2000;

            InputOutput = new OracleParameter();

            InputOutput.ParameterName = "DualAttribute";
            InputOutput.OracleType = OracleType.VarChar;
            InputOutput.Direction = System.Data.ParameterDirection.InputOutput;
            InputOutput.Size = 20000;

            ReturnValue = new OracleParameter();

            ReturnValue.ParameterName = "ReturnAttribute";
            ReturnValue.OracleType = OracleType.VarChar;
            ReturnValue.Direction = System.Data.ParameterDirection.ReturnValue;
            ReturnValue.Size = 20000;

        }

        public void AddAttribute(String attributeName, String attributeValue)
        {
            Attributes += attributeName + "\u001f" + attributeValue + "\u001e";
        }

        public String getAttributeValue(String name)
        {
            try 
            {
                String message = "\u001e" + Attributes;

                int nameBegin = message.IndexOf("\u001e" + name + "\u001f");

                    if (!nameBegin.Equals(-1))
                    {
                        int nameEnd = message.IndexOf("\u001f", nameBegin);

                        int valueBegin = nameEnd + 1;
                        int valueEnd = message.IndexOf("\u001e", valueBegin);
                        int valueLength = valueEnd - valueBegin;

                        return message.Substring(valueBegin, valueLength);
                    }
                    else
                    {
                        return "";
                    }
            } 
            catch (Exception)
            {
                return "";
            }
        }

        public void ClearAttributes()
        {
            Attributes = "";
        }

        public void SetAttributesAsInput()
        {
            Input.Value = Attributes;
        }

        public void SetOutputAsAttribute()
        {
            Attributes = Output.Value.ToString();
        }

        


    }
}
