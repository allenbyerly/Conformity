using System;
using System.Collections.Generic;
using System.Linq;
using QueryBuilder;
using System.Data.OracleClient;
using System.ComponentModel;

namespace IfsInterface
{
    public class IfsTransactions
    {
        public class Transaction
        {
            [Description("ID")]
            [Browsable(true)]
            public string Id { get; set; }
            
            [Description("TITLE")]
            [Browsable(true)]
            public string Title { get; set; }
            
            [Description("DESCRIPTION")]
            [Browsable(true)]
            public string Description { get; set; }
            
            [Description("PACKAGE")]
            [Browsable(true)]
            public string Package { get; set; }
            
            [Description("API")]
            [Browsable(true)]
            public string Api { get; set; }
            
            [Description("VERSION")]
            [Browsable(true)]
            public string Version { get; set; }

            [Description("LICENSED")]
            [Browsable(true)]
            public bool Licensed { get; set; }

            [Description("FAILED")]
            [Browsable(false)]
            public bool Failed { get; set; }

            public IfsFields Fields { get; set; }

            public Transaction() {}

            public Transaction(Transaction transaction) 
            {
                Id = transaction.Id;
                Title = transaction.Title;
                Description = transaction.Description;
                Package = transaction.Package;
                Api = transaction.Api;
                Version = transaction.Version;
                Licensed = transaction.Licensed;
                Failed = transaction.Failed;
            }

            public Transaction(string id, string title, string description, string package, string api, string version)
            {
                Id = id;
                Title = title;
                Description = description;
                Package = package;
                Api = api;
                Version = version;
                Licensed = false;
                Failed = false;
            }

            public void LoadFields(OracleConnection connection, IfsProperties ifsProperties)
            {
                Failed = false;
                Fields = new IfsFields(connection, this.Id, ifsProperties);
            }
        }

        protected Dictionary<string, Transaction> Initalizer;
        public Dictionary<string, Transaction> Transactions;
        
        private int TransactionCount { get; set; }
        

        public IfsTransactions()
        {
            Initalizer = new Dictionary<string, Transaction>();
            Transactions = new Dictionary<string, Transaction>();
        }

        //Constructor to create an initializer based on IFS transaction field values in the database and then sets 
        //the transaction fields to these values
        public IfsTransactions(OracleConnection connection, IfsProperties ifsProperties)
        {
            Initalizer = new Dictionary<string, Transaction>();
            Transactions = new Dictionary<string, Transaction>();

            //Build a query to get transaction fields
            OracleQueryBuilder TransactionsQuery = new OracleQueryBuilder(ifsProperties.AppOwner);

            //Add Table to Select From
            TransactionsQuery.AddFrom("ESI_SW_TRANSACTIONS");

            //Add Fields to Select
            TransactionsQuery.AddSelect("TRANSACTION", "", "", "ESI_SW_TRANSACTIONS", "");//0
            TransactionsQuery.AddSelect("TITLE", "", "", "ESI_SW_TRANSACTIONS", "");//1
            TransactionsQuery.AddSelect("DESCRIPTION", "", "", "ESI_SW_TRANSACTIONS", "");//2
            TransactionsQuery.AddSelect("PACKAGE", "", "", "ESI_SW_TRANSACTIONS", "");//3
            TransactionsQuery.AddSelect("API", "", "", "ESI_SW_TRANSACTIONS", "");//4
            TransactionsQuery.AddSelect("VERSION", "", "", "ESI_SW_TRANSACTIONS", "");//5

            //Execute the query
            using (OracleDataReader results = TransactionsQuery.Execute(connection))
            {
                while (results.Read())
                {
                    if (!results.IsDBNull(0))
                    {
                        TransactionCount++;

                        //Create a field to store the values for each row
                        Transaction transaction = new Transaction();

                        //Set the field hierarchy to the value from the hierarchy 
                        //                   field.Hierarchy = Hierarchy.IndexOf(results.GetString(0));

                        //Add row values to the field

                        transaction.Id = results.GetString(0) ?? "";
                        transaction.Title = results.GetString(1) ?? "";
                        transaction.Description = results.GetString(2) ?? "";
                        transaction.Package = results.GetString(3) ?? "";
                        transaction.Api = results.GetString(4) ?? "";
                        transaction.Version = results.GetString(5) ?? "";
                        transaction.Licensed = false;

                        //Add each field to the initializer
                        Initalizer.Add(transaction.Id, transaction);
                    }
                }
            }
       /*     //Add System Transactions
            Initalizer.Add("esi_scanworks_settings", AddSystemTransaction("esi_scanworks_settings"));
            Initalizer.Add("esi_scanworks_logon", AddSystemTransaction("esi_scanworks_logon"));
            Initalizer.Add("esi_scanworks_menu", AddSystemTransaction("esi_scanworks_menu"));
            Initalizer.Add("esi_scanworks_lov", AddSystemTransaction("esi_scanworks_lov"));
            Initalizer.Add("esi_scanworks_interface", AddSystemTransaction("esi_scanworks_interface"));
            Initalizer.Add("esi_scanworks_dialog_message", AddSystemTransaction("esi_scanworks_dialog_message"));
*/
            //Initalize the transaction fields to the intializer values
            Transactions = InitializeTransactions(Initalizer);
        }

        public Transaction AddSystemTransaction(string name)
        {
            Transaction transaction = new Transaction();

            transaction.Id = name;
            transaction.Title = name;
            transaction.Description = name;
            transaction.Package = "CORE";
            transaction.Api = name;
            transaction.Licensed = true;

            return transaction;
        }


        //Initializes transaction fields with intial field values from the database.
        public Dictionary<string, Transaction> InitializeTransactions(Dictionary<string, Transaction> initialTransactions)
        {
            Dictionary<string, Transaction> transactions = new Dictionary<string, Transaction>();

            foreach (KeyValuePair<string, Transaction> initialTransaction in initialTransactions)
            {
                Transaction transaction = new Transaction();

                transaction.Id = initialTransaction.Value.Id;
                transaction.Title = initialTransaction.Value.Title;
                transaction.Description = initialTransaction.Value.Description;
                transaction.Package = initialTransaction.Value.Package;
                transaction.Api = initialTransaction.Value.Api;
                transaction.Version = initialTransaction.Value.Version;
                transaction.Licensed = initialTransaction.Value.Licensed;

                transactions.Add(transaction.Id, transaction);
            }
            
            return transactions;
        }

        //Get Field Values By Field ID
        public String GetTitle(String transaction)
        {
            return Transactions[transaction].Title;
        }
        public String GetDescription(String transaction)
        {
            return Transactions[transaction].Description;
        }
        public String GetPackage(String transaction)
        {
            return Transactions[transaction].Package;
        }
        public String GetApi(String transaction)
        {
            return Transactions[transaction].Api;
        }
        public bool Licensed(String transaction)
        {
            return Transactions[transaction].Licensed;
        }

        public Transaction GetTransaction(String transaction)
        {
            return Transactions[transaction];
        }

    }
}
