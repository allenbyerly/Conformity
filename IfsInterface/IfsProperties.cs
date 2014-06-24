using System;
using System.Collections;
using System.Collections.Generic;
using ScannerFunctions;

namespace IfsInterface
{
    public class IfsProperties
    {
        public string AppOwner { get; set; }
        public string Username { get; set; }
        public string Contract { get; set; }
        public string DefaultContract { get; set; }
        public string DefaultMenu { get; set; }
        public string CurrentMenu { get; set; }
        public string Printer { get; set; }
        public string Language { get; set; }
        public ArrayList Transactions { get; set; }
        public DialogMessageBox DialogMessageBox { get; set; }
        
        private Dictionary<string, string> dynamicProperties;

        public IfsProperties()
        {
            dynamicProperties = new Dictionary<string, string>();
        }

        public string GetDynamicProperty(string name)
        {
            string result;

            try
            {
                result = dynamicProperties[name];
            }
            catch (Exception)
            {
                result = null;
            }

            return result;
        }

        public void SetDynamicProperty(string name, string value)
        {
            dynamicProperties.Add(name, value);
        }

        public string GetTransactionPrinter(string menuName)
        {
            if (Printer.Equals(""))
            {
                return "test";
            }
            else
            {
                return Printer;
            }
        }
    }
}
