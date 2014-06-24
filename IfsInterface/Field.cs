﻿using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace IfsInterface
{
    public class Field
    {
        [Description("Field_Id")]
        [Browsable(true)]
        public string FieldID { get; set; }

        [Description("Transaction")]
        [Browsable(false)]
        public string Transaction { get; set; }

        [Description("API")]
        [Browsable(true)]
        public string API { get; set; }

        [Description("Prompt")]
        [Browsable(true)]
        public string Prompt { get; set; }

        [Description("Default_Value")]
        [Browsable(true)]
        public string DefaultValue { get; set; }

        [Description("Field_Name")]
        [Browsable(false)]
        public string FieldName { get; set; }

        [Description("Lov")]
        [Browsable(false)]
        public string Lov { get; set; }

        [Description("Lov_Prompt")]
        [Browsable(false)]
        public string LovPrompt { get; set; }

        [Description("Value")]
        [Browsable(true)]
        public string Value { get; set; }

        [Description("Hierarchy")]
        [Browsable(true)]
        public int Hierarchy { get; set; }

        [Description("Max_Length")]
        [Browsable(true)]
        public int MaxLength { get; set; }

        [Description("Enabled")]
        [Browsable(false)]
        public bool Enabled { get; set; }

        [Description("Read_Only")]
        [Browsable(true)]
        public bool ReadOnly { get; set; }

        [Description("Uppercase")]
        [Browsable(true)]
        public bool Uppercase { get; set; }

        [Description("Has_UOM")]
        [Browsable(true)]
        public bool HasUom { get; set; }

        [Description("Lov_On_Entry")]
        [Browsable(true)]
        public bool LovOnEntry { get; set; }

        [Description("Lov_Read_Only")]
        [Browsable(true)]
        public bool LovReadOnly { get; set; }

        [Description("Configuration")]
        [Browsable(false)]
        public bool Configurable { get; set; }

        public Field() { }

        public Field(string fieldID)
        {
            FieldID = fieldID;
            Transaction = "";
            API = "";
            Prompt = fieldID;
            DefaultValue = "";
            FieldName = fieldID;
            Lov = "";
            LovPrompt = "";
            Value = "";

            Hierarchy = 1;
            MaxLength = 100;

            Enabled = false;
            ReadOnly = false;
            Uppercase = true;
            HasUom = false;
            LovOnEntry = false;
            LovReadOnly = false;
            Configurable = false;

        }


        public Field(string fieldID, string transaction, string api, string prompt, string defaultValue, string fieldName, string lov, string lovPrompt,
                     int hierarchy, int maxLength, bool enabled, bool readOnly, bool uppercase, bool hasUom, bool lovOnEntry, bool lovReadOnly, bool configurable)
        {
            FieldID = fieldID;
            Transaction = transaction;
            API = api;
            Prompt = fieldID;
            DefaultValue = defaultValue;
            FieldName = fieldID;
            Lov = lov;
            LovPrompt = lovPrompt;
            Value = "";

            Hierarchy = hierarchy;
            MaxLength = maxLength;

            Enabled = enabled;
            ReadOnly = readOnly;
            Uppercase = uppercase;
            HasUom = hasUom;
            LovOnEntry = lovOnEntry;
            LovReadOnly = lovReadOnly;
            Configurable = configurable;

        }

    }
}
