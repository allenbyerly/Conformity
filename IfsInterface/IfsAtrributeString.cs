using System;
using System.Collections.Generic;
using System.Data.OracleClient;
using System.Linq;
using System.Text;

namespace IfsInterface
{
    public class IfsAtrributeString
    {
        public String Value { get; set; }

        public void AddToAttribute(String attributeName, String attributeValue)
        {
            Value += attributeName + "\u001f" + attributeValue + "\u001e";
        }
        public void ClearAttribute()
        {
            Value = "";
        }

        public String getAttributeValue(String name)
        {
            String message = "\u001e" + Value;

            int nameBegin = message.IndexOf("\u001e" + name + "\u001f");
            int nameEnd = message.IndexOf("\u001f", nameBegin);

            int valueBegin = nameEnd + 1;
            int valueEnd = message.IndexOf("\u001e", valueBegin);
            int valueLength = valueEnd - valueBegin;

            return message.Substring(valueBegin, valueLength);
        }

    }
}
